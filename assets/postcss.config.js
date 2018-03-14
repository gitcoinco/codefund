/* eslint-disable import/no-extraneous-dependencies,global-require */

module.exports = {
  plugins: [
    require("postcss-import"),
    require("postcss-cssnext"),
    require("postcss-flexbugs-fixes"),
    require("cssnano")({
      preset: "default"
    })
  ]
};
