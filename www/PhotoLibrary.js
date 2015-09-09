console.log("[PhotoLibrary] installing...");

var exec = require("cordova/exec");

module.exports = {
	getRandomPhotos: function (howMany, callback) {
		console.log("[PhotoLibrary] getRandomPhotos");

		if (navigator.userAgent.indexOf("Android") !== -1) {
			// Android done in JS (TODO)
			callback(null, {});
		} else {
			exec(function success(result) {
				callback(null, result || {});
			}, function error(err) {
				callback(err, {});
			}, "PhotoLibrary", "getRandomPhotos", [howMany]);
		}
	}
};

console.log("[PhotoLibrary] installed.");