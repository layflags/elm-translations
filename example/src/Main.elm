module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, hr, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Language exposing (Language(..))
import Translations exposing (Translations)
import Url.Builder


type Status
    = Pending
    | Failed Http.Error
    | Initialised Translations


type alias Model =
    { language : Language
    , status : Status
    }


type Msg
    = GotTranslations (Result Http.Error Translations)
    | LanguageSwitched


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Language.default Pending, fetchTranslations Language.default )


view : Model -> Html Msg
view { language, status } =
    div
        [ style "margin" "16px"
        , style "text-align" "center"
        ]
    <|
        case status of
            Pending ->
                [ text "Loading ... " ]

            Failed _ ->
                [ text "Fetching translations failed" ]

            Initialised t ->
                [ button [ onClick LanguageSwitched ]
                    [ case language of
                        EN ->
                            text "Zu deutsch wechseln"

                        DE ->
                            text "Switch to english"
                    ]
                , hr [] []
                , h1 [] [ text t.title ]
                , p []
                    [ text <|
                        t.authentication.info
                            { username = "John D."
                            , role = "Admin"
                            }
                    ]
                ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTranslations (Ok translations) ->
            ( { model | status = Initialised translations }, Cmd.none )

        GotTranslations (Err error) ->
            ( { model | status = Failed error }, Cmd.none )

        LanguageSwitched ->
            let
                lng =
                    Language.switch model.language
            in
            ( { model | language = lng }, fetchTranslations lng )



-- HELPERS


fetchTranslations : Language -> Cmd Msg
fetchTranslations language =
    Http.get
        { url = Url.Builder.absolute [ Language.toString language ++ ".json" ] []
        , expect = Http.expectJson GotTranslations Translations.decoder
        }
