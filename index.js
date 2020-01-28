#!/usr/bin/env node

"use strict";

const meow = require("meow");
const fs = require("fs");
const path = require('path')
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
      --out,    -o  path to a folder where the generated translations should be saved (optional)
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
      },
      out: {
        type: "string",
        alias: "o",
        default: ""
      }
    }
  }
);

const { from, module: moduleName, root , out: outputFolder} = cli.flags;


if (from) {
  const resolveTranslationsPath = (moduleName, baseDir = __dirname)  => {
    const filePath = path.resolve(baseDir, path.join(...moduleName.split('.')))
    return `${filePath}.elm`

  }
  const writeFile = (filePath) => {
    const fileFolder = path.dirname(filePath)
    if(!fs.existsSync(fileFolder)) {
      fs.mkdirSync(fileFolder, { recursive: true })
    }
    return fs.writeFileSync(filePath, elmCode, 'utf8')
  }

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

  if (outputFolder) {
    try {
      writeFile(resolveTranslationsPath(moduleName, path.resolve(outputFolder)), data)
    } catch(err) {
      console.error(`Cannot create translations file\n- ${err}`);
      process.exit(6);
    }
  } else {
    console.log(elmCode);
  }
} else {
  cli.showHelp();
}
