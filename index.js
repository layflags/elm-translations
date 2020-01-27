#!/usr/bin/env node

"use strict";

const meow = require("meow");
const fs = require("fs");
const generate = require("./generator");

const cli = meow(
  `
    Usage
      $ elm-translations

    Options
      --from,   -f  path to your translations file (JSON)
      --module, -m  custom Elm module name (default: Translations)
      --version     show version

    Examples
      $ elm-translations --from en.json
      $ elm-translations -f en.json -m I18n.Translations
`,
  {
    flags: {
      from: {
        type: "string",
        alias: "f"
      },
      module: {
        type: "string",
        alias: "m",
        default: "Translations"
      }
    }
  }
);

const { from, module: moduleName } = cli.flags;

if (from) {
  let data;
  let translations;
  let elmCode;

  try {
    data = fs.readFileSync(from, "utf8");
  } catch (err) {
    console.error(`Cannot read file: ${from}`);
    process.exit(3);
  }

  try {
    translations = JSON.parse(data);
  } catch (err) {
    console.error(`Cannot parse file ${from}\n- ${err}`);
    process.exit(4);
  }

  try {
    elmCode = generate(translations, moduleName);
  } catch (err) {
    console.error(`Cannot generate Elm code\n- ${err}`);
    process.exit(5);
  }

  console.log(elmCode);
} else {
  cli.showHelp();
}
