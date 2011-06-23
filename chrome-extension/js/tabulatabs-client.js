function TabulatabsClient(clientId) {
	var serverPath = 'http://apiv0.tabulatabs.com/';

	var self = this;

	var getOption = function(varName, defaultValue) {
		if (localStorage.getItem(varName)) {
			return localStorage.getItem(varName);
		} else {
			if(defaultValue) localStorage.setItem(varName, defaultValue);
			return defaultValue;
		}
	}

	var generatePassword = function() {
		var c = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPRSTUVWXYZ';
		var cLength = c.length;

		var passwd = '';

		for(var i = 0; i < 32; i++) {
			passwd += c[Math.floor(Math.random() * cLength)];
		}

		return passwd;
	}

	var registerBrowser = function(userId, userPassword, callback) {
		if (!callback) callback = function(data) {};

		$.post(serverPath, {
			'userId': userId,
			'userPasswd': userPassword,
			'action': 'registerBrowser'
		}, callback, 'json');
	}

	var encryptionPassword = getOption('encryptionPassword', generatePassword());
	var userId = getOption('userId', null);
	var userPassword = getOption('userPassword', null);
	var registeredClients = getOption('registeredClients', []);

	if (!userId | !userPassword) {
		userId = getOption('userId', randomUUID());
		userPassword = getOption('userPassword', generatePassword());

		registerBrowser(userId, userPassword, function() {
			self.putObjectForKey('browserInfo', {'label': 'Chrome', 'icon': 'chromeIcon_512.png'});
		});
	}

	var encrypt = function(payload) {
		return sjcl.encrypt(encryptionPassword, JSON.stringify(payload));
	};

	var decrypt = function(payload) {
		if(!payload) {
			return null;
		}

		return JSON.parse(sjcl.decrypt(encryptionPassword, payload));
	};

	this.setTabs = function(tabs) {
		this.putObjectForKey('browserTabs', tabs, function(response) { console.dir(response); });
	}

	this.clientRegistrationUrl = function() {
		return 'tabulatabs:register?id=' + userId + '&p1=' + userPassword + '&p2=' + encryptionPassword;
	}

	this.getObjectForKey = function(key, callback, errorCallback) {
		if (!errorCallback) errorCallback = function() {};

		$.post(serverPath, {
			'userId': userId,
			'userPasswd': userPassword,
			'action': 'get',
			'key': key
		}, function(data) {
			console.dir(data);
		}, 'json');
	}

	this.putObjectForKey = function(key, value, callback) {
		if (!callback) callback = function(data) {};
		
		encryptedValue = JSON.stringify(encrypt(value));

		$.post(serverPath, {
			'userId': userId,
			'userPasswd': userPassword,
			'action': 'put',
			'key': key,
			'value': encryptedValue
		}, callback, 'json');
	}
	
	this.getRegisteredClients = function() {
		return registeredClients;
	}

	this.getTabs = function(callback) {
		/* var tabs = unhosted.dav.get('openTabs.json', function(encryptedTabs) {
			var tabs = decrypt(encryptedTabs);
			if(!tabs) {
				tabs = {};
			}

			callback(tabs);
		}); */
	}
	/*
	this.calculateThumbFilename = function(url, width, height) {
		return 'thumb_' + SHA1(url) + '_' + width + 'x' + height + '.json';
	}

	this.setThumbnail = function(url, width, height, thumbUrl) {
		unhosted.dav.put(this.calculateThumbFilename(url, width, height), encrypt({src: thumbUrl}));
	}

	this.getThumbnail = function(url, width, height, callback) {
		var decryptCallback = function(encryptedThumb) {
			callback(decrypt(encryptedThumb));
		}
		
		//return unhosted.dav.get(this.calculateThumbFilename(url, width, height), decryptCallback);
	}
	*/
}
