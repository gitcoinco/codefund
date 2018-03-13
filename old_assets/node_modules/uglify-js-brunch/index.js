'use strict';

const uglify = require('uglify-js');

const formatError = (error) => {
  const err = new Error(`L${error.line}:${error.col} ${error.message}`);
  err.name = '';
  err.stack = error.stack;
  return err;
};

class UglifyJSOptimizer {
  constructor(config) {
    this.options = Object.assign({}, config.plugins.uglify);
    this.options.fromString = true;
    this.options.sourceMaps = !!config.sourceMaps;
  }

  optimize(file) {
    const data = file.data;
    const path = file.path;

    try {
      if (this.options.ignored && this.options.ignored.test(file.path)) {
        // ignored file path: return non minified
        const result = {
          data,
          // brunch passes in a SourceMapGenerator object, but wants a string back.
          map: file.map ? file.map.toString() : null,
        };
        return Promise.resolve(result);
      }
    } catch (e) {
      return Promise.reject(`error checking ignored files to uglify ${e}`);
    }

    if (file.map) {
      this.options.inSourceMap = file.map.toJSON();
    }

    this.options.outSourceMap = this.options.sourceMaps ?
      `${path}.map` : undefined;

    try {
      const optimized = uglify.minify(data, this.options);

      const result = optimized && this.options.sourceMaps ? {
        data: optimized.code,
        map: optimized.map,
      } : {
        data: optimized.code,
      };
      result.data = result.data.replace(/\n\/\/# sourceMappingURL=\S+$/, '');

      return Promise.resolve(result);
    } catch (err) {
      return Promise.reject(formatError(err));
    }
  }
}

UglifyJSOptimizer.prototype.brunchPlugin = true;
UglifyJSOptimizer.prototype.type = 'javascript';

module.exports = UglifyJSOptimizer;
