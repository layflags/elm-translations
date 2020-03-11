#!/bin/sh

mkdir -p dist
elm make src/Main.elm --output=dist/elm.js
cp index.html en.json de.json dist/
cd dist
surge --domain elm-translations-example.surge.sh
