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
	};

	var generatePassword = function() {
		var c = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPRSTUVWXYZ';
		var cLength = c.length;

		var passwd = '';

		for(var i = 0; i < 32; i++) {
			passwd += c[Math.floor(Math.random() * cLength)];
		}

		return passwd;
	};

	var registerBrowser = function(userId, clientId, callback) {
		if (!callback) callback = function(data) {};

		$.post(serverPath, {
			'userId': userId,
			"clientId": clientId,
			'action': 'registerBrowser'
		}, callback, 'json');
	};

	var registerClient = function(userId, clientId, callback) {
		if (!callback) callback = function(data) {};

		$.post(serverPath, {
			'userId': userId,
			"clientId": clientId,
			'action': 'registerClient'
		}, callback, 'json');
	};

	var encryptionPassword = getOption('encryptionPassword', generatePassword());
	var userId = getOption('userId', null);
	var clientId = getOption('clientId', null);
	var registeredClients = getOption('registeredClients', []);

	if (!userId | !clientId) {
		userId = getOption('userId', randomUUID());
		clientId = getOption('clientId', generatePassword());

		registerBrowser(userId, clientId, function() {
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
		this.putObjectForKey('browserTabs', tabs, function(response) {
			// console.dir(response);
		});
	}

	this.clientRegistrationUrl = function() {
		var newClientId = generatePassword();
		var url = 'tabulatabs:/register?uid=' + userId + '&cid=' + newClientId + '&p=' + encryptionPassword;
		registerClient(userId, newClientId);
		
		console.log(url);
		return url;
	}

	this.getObjectForKey = function(key, callback, errorCallback) {
		if (!errorCallback) errorCallback = function() {};

		$.post(serverPath, {
			'userId': userId,
			"clientId": clientId,
			'action': 'get',
			'key': key
		}, function(data) {
			console.dir(data);
		}, 'json');
	}

	this.putObjectForKey = function(key, value, callback) {
		if (!callback) callback = function(data) {};
		
		encryptedValue = encrypt(value);

		$.post(serverPath, {
			'userId': userId,
			"clientId": clientId,
			'action': 'put',
			'key': key,
			'value': encryptedValue
		}, callback, 'json');
	};
	
	this.getRegisteredClients = function() {
		return registeredClients;
	};

	this.getTabs = function(callback) {
		/* var tabs = unhosted.dav.get('openTabs.json', function(encryptedTabs) {
			var tabs = decrypt(encryptedTabs);
			if(!tabs) {
				tabs = {};
			}

			callback(tabs);
		}); */
	};
	
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
