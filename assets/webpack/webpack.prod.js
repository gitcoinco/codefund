/* eslint-disable import/no-extraneous-dependencies */

const path = require("path");
const merge = require("webpack-merge");
const UglifyJSPlugin = require("uglifyjs-webpack-plugin");
const WorkboxPlugin = require("workbox-webpack-plugin");

const { JS_PATH } = require("./paths");
const common = require("./webpack.common");

module.exports = merge(common, {
  devtool: "source-map",
  plugins: [
    new UglifyJSPlugin({
      sourceMap: true
    }),
    new WorkboxPlugin({
      swDest: path.join(JS_PATH, "sw.js"),
      clientsClaim: true,
      skipWaiting: true
    })
  ]
});
