function TabulatabsClient(clientId) {
	var unhosted = Unhosted('tabulatabs.com');

	var encryptionPassword = null;

	if(localStorage.getItem('encryptionPassword')) {
		encryptionPassword = Base64.decode(localStorage.getItem('encryptionPassword'));
	}

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

	this.setEncryptionPassword = function(newEncryptionPassword) {
		encryptionPassword = newEncryptionPassword
		localStorage.setItem('encryptionPassword', Base64.encode(encryptionPassword));
	}

	this.getUsername = function() {
		return unhosted.getUserName();
	}

	this.loggedIn = function() {
		return !!this.getUsername();
	}

	this.logout = function() {
		unhosted.setUserName('');
		localStorage.removeItem('OAuth2-cs::token');
	}

	this.login = function(userName) {
		unhosted.setUserName(userName);
	}

	this.setTabs = function(tabs) {
		unhosted.dav.put('openTabs.json', encrypt(tabs));
	}

	this.getTabs = function(callback) {
		var tabs = unhosted.dav.get('openTabs.json', function(encryptedTabs) {
			var tabs = decrypt(encryptedTabs);
			if(!tabs) {
				tabs = {};
			}

			callback(tabs);
		});
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
		
		return unhosted.dav.get(this.calculateThumbFilename(url, width, height), decryptCallback);
	}
}
