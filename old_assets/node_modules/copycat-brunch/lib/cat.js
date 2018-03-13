var mkdirp = require('mkdirp'),
  copyFile = require('quickly-copy-file'),
  path = require('path'),
  fs = require('fs'),
  logger = require('loggy');

var mtimes = {};

var cat = (function(){
  var _0777 = parseInt('0777', 8), copiedFiles = [], verbose = false, onlyChanged = false, notModifiedCount = 0;
  return {
    setVerbose: function(v) {
      verbose = v;
    },
    setOnlyChanged: function(c) {
      onlyChanged = c;
    },
    mkdir: function(target){
      var _return = true;
      mkdirp(target, this._0777, function (err) {
          if (err) _return = false;
      });
      return _return;
    },
    copyFolderRecursiveAsync: function(source, target){
      notModifiedCount = 0;

      if (!fs.existsSync(target))
        this.mkdir(target);

      var stat = fs.lstatSync(source);

      if (stat.isDirectory()){
        files = fs.readdirSync(source);
        files.forEach(function (file) {
          var curSource = path.join(source, file);

          stat = fs.lstatSync(curSource);

          if (stat.isDirectory()){
            var curTarget = path.join(target, path.basename(curSource));
            cat.copyFolderRecursiveAsync(curSource, curTarget);
          }else{
            cat.copyFileAsync(curSource, target, stat);
          }
        });
      }else{
        this.copyFileAsync(source, target, stat);
      }

      var notModifiedMsg = onlyChanged ? ' (' + notModifiedCount + ' files were not modified)' : '';

	  logger.info('[copycat] copied ' + copiedFiles.length + ' files' + notModifiedMsg);
    },
    copyFileAsync: function(original, copy, stat){
      if (onlyChanged) {
        if ((mtimes[original] || 0) >= stat.mtime.getTime()) {
          notModifiedCount += 1;
          return;
        }

        mtimes[original] = stat.mtime.getTime();
      }

      _copyFile = path.join(copy, path.basename(original));
      copiedFiles.push(_copyFile);
      copyFile(original, _copyFile, function(error) {
        if (error)
          console.error(error);
        else{
          if(verbose){
            verbose = false; //just print the current file, or else the recursion makes it print the whole collection
            copiedFiles.forEach(function(file){
              logger.info('[copycat] copied ' + file);
            });
          }
          copiedFiles.pop(_copyFile);
        }
      });
    }
  }
})();

module.exports = cat;
