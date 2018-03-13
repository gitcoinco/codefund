'use strict';

var sysPath = require('path');
var fs = require('fs-mode');
var each = require('async-each');
var glob = require('glob');
var chalk = require('chalk');

function defaultSettings(extName) {
  switch (extName) {
    case 'jade':
      return {
        regexp: /^\s*(?:include|extends)\s+(.+)/
      };
    case 'styl':
      return {
        regexp: /^\s*(?:@import|@require)\s*['"]?([^'"]+)['"]?/,
        exclusion: 'nib',
        moduleDep: true,
        globDeps: true
      };
    case 'less':
      return {
        regexp: /^\s*@import\s*(?:\([\w, ]+\)\s*)?(?:(?:url\()?['"]?([^'")]+)['"]?)/
      };
    case 'sass':
    case 'scss':
      return {
        regexp: /^\s*@import\s*['"]?([^'"]+)['"]?/,
        prefix: '_',
        exclusion: /^compass/,
        extensionsList: ['scss', 'sass'],
        multipass: [
          /@import[^;]+;/g,
          /\s*['"][^'"]+['"]\s*,?/g,
          /(?:['"])([^'"]+)/
        ]
      };
    case 'css':
      return {
        regexp: /^\s*@import\s*(?:url\()?['"]([^'"]+)['"]/
      };
  }

  return {};
}

function printDepsList(path, depsList) {
  var formatted = depsList.map(function (p) {
    return '    |--' + sysPath.relative('.', p);
  }).join('\n');

  console.log(chalk.green.bold('DEP') + ' ' + sysPath.relative('.', path));
  console.log(formatted || '    |  NO-DEP');
}

function progenyConstructor(mode, settings) {
  settings = settings || {};
  var rootPath = settings.rootPath;
  var altPaths = settings.altPaths;
  var extension = settings.extension;
  var regexp = settings.regexp;
  var prefix = settings.prefix;
  var exclusion = settings.exclusion;
  var extensionsList = settings.extensionsList;
  var multipass = settings.multipass;
  var potentialDeps = settings.potentialDeps;
  var moduleDep = settings.moduleDep;
  var globDeps = settings.globDeps;
  var reverseArgs = settings.reverseArgs;
  var debug = settings.debug;

  function parseDeps(path, source, depsList, callback) {
    var parent;
    if (path) {
      parent = sysPath.dirname(path);
    }

    var globs = [];
    var mdeps = [];
    if (multipass) {
      mdeps = multipass.slice(0, -1)
        .reduce(function (vals, regex) {
          return vals.map(function (val) {
            return val ? val.match(regex) : [];
          }).reduce(function (flat, val) {
            return flat.concat(val);
          }, []);
        }, [source])
        .map(function (val) {
          var last = multipass[multipass.length - 1];
          return val.match(last)[1];
        });
    }

    var paths = source.toString()
      .split('\n')
      .map(function (line) {
        return line.match(regexp);
      })
      .filter(function (match) {
        return match && match.length;
      })
      .map(function (match) {
        return match[1];
      })
      .concat(mdeps)
      .filter(function (path) {
        return path && ![].concat(exclusion).some(function (ex) {
          if (ex instanceof RegExp) return ex.test(path);
          if (typeof ex === 'string') return ex === path;
        });
      })
      .map(function (path) {
        var isGlob = globDeps && glob.hasMagic(path);
        if (isGlob) globs.push(path);

        var allowExtendedImports = isGlob || moduleDep;
        if (!allowExtendedImports && extension && !sysPath.extname(path)) {
          return path + '.' + extension;
        }
        return path;
      });

    var dirs = [];
    if (parent) {
      dirs.push(parent);
    }

    if (rootPath && rootPath !== parent) {
      dirs.push(rootPath);
    }

    if (Array.isArray(altPaths)) {
      [].push.apply(dirs, altPaths);
    }

    var deps = [];
    dirs.forEach(function (dir) {
      globs.forEach(function (glob) {
        depsList.patterns.push(sysPath.join(dir, glob));
      });

      paths.forEach(function (path) {
        if (moduleDep && extension && !sysPath.extname(path)) {
          deps.push(sysPath.join(dir, path + '.' + extension));
          deps.push(sysPath.join(dir, path, 'index.' + extension));
        } else {
          deps.push(sysPath.join(dir, path));
        }
      });
    });

    if (extension) {
      deps.forEach(function (path) {
        var isGlob = globDeps && glob.hasMagic(path);
        if (!isGlob && sysPath.extname(path) !== '.' + extension) {
          deps.push(path + '.' + extension);
        }
      });
    }

    if (prefix) {
      var prefixed = [];
      deps.forEach(function (path) {
        var dir = sysPath.dirname(path);
        var file = sysPath.basename(path);
        if (file.indexOf(prefix) !== 0) {
          prefixed.push(sysPath.join(dir, prefix + file));
        }
      });
      [].push.apply(deps, prefixed);
    }

    if (extensionsList.length) {
      var altExts = [];
      deps.forEach(function (path) {
        var dir = sysPath.dirname(path);
        extensionsList.forEach(function (ext) {
          if (sysPath.extname(path) !== '.' + ext) {
            var base = sysPath.basename(path, '.' + extension);
            altExts.push(sysPath.join(dir, base + '.' + ext));
          }
        });
      });

      [].push.apply(deps, altExts);
    }

    if (deps.length) {
      each(deps, function (path, callback) {
        if (depsList.indexOf(path) >= 0) {
          callback();
          return;
        }
        if (globDeps && glob.hasMagic(path)) {
          var addDeps = function (files) {
            each(files, function (path, callback) {
              addDep(path, depsList, callback);
            }, callback);
          };

          if (mode === 'Async') {
            glob(path, function (err, files) {
              if (err) {
                return callback();
              }

              addDeps(files);
            });
          } else {
            var files = glob.sync(path);
            addDeps(files);
          }
        } else {
          addDep(path, depsList, callback);
        }
      }, callback);
    } else {
      callback();
    }
  }

  function addDep(path, depsList, callback) {
    if (depsList.indexOf(path) < 0) {
      depsList.push(path);
    }

    fs[mode].readFile(path, { encoding: 'utf8' }, function (err, source) {
      if (err) {
        if (!potentialDeps) {
          depsList.splice(depsList.indexOf(path), 1);
        }
        callback();
      } else {
        parseDeps(path, source, depsList, callback);
      }
    });
  }

  var progeny = function (path, source, callback) {
    if (typeof source === 'function') {
      callback = source;
      source = undefined;
    }

    if (source && typeof source === 'object' && 'path' in source) {
      path = source.path;
      source = source.data;
    }

    if (reverseArgs) {
      var temp = source;
      source = path;
      path = temp;
    }

    var depsList = [];
    Object.defineProperty(depsList, "patterns", {
      value: [],
      writable: true,
      configurable: true,
    });

    extension = extension || sysPath.extname(path).slice(1);
    var def = defaultSettings(extension);
    if (regexp == null) regexp = def.regexp;
    if (prefix == null) prefix = def.prefix;
    if (exclusion == null) exclusion = def.exclusion;
    if (extensionsList == null) extensionsList = def.extensionsList || [];
    if (multipass == null) multipass = def.multipass;
    if (moduleDep == null) moduleDep = def.moduleDep;
    if (globDeps == null) globDeps = def.globDeps;
    if (debug == null) debug = def.debug;

    function run() {
      parseDeps(path, source, depsList, function () {
        if (debug) printDepsList(path, depsList);
        callback(null, depsList);
      });
    }

    if (source) {
      run();
    } else {
      fs[mode].readFile(path, { encoding: 'utf8' },
        function (err, fileContents) {
          if (err) {
            return callback(err);
          }

          source = fileContents;
          run();
        }
      );
    }
  };

  var progenySync = function (path, source) {
    var result = [];
    progeny(path, source, function (err, depsList) {
      if (err) {
        throw err;
      }

      result = depsList;
    });

    return result;
  };

  if (mode === 'Sync') {
    return progenySync;
  }

  return progeny;
}


module.exports = progenyConstructor.bind(null, 'Async');
module.exports.Sync = progenyConstructor.bind(null, 'Sync');
