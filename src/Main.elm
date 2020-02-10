port module Main exposing (main)

import Json.Decode
import Json.Encode
import TranslationsCodeGen


port succeed : String -> Cmd msg


port fail : String -> Cmd msg


type alias Flags =
    ( String, Json.Encode.Value )


main : Program Flags () ()
main =
    Platform.worker
        { init = init
        , update = (always >> always) ( (), Cmd.none )
        , subscriptions = always Sub.none
        }


init : Flags -> ( (), Cmd () )
init ( moduleName, data ) =
    ( ()
    , case TranslationsCodeGen.generateCode moduleName data of
        Ok code ->
            succeed code

        Err error ->
            fail <| Json.Decode.errorToString error
    )
