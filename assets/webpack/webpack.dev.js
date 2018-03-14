/* eslint-disable import/no-extraneous-dependencies */

const merge = require("webpack-merge");
const common = require("./webpack.common");

module.exports = merge(common, {
  devtool: "inline-source-map",
  stats: {
    colors: true
  },
  performance: {
    hints: false
  }
});
