'use strict';

var progeny = require('./index');
var path = require('path');
var assert = require('assert');
var sinon = require('sinon');

function getFixturePath(subPath) {
  return path.join(__dirname, 'fixtures', subPath);
}

describe('progeny', function() {
  var o = { potentialDeps: true };

  it('should preserve original file extensions', function (done) {
    progeny(o)(getFixturePath('altExtensions.jade'), function (err, dependencies) {
      var paths = [
        getFixturePath('htmlPartial.html'),
        getFixturePath('htmlPartial.html.jade')
      ];
      assert.deepEqual(dependencies, paths);
      done();
    });
  });

  it('should resolve recursive dependencies', function (done) {
    progeny(o)(getFixturePath('recursive.jade'), function (err, dependencies) {
      var paths = [
        getFixturePath('altExtensions.jade'),
        getFixturePath('htmlPartial.html'),
        getFixturePath('htmlPartial.html.jade')
      ];
      assert.deepEqual(dependencies, paths);
      done();
    });
  });

  it('should resolve module imports', function (done) {
    progeny(o)(getFixturePath('module.styl'), function (err, dependencies) {
      var paths = [
        getFixturePath('base.styl'),
        getFixturePath('base/index.styl'),
        getFixturePath('foo.styl')
      ];
      assert.deepEqual(dependencies, paths);
      done();
    });
  });

  it('should resolve glob patterns', function (done) {
    progeny(o)(getFixturePath('globbing.styl'), function (err, dependencies) {
      var paths = [
        getFixturePath('base/glob/styles1.styl'),
        getFixturePath('base/glob/styles2.styl')
      ];

      assert.deepEqual(dependencies, paths);
      done();
    });
  });

  it('should list found globs in .patterns', function (done) {
    progeny(o)(getFixturePath('globbing.styl'), function (err, dependencies) {
      assert.deepEqual(dependencies.patterns, [getFixturePath('base/glob/*')]);
      done();
    });
  });

  it('should provide only real files by default', function (done) {
    progeny()(getFixturePath('recursive.jade'), function (err, dependencies) {
      var paths = [getFixturePath('altExtensions.jade')];
      assert.deepEqual(dependencies, paths);
      done();
    });
  });

  it('should resolve multiline @import statements', function (done) {
    progeny(o)(getFixturePath('multilineImport.scss'), function (err, dependencies) {
      // 6 non-excluded references in fixture
      // x4 for prefixed/unprefixed and both file extensions
      assert.equal(dependencies.length, 24);
      done();
    });
  });

  it('should be truly async', function (done) {
    var dependencies = null;
    progeny(o)(getFixturePath('altExtensions.jade'), function (err, deps) {
      dependencies = deps;
      assert(Array.isArray, dependencies);
      done();
    });

    assert.equal(dependencies, null);
  });

  it('should return empty array when there are no deps', function (done) {
    progeny(o)('foo.scss', '$a: 5px; .test {\n  border-radius: $a; }\n', function (err, deps) {
      assert.deepEqual(deps, []);
      done();
    });
  });
});

describe('progeny.Sync', function () {
  var o = { potentialDeps: true };

  it('should return the result', function () {
    assert(Array.isArray(progeny.Sync()(getFixturePath('altExtensions.jade'))));
  });

  it('should resolve glob patterns', function () {
    var dependencies = progeny.Sync(o)(getFixturePath('globbing.styl'));
    var paths = [
      getFixturePath('base/glob/styles1.styl'),
      getFixturePath('base/glob/styles2.styl')
    ];

    assert.deepEqual(dependencies, paths);
  });
});

describe('progeny configuration', function () {
  describe('excluded file list', function () {
    var progenyConfig = {
      rootPath: path.join(__dirname, 'fixtures'),
      exclusion: [
        /excludedDependencyOne/,
        /excludedDependencyTwo/
      ],
      extension: 'jade',
      potentialDeps: true
    };

    it('should accept one regex', function (done) {
      progenyConfig.exclusion = /excludedDependencyOne/;
      var getDependencies = progeny(progenyConfig);

      getDependencies(getFixturePath('excludedDependencies.jade'), function (err, dependencies) {
        var paths = [
          getFixturePath('excludedDependencyTwo.jade'),
          getFixturePath('includedDependencyOne.jade')
        ];

        assert.deepEqual(dependencies, paths);
        done();
      });
    });

    it('should accept one string', function (done) {
      progenyConfig.exclusion = 'excludedDependencyOne';
      var getDependencies = progeny(progenyConfig);

      getDependencies(getFixturePath('excludedDependencies.jade'), function (err, dependencies) {
        var paths = [
          getFixturePath('excludedDependencyTwo.jade'),
          getFixturePath('includedDependencyOne.jade')
        ];

        assert.deepEqual(dependencies, paths);
        done();
      });
    });

    it('should accept a list of regexes', function (done) {
      progenyConfig.exclusion = [
        /excludedDependencyOne/,
        /excludedDependencyTwo/
      ];
      var getDependencies = progeny(progenyConfig);

      getDependencies(getFixturePath('excludedDependencies.jade'), function (err, dependencies) {
        assert.deepEqual(dependencies, [getFixturePath('includedDependencyOne.jade')]);
        done();
      });
    });

    it('should accept a list of strings', function (done) {
      progenyConfig.exclusion = [
        'excludedDependencyOne',
        'excludedDependencyTwo'
      ];
      var getDependencies = progeny(progenyConfig);

      getDependencies(getFixturePath('excludedDependencies.jade'), function (err, dependencies) {
        assert.deepEqual(dependencies, [getFixturePath('includedDependencyOne.jade')]);
        done();
      });
    });

    it('should accept a list of both strings and regexps', function (done) {
      progenyConfig.exclusion = [
        'excludedDependencyOne',
        /excludedDependencyTwo/
      ]
      var getDependencies = progeny(progenyConfig);

      getDependencies(getFixturePath('excludedDependencies.jade'), function (err, dependencies) {
        assert.deepEqual(dependencies, [getFixturePath('includedDependencyOne.jade')]);
        done();
      });
    });
  });

  describe('altPaths', function () {
    it('should look for deps in altPaths', function (done) {
      var progenyConfig = {
        altPaths: [getFixturePath('subdir')],
        potentialDeps: true
      };

      progeny(progenyConfig)(getFixturePath('altExtensions.jade'), function (err, dependencies) {
        var paths = [
          getFixturePath('htmlPartial.html'),
          getFixturePath('subdir/htmlPartial.html'),
          getFixturePath('htmlPartial.html.jade'),
          getFixturePath('subdir/htmlPartial.html.jade'),
        ];
        assert.deepEqual(dependencies, paths);
        done();
      });
    });
  });

  describe('reverseArgs', function () {
    it('should allow path, source args to be switched', function (done) {
      var progenyConfig = {
        potentialDeps: true,
        reverseArgs: true
      };

      progeny(progenyConfig)('@require bar\na=5px\n.test\n\tborder-radius a', 'foo.styl', function (err, deps) {
        assert.deepEqual(deps, ['bar.styl', 'bar/index.styl']);
        done();
      });
    });
  });

  describe('regexes', function () {
    describe('Stylus', function () {
      it('should get Stylus @import statements', function (done) {
        var progenyConfig = { potentialDeps: true };
        progeny(progenyConfig)(getFixturePath('imports/foo.styl'), function (err, deps) {
          assert.deepEqual(deps, [getFixturePath('imports/bar.styl')]);
          done();
        });
      });
    });

    describe('LESS', function () {
      it('should get normal LESS import statements', function (done) {
        var progenyConfig = { potentialDeps: true };
        progeny(progenyConfig)(getFixturePath('imports/foo.less'), function (err, deps) {
          assert.deepEqual(deps, [getFixturePath('imports/bar.less')]);
          done();
        });
      });

      it('should get LESS import statements with one or more options', function (done) {
        var progenyConfig = { potentialDeps: true };
        progeny(progenyConfig)(getFixturePath('imports/foo-options.less'), function (err, deps) {
          assert.deepEqual(deps, [getFixturePath('imports/bar.less'), getFixturePath('imports/baz.less')]);
          done();
        });
      });

      it('should get LESS imports with the url() function', function (done) {
        var progenyConfig = { potentialDeps: true };
        progeny(progenyConfig)(getFixturePath('imports/foo-url.less'), function (err, deps) {
          assert.deepEqual(deps, [
            getFixturePath('imports/bar.less'),
            getFixturePath('imports/baz.less'),
            getFixturePath('imports/qux.less')
          ]);
          done();
        });
      });
    });
  });

  describe('Debug mode', function () {
    beforeEach(function () {
      sinon.spy(console, 'log');
    });

    it('should print dependencies list when debug is set to true', function (done) {
      progeny({ debug: true, potentialDeps: true })(getFixturePath('imports/foo.less'), function (err, deps) {
        assert(console.log.callCount === 2);
        done();
      });
    });

    afterEach(function () {
      console.log.restore();
    });
  });
});
