var params={}, cat = require('./cat'),
  logger = require('loggy'), copycat = function(config) {params = config;}
copycat.prototype.brunchPlugin = true;
copycat.prototype.type='javascript';
copycat.prototype.extension='js';

copycat.prototype.onCompile = function(data, path, callback) {
  var verbose = 'verbose';
  var onlyChanged = 'onlyChanged';
  cat.setVerbose(params.plugins.copycat[verbose] ? params.plugins.copycat[verbose] : false);
  cat.setOnlyChanged(params.plugins.copycat[onlyChanged] ? params.plugins.copycat[onlyChanged] : false);
  Object.keys(params.plugins.copycat).forEach(function(key){
    var destination = key;
    var directories = params.plugins.copycat[key];
    if(typeof destination === 'string' && (typeof directories === 'string' || typeof directories === 'object')) {
      if(typeof directories === 'string'){
        cat.copyFolderRecursiveAsync(directories, params.paths.public + '/' + destination);
      }else{
		directories.forEach(function(directory) {
			cat.copyFolderRecursiveAsync(directory, params.paths.public + '/' + destination);
		});
      }
    }
  });
};

module.exports = copycat;
