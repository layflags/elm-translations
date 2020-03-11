module Language exposing (Language(..), default, switch, toString)


type Language
    = DE
    | EN


switch : Language -> Language
switch language =
    case language of
        EN ->
            DE

        DE ->
            EN


default : Language
default =
    EN


toString : Language -> String
toString language =
    case language of
        EN ->
            "en"

        DE ->
            "de"
