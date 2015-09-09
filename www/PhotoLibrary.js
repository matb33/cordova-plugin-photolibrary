console.log("[PhotoLibrary] installing...");

var exec = require("cordova/exec");

module.exports = {
	getRandomPhotos: function (howMany, width, height, callback) {
		console.log("[PhotoLibrary] getRandomPhotos");

		if (navigator.userAgent.indexOf("Android") !== -1) {
			// Android done in JS (TODO)
			callback(null, {});
		} else {
			exec(function success(result) {
				callback(null, _.map(result || [], function (path) {
					if (path.indexOf('/var/mobile') !== -1) {
						path = 'cdvfile://localhost/persistent/' + path.replace(/.*Documents\//, '');
					}
					return path;
				});
			}, function error(err) {
				callback(err, {});
			}, "PhotoLibrary", "getRandomPhotos", [howMany, width, height]);
		}
	}
};

console.log("[PhotoLibrary] installed.");