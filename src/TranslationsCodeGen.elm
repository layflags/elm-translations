module TranslationsCodeGen exposing (generateCode)

import Elm.CodeGen exposing (..)
import Elm.Pretty
import Elm.Syntax.Expression exposing (LetDeclaration)
import Json.Decode as JD
import Json.Encode as JE
import Regex


type alias TKey =
    String


type alias TVar =
    String


type TValue
    = TLeaf String
    | TLeafWithSubstitutions String (List TVar)
    | TBranch TTree


type alias TTree =
    List ( TKey, TValue )


generateCode : String -> JE.Value -> Result JD.Error String
generateCode moduleName jsonData =
    if String.split "." moduleName |> List.all isUpperCamelCase then
        parseJson jsonData |> Result.map (toCode moduleName)

    else
        Err <|
            JD.Failure "Module name is not in upper camel case"
                (JE.string moduleName)



-- HELPER


moduleComment : String
moduleComment =
    """


# !!! DO NOT EDIT THIS FILE !!!

This file was generated with:
<https://github.com/layflags/elm-translations>"""


parseJson : JE.Value -> Result JD.Error TTree
parseJson =
    JD.decodeValue (lowerCamelCaseKeyValuePairs decodeTValue)


toCode : String -> TTree -> String
toCode moduleName data =
    let
        comment =
            markdown moduleComment emptyFileComment
    in
    Elm.Pretty.pretty 80 <|
        file
            (generateModule moduleName)
            imports
            ([ decoderFunDecl, parseFunDecl ]
                ++ generateTypeAndDecoderDeclList [] data
            )
            (Just comment)


decodeTValue : JD.Decoder TValue
decodeTValue =
    JD.oneOf
        [ JD.string |> JD.map toLeaf
        , JD.lazy <|
            \_ ->
                lowerCamelCaseKeyValuePairs decodeTValue |> JD.map TBranch
        ]


toLeaf : String -> TValue
toLeaf value =
    case extractVars value of
        [] ->
            TLeaf value

        vars ->
            TLeafWithSubstitutions value vars


lowerCamelCaseKeyValuePairs : JD.Decoder a -> JD.Decoder (List ( String, a ))
lowerCamelCaseKeyValuePairs =
    JD.keyValuePairs
        >> JD.andThen
            (\list ->
                if List.all (Tuple.first >> isLowerCamelCase) list then
                    JD.succeed list

                else
                    JD.fail "Invalid key(s) found - use lower camel case only"
            )


isLowerCamelCase : String -> Bool
isLowerCamelCase =
    let
        lowerCamelCase =
            Maybe.withDefault Regex.never <|
                Regex.fromString "^[a-z][a-zA-Z0-9]*$"
    in
    Regex.contains lowerCamelCase


isUpperCamelCase : String -> Bool
isUpperCamelCase =
    let
        upperCamelCase =
            Maybe.withDefault Regex.never <|
                Regex.fromString "^[A-Z][a-zA-Z0-9]*$"
    in
    Regex.contains upperCamelCase


extractVars : String -> List TVar
extractVars str =
    let
        vars =
            Maybe.withDefault Regex.never <|
                Regex.fromString "\\{\\{([a-z][a-zA-Z0-9_]*)\\}\\}"
    in
    Regex.find vars str
        |> List.map (.match >> String.dropLeft 2 >> String.dropRight 2)


join_ : List String -> String
join_ =
    String.join "_"


{-|

    module MODULE_NAME exposing (Translations, parse)

-}
generateModule : String -> Module
generateModule name =
    normalModule (String.split "." name)
        [ typeOrAliasExpose "Translations"
        , funExpose "parse"
        , funExpose "decoder"
        ]


{-|

    import Json.Decode exposing (Decoder, Error, Value, map, string, succeed)
    import Json.Decode.Pipeline exposing (required)

-}
imports : List Import
imports =
    [ importStmt [ "Json", "Decode" ]
        Nothing
        (Just <|
            exposeExplicit
                [ typeOrAliasExpose "Decoder"
                , typeOrAliasExpose "Error"
                , typeOrAliasExpose "Value"
                , funExpose "map"
                , funExpose "string"
                , funExpose "succeed"
                ]
        )
    , importStmt [ "Json", "Decode", "Pipeline" ]
        Nothing
        (Just <|
            exposeExplicit
                [ funExpose "required"
                ]
        )
    ]


{-|

    decoder : Decoder Translations
    decoder =
        decodeTranslations

-}
decoderFunDecl : Declaration
decoderFunDecl =
    funDecl Nothing
        (Just (typeVar "Decoder Translations"))
        "decoder"
        []
        (apply [ fun "decodeTranslations" ])


{-|

    parse : Value -> Result Error Translations
    parse =
        Json.Decode.decodeValue decodeTranslations

-}
parseFunDecl : Declaration
parseFunDecl =
    funDecl Nothing
        (Just
            (funAnn
                (typeVar "Value")
                (typeVar "Result Error Translations")
            )
        )
        "parse"
        []
        (apply
            [ fqFun [ "Json", "Decode" ] "decodeValue"
            , fun "decodeTranslations"
            ]
        )


generateTypeAndDecoderDeclList : List String -> TTree -> List Declaration
generateTypeAndDecoderDeclList path data =
    List.foldl
        (\( key, value ) result ->
            case value of
                TLeaf _ ->
                    result

                TLeafWithSubstitutions _ _ ->
                    result

                TBranch tree ->
                    List.concat
                        [ result
                        , generateTypeAndDecoderDeclList (path ++ [ key ]) tree
                        ]
        )
        (generateTypeAndDecoderDecl path data)
        data


substitutionsRecordAnn : List TVar -> TypeAnnotation
substitutionsRecordAnn =
    recordAnn << List.map (\var -> ( var, stringAnn ))


toRecordTypeField : String -> ( TVar, TValue ) -> ( TVar, TypeAnnotation )
toRecordTypeField typePrefix ( key, value ) =
    ( key
    , case value of
        TLeaf _ ->
            stringAnn

        TLeafWithSubstitutions _ vars ->
            funAnn (substitutionsRecordAnn vars) stringAnn

        TBranch _ ->
            typeVar <| join_ [ typePrefix, key ]
    )


toDecoderExpression : String -> ( TVar, TValue ) -> Expression
toDecoderExpression decoderPrefix ( key, value ) =
    let
        expr =
            case value of
                TLeaf _ ->
                    fun "string"

                TLeafWithSubstitutions _ _ ->
                    parens <|
                        apply
                            [ fun "map"
                            , fun (join_ [ "substitute", key ])
                            , fun "string"
                            ]

                TBranch _ ->
                    fun <| join_ [ decoderPrefix, key ]
    in
    apply [ fun "required", string key, expr ]


toReplacerExpr : String -> Expression
toReplacerExpr varName =
    apply
        [ fqFun [ "String" ] "replace"
        , string <| "{{" ++ varName ++ "}}"
        , access (val "args") varName
        ]


substitutionLetFunction : TKey -> List TVar -> LetDeclaration
substitutionLetFunction key vars =
    letFunction
        (join_ [ "substitute", key ])
        [ varPattern "content", varPattern "args" ]
    <|
        pipe (val "content") (List.map toReplacerExpr vars)


toSubstitutionFunList : TTree -> List LetDeclaration
toSubstitutionFunList =
    List.foldl
        (\( key, value ) result ->
            case value of
                TLeafWithSubstitutions _ vars ->
                    substitutionLetFunction key vars :: result

                _ ->
                    result
        )
        []


generateTypeAndDecoderDecl : List String -> TTree -> List Declaration
generateTypeAndDecoderDecl path data =
    let
        typeName =
            join_ ("Translations" :: path)

        decoderTypeVar =
            typeVar <| String.join " " [ "Decoder", typeName ]

        decoderName =
            "decode" ++ typeName

        decoderFields =
            List.map (toDecoderExpression decoderName) data

        decoderExpr =
            pipe (apply [ fun "succeed", val typeName ]) decoderFields

        decoderBody =
            case toSubstitutionFunList data of
                [] ->
                    decoderExpr

                funList ->
                    letExpr funList decoderExpr

        recordTypeAnn =
            recordAnn <| List.map (toRecordTypeField typeName) data
    in
    [ aliasDecl Nothing typeName [] recordTypeAnn
    , funDecl Nothing (Just decoderTypeVar) decoderName [] decoderBody
    ]
