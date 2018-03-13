## babel-brunch

Brunch plugin using [babel](https://github.com/babel/babel) to turn latest
ECMAScript standard code into vanilla ES5 with no runtime required.

All the `.js` files in your project will be run through the babel compiler,
except those it is configured to ignore, unless you use the `pattern` option.

Additionally, starting Brunch 2.7, babel-brunch will also compile NPM dependencies.

## Installation

`npm install --save-dev babel-brunch`

## Configuration

[babel-preset-latest](https://babeljs.io/docs/plugins/preset-latest/) (es2015, es2016, es2017) **is used by default**, you don't need to adjust config to have it.

### Using React; or any other plugin

Install a plugin:

```
npm insall --save-dev babel-preset-react
```

Then, make sure Brunch sees it:

```javascript
exports.plugins = {
  babel: {
    presets: ['latest', 'react']
  }
}
```

Optionally, you can configure the preset:

`presets: [ 'latest', ['transform-es2015-template-literals', {spec: true}] ]`


### Ignoring node modules

```
exports.plugins = {
  babel: {
    ignore: [
      /^node_modules/,
      'app/legacyES5Code/**/*'
    ]
  }
}
```

### Changing which files would be compiled by babel

```
exports.plugins = {
  babel: {
    pattern: /\.es7$/ // By default, JS|JSX|ES6 are used.
  }
}
```

Set [babel options](https://babeljs.io/docs/usage/options) in your brunch
config (such as `brunch-config.js`) except for `filename` and `sourceMap`
which are handled internally.

## Change Log
[See release notes page on GitHub](https://github.com/babel/babel-brunch/releases)

## License

[ISC](https://raw.github.com/babel/babel-brunch/master/LICENSE)
