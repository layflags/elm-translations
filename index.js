#!/usr/bin/env node

"use strict";

const meow = require("meow");
const fs = require("fs");
const dotProp = require("dot-prop");
const isPlainObj = require("is-plain-obj");
const generate = require("./generator");

const cli = meow(
  `
    Usage
      $ elm-translations

    Options
      --from,   -f  path to your translations file (JSON)
      --module, -m  custom Elm module name (default: Translations)
      --root,   -r  key path to use as root (optional)
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
      },
      root: {
        type: "string",
        alias: "r",
        default: ""
      }
    }
  }
);

const { from, module: moduleName, root } = cli.flags;

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
    console.error(`Cannot parse file: ${from}\n- ${err}`);
    process.exit(4);
  }

  if (root) {
    const value = dotProp.get(translations, root);
    if (isPlainObj(value)) {
      translations = value;
    } else {
      console.error(
        `Cannot use root: ${root}\n- Error: value of key '${root}' is not an object`
      );
      process.exit(5);
    }
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
