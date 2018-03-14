const path = require("path");

const SOURCE_PATH = path.resolve(__dirname, "src");
const OUTPUT_PATH = path.resolve(__dirname, "../../priv/static");
const JS_PATH = path.resolve(__dirname, "../../priv/static/js");

module.exports = {
  JS_PATH,
  SOURCE_PATH,
  OUTPUT_PATH
};
