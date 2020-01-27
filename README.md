# elm-translations

Generate type safe translations for your Elm app.

## Usage

```
$ npx elm-translations --help
$ npx elm-translations --from your-translations.json > src/Translations.elm
```

### From `your-translations.json`

```json
{
  "keywords": "elm,typesafe,translations",
  "navigation": {
    "contact": "Contact",
    "admin": {
      "authInfo": "Your are logged in as {{username}} ({{role}})"
    }
  }
}
```

**Requirements:**

- use only lower camel case keys
- use only lower camel case variables
- use only `String` values

### To generated `src/Translations.elm`

```elm
module Translations exposing (Translations, parse)

import Json.Decode exposing (Decoder, Error, Value, map, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Translations_navigation_admin =
    { authInfo : { username : String, role : String } -> String
    }


decodeTranslations_navigation_admin : Decoder Translations_navigation_admin
decodeTranslations_navigation_admin =
    let
        substitute_authInfo content args =
            content
                |> String.replace "{{username}}" args.username
                |> String.replace "{{role}}" args.role
    in
    succeed Translations_navigation_admin
        |> required "authInfo" (map substitute_authInfo string)


type alias Translations_navigation =
    { contact : String
    , admin : Translations_navigation_admin
    }


decodeTranslations_navigation : Decoder Translations_navigation
decodeTranslations_navigation =
    succeed Translations_navigation
        |> required "contact" string
        |> required "admin" decodeTranslations_navigation_admin


type alias Translations =
    { keywords : String
    , navigation : Translations_navigation
    }


decodeTranslations : Decoder Translations
decodeTranslations =
    succeed Translations
        |> required "keywords" string
        |> required "navigation" decodeTranslations_navigation


parse : Value -> Result Error Translations
parse =
    Json.Decode.decodeValue decodeTranslations
```

### Use it in your Elm app like e.g.:

```elm
module Main exposing (main)

import Browser
import Html exposing (..)
import Json.Decode
import Translations


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Model
    = Failed String
    | Initialised Translations.Translations


type alias Flags =
    { translations : Json.Decode.Value }


init : Flags -> ( Model, Cmd Msg )
init { translations } =
    case Translations.parse translations of
        Ok t ->
            ( Initialised t
            , Cmd.none
            )

        Err _ ->
            ( Failed "Parsing translations failed"
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    case model of
        Failed message ->
            Html.text <| "Initialisation failed: " ++ message

        Initialised t ->
            p []
                [ Html.text t.keywords
                , br [] []
                , Html.text <|
                    t.navigation.admin.authInfo
                        { username = "John D."
                        , role = "Admin"
                        }
                ]

...
```
