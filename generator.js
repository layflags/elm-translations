"use strict";

const generate = (data, moduleName) => {
  if (!isValidModuleName(moduleName)) {
    throw Error(
      `Module name invalid: ${moduleName} (upper camel case required)`
    );
  }
  return [
    header(moduleName),
    ...mapNested(data),
    generateType(data),
    generateDecoder(data),
    footer
  ]
    .join("\n")
    .trim();
};

module.exports = generate;

// HELPERS

const isValidModuleName = value => /^[A-Z][a-zA-Z0-9]*$/.test(value);

const isValidKey = value => /^[a-z][a-zA-Z0-9]*$/.test(value);

const placeholderRegex = /{{([a-z][a-zA-Z0-9]*)}}/g;

const matchAll = (str, regex) => {
  let result;
  const matches = [];
  // eslint-disable-next-line no-cond-assign
  while ((result = regex.exec(str)) !== null) {
    matches.push(result);
  }
  return matches;
};

const scanPlaceholders = value =>
  matchAll(value, placeholderRegex).map(([, placeholder]) => placeholder);

const hasPlaceholders = value =>
  Boolean(value.match && value.match(placeholderRegex));

// CODE GENERATORS

const header = moduleName => `
module ${moduleName} exposing (Translations, parse)

import Json.Decode exposing (Decoder, Error, Value, map, string, succeed)
import Json.Decode.Pipeline exposing (required)
`;

const footer = `
parse : Value -> Result Error Translations
parse =
    Json.Decode.decodeValue decodeTranslations
`;

const generateType = (obj, prefix) => {
  const prefixed = prefix ? `_${prefix}` : "";
  const wrap = content =>
    `
type alias Translations${prefixed} =
    { ${content}
    }
`;
  const rows = Object.entries(obj).map(([key, value]) => {
    if (!isValidKey(key)) {
      throw Error(`Key invalid: ${key} (lower camel case required)`);
    }
    const type = (() => {
      if (typeof value === "string") {
        if (hasPlaceholders(value)) {
          const args = scanPlaceholders(value);
          return `{ ${args
            .map(arg => `${arg} : String`)
            .join(", ")} } -> String`;
        }
        return "String";
      }
      return `Translations${prefixed}_${key}`;
    })();
    return `${key} : ${type}`;
  });
  return wrap(rows.join("\n    , "));
};

const generateDecoder = (obj, prefix) => {
  const prefixed = prefix ? `_${prefix}` : "";

  const wrapSubstitues = content =>
    content
      ? `
    let
${content}
    in`
      : "";

  const wrap = (substitutes, decoder) =>
    `
decodeTranslations${prefixed} : Decoder Translations${prefixed}
decodeTranslations${prefixed} =${wrapSubstitues(substitutes)}
    succeed Translations${prefixed}
${decoder}
`;

  const substitutes = Object.entries(obj)
    .filter(([, value]) => hasPlaceholders(value))
    .map(([key, value]) => {
      const args = scanPlaceholders(value);
      return `        substitute_${key} content args =
            content
${args
  .map(arg => `                |> String.replace "{{${arg}}}" args.${arg}`)
  .join("\n")}`;
    });

  const rows = Object.entries(obj).map(([key, value]) => {
    const decoder =
      typeof value === "string"
        ? (hasPlaceholders(value) && `(map substitute_${key} string)`) ||
          "string"
        : `decodeTranslations${prefixed}_${key}`;
    return `        |> required "${key}" ${decoder}`;
  });

  return wrap(substitutes.join("\n\n"), rows.join("\n"));
};

const mapNested = (obj, prefix) =>
  Object.entries(obj)
    .filter(([, value]) => typeof value !== "string")
    .reduce((acc, [key, value]) => {
      if (!isValidKey(key)) {
        throw Error(`Key invalid: ${key} (lower camel case required)`);
      }
      const prefixed = prefix ? `${prefix}_${key}` : key;
      return acc.concat([
        ...mapNested(value, prefixed),
        generateType(value, prefixed),
        generateDecoder(value, prefixed)
      ]);
    }, []);
