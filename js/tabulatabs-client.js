function TabulatabsClient(clientId) {
	var getOption = function(varName, defaultValue) {
		if (localStorage.getItem(varName)) {
			return localStorage.getItem(varName);
		} else {
			localStorage.setItem(varName, defaultValue);
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

	var encryptionPassword = getOption('encryptionPassword', generatePassword());
	var userId = getOption('userId', randomUUID());
	var userPassword = getOption('userPassword', generatePassword());
	var registeredClients = getOption('registeredClients', []);

	var encrypt = function(payload) {
		if(!encryptionPassword) {
			return {unencrypted: payload};
		} else {
			return {encrypted: sjcl.encrypt(encryptionPassword, JSON.stringify(payload))};
		}
	};

	var decrypt = function(payload) {
		if(!payload) {
			return null;
		}

		if(!payload.encrypted) {
			return payload.unencrypted;
		} else {
			if(!encryptionPassword) {
				throw "noPassword";
			}

			return JSON.parse(sjcl.decrypt(encryptionPassword, payload.encrypted));
		}
	};

	this.clientRegistrationUrl = function() {
		return 'tabulatabs:register?id=' + userId + '&p1=' + userPassword + '&p2=' + encryptionPassword;
	}

	this.getRegisteredClients = function() {
		return registeredClients;
	}

	this.setTabs = function(tabs) {
		//unhosted.dav.put('openTabs.json', encrypt(tabs));
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
}
