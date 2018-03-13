'use strict';

const babel = require('babel-core');
const anymatch = require('anymatch');
const resolve = require('path').resolve;
const logger = require('loggy');

const reIg = /^(bower_components|vendor)/;

const warns = {
  ES6to5: 'Please use `babel` instead of `ES6to5` option in your config file.'
};

const prettySyntaxError = (err) => {
  if (!(err._babel && err instanceof SyntaxError)) return err;
  const msg = err.message.replace(/\(\d+:\d+\)$/, '').replace(/^([\./\w]+\:\s)/, '');
  const error = new Error(`L${err.loc.line}:${err.loc.column} ${msg}\n${err.codeFrame}`);
  error.name = '';
  error.stack = err.stack;
  return error;
};

class BabelCompiler {
  constructor(config) {
    if (!config) config = {};
    const pl = config.plugins;
    const options = pl && (pl.babel || pl.ES6to5) || {};

    if (pl && !pl.babel && pl.ES6to5) {
      logger.warn(warns.ES6to5);
    }

    const opts = Object.keys(options).reduce((obj, key) => {
      if (key !== 'sourceMap' && key !== 'ignore') {
        obj[key] = options[key];
      }
      return obj;
    }, {});

    opts.sourceMap = !!config.sourceMaps;
    if (!opts.presets) {
      opts.presets = ['latest'];
      // ['env', opts.env]
    }
    if (!opts.plugins) opts.plugins = [];

    // this is needed so that babel can locate presets when compiling node_modules
    const mapOption = type => data => {
      const resolvePath = name => {
        // for cases when plugins name do not match common convention
        // for example: `babel-root-import`
        const plugin = name.startsWith('babel-') ? name : `babel-${type}-${name}`;
        return resolve(config.paths.root, 'node_modules', plugin);
      };
      if (typeof data === 'string') return resolvePath(data);
      return [resolvePath(data[0]), data[1]];
    };
    const mappedPresets = opts.presets.map(mapOption('preset'));
    const mappedPlugins = opts.plugins.map(mapOption('plugin'));
    opts.presets = mappedPresets;
    opts.plugins = mappedPlugins;
    if (opts.presets.length === 0) delete opts.presets;
    if (opts.plugins.length === 0) delete opts.plugins;
    if (opts.pattern) {
      this.pattern = opts.pattern;
      delete opts.pattern;
    }
    this.isIgnored = anymatch(options.ignore || reIg);
    this.options = opts;
  }

  compile(file) {
    if (this.isIgnored(file.path)) return Promise.resolve(file);
    this.options.filename = file.path;
    this.options.sourceFileName = file.path;

    return new Promise((resolve, reject) => {
      let compiled;

      try {
        compiled = babel.transform(file.data, this.options);
      } catch (error) {
        reject(prettySyntaxError(error));
        return;
      }

      const result = {data: compiled.code || compiled};

      // Concatenation is broken by trailing comments in files, which occur
      // frequently when comment nodes are lost in the AST from babel.
      result.data += '\n';

      if (compiled.map) result.map = JSON.stringify(compiled.map);
      resolve(result);
    });
  }
}

BabelCompiler.prototype.brunchPlugin = true;
BabelCompiler.prototype.type = 'javascript';
BabelCompiler.prototype.extension = 'js';
BabelCompiler.prototype.pattern = /\.(es6|jsx?)$/;

module.exports = BabelCompiler;
