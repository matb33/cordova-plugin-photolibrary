console.log("[PhotoLibrary] installing...");

var exec = require("cordova/exec");

module.exports = {
	getRandomPhotos: function (howMany, callback) {
		console.log("[PhotoLibrary] getRandomPhotos");

		if (navigator.userAgent.indexOf("Android") !== -1) {
			// Android done in JS (TODO)
			callback(null, []);
		} else {
			exec(function success(result) {
				callback(null, _.map(result || [], function (path) {
					var obj = {};

					obj.path = path;
					if (path.indexOf('/var/mobile') !== -1) {
						obj.cdvfile = 'cdvfile://localhost/persistent/' + path.replace(/.*Documents\//, '');
					}

					return obj;
				}));
			}, function error(err) {
				callback(err, null);
			}, "PhotoLibrary", "getRandomPhotos", [howMany]);
		}
	}
};

console.log("[PhotoLibrary] installed.");