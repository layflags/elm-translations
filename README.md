# elm-translations

**Generate type safe translations for your Elm app**

`elm-translations` is a command line script that generates an Elm module from your JSON translation files. This module just includes a `Translations` type (nested Record), a JSON decoder and a JSON parser, but not the actual translation data. So you just need to generate the Elm code once and then use for all the languages you want to support in your app by e.g. loading them dynamically at runtime.

## Features

### ✅ Type safe

Won't compile if you try to access the wrong keys in your Elm code

### ✅ Nesting support

Let's you organize your translations easily

### ✅ Variable substitutions

Just pass a Record and never forget to set a variable again

## Usage

```sh
# get a preview of the generated Elm code
$ npx elm-translations --from your-translations.json

# generate Elm code and store it here: ./src/Translations.elm
$ npx elm-translations --from your-translations.json --out src

# or use a custom module name - will be stored here: ./src/I18n/Trans.elm
$ npx elm-translations --from your-translations.json --module I18n.Trans --out src

# see all possible options
$ npx elm-translations --help

  Type safe translations for Elm

  Usage
    $ elm-translations

  Options
    --from,   -f  path to your translations file (JSON)
    --module, -m  custom Elm module name (default: Translations)
    --root,   -r  key path to use as root (optional)
    --out,    -o  path to a folder where the generated translations should be saved (optional)
    --version     show version

  Examples
    $ elm-translations --from en.json
    $ elm-translations -f en.json -m I18n.Translations -o src
```

## Examples

### Passing translation data via `flags`

1. Create your `Translations.elm` file with e.g.:

```sh
$ npx elm-translations -f en.json -o src
```

2. In your Html page pass the translation data:

```html
...
<script>
  Elm.Main.init({
    node: document.getElementById("elm"),
    flags: {
      // your translation data inlined by e.g. EJS or Handlebars:
      // ...
      welcome: "Welcome {{name}}!",
      home: {
        intro: "This App is about ..."
      }
      // ...
    }
  });
</script>
...
```

3. In your Elm app use the translations:

```elm
module Main exposing (..)

import Json.Decode
import Json.Encode
import Translations exposing (Translations)


-- ...


type Model
    = Initialized Translations
    | Failed Json.Decode.Error


init : Json.Encode.Value -> ( Model, Cmd Msg )
init flags =
    case Translations.parse flags of
        Ok t ->
            ( Initialized t, Cmd.none )

        Err error ->
            ( Failed error, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Initialized t ->
            div []
                [ h1 [] [ text <| t.welcome { name = "John" } ]
                , p [] [ text t.home.intro ]
                ]

        Failed error ->
            p [] [ text "Error: Cannot proccess translation data" ]


-- ...

```

### Dynamically fetching translation data

There's an example available in the git repository. To let it run locally on your machine, follow these steps:

1. Clone the respository

```sh
$ git clone git@github.com:layflags/elm-translations.git
```

2. Go to the example folder

```sh
$ cd elm-translations/example
```

3. Generate the `Translations.elm` module

```sh
$ npx elm-translations --from en.json --out src
```

4. Start Elm Reactor and go to http://localhost:8000/src/Main.elm

```sh
$ elm reactor
```

## JSON file requirements

### Use only lower camel case keys!

**🟢 YES**

```json
{ "buttonTitle": "Submit" }
```

```json
{ "headline": "Welcome to Elm!" }
```

**🔴 NO**

```json
{ "button-title": "Submit" }
```

```json
{ "Headline": "Submit" }
```

### Use only lower camel case variables!

**🟢 YES**

```json
{ "welcome": "Hi {{name}}!" }
```

```json
{ "welcome": "Hi {{firstName}} {{lastName}}!" }
```

**🔴 NO**

```json
{ "welcome": "Hi {{Name}}!" }
```

```json
{ "welcome": "Hi {{first_Name}} {{last_Name}}!" }
```

### Use only `String` values (nesting possible)!

**🟢 YES**

```json
{ "buttonTitle": "Submit" }
```

```json
{ "form": { "buttonTitle": "Submit" } }
```

**🔴 NO**

```json
{ "count": 3 }
```

```json
{ "isVisible": true }
```

```json
{ "name": null }
```
