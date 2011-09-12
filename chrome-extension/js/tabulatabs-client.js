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

	var generateRandomByteArray = function(length) {
		var bytes = new Uint8Array(length);
		window.crypto.getRandomValues(bytes);
		return bytes;
	};

	var generateKey = function() {
		return generateRandomByteArray(32);
	};

	var generateHexKey = function() {
		return GibberishAES.a2h(generateKey());
	}

	var generateIv = function() {
		return generateRandomByteArray(16);
	}

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

	var key = GibberishAES.h2a(getOption('key', generateHexKey()));
	var userId = getOption('userId', null);
	var clientId = getOption('clientId', null);
	var registeredClients = getOption('registeredClients', []);

	if (!userId | !clientId) {
		userId = getOption('userId', randomUUID());
		clientId = getOption('clientId', randomUUID());

		registerBrowser(userId, clientId, function() {
			self.putObjectForKey('browserInfo', {'label': 'Chrome', 'icon': 'chromeIcon_512.png'});
		});
	}

	var encrypt = function(payload) {
		var iv = generateIv();
		var ic = GibberishAES.Base64.encode(GibberishAES.rawEncrypt(GibberishAES.s2a(JSON.stringify(payload)), key, iv));
		return {iv: GibberishAES.a2h(iv), ic: ic};
	};

	var decrypt = function(encryptedObject) {
		var iv = GibberishAES.h2a(encryptedObject.iv);
		var json = GibberishAES.rawDecrypt(GibberishAES.Base64.decode(encryptedObject.ic), key, iv, false);
		return JSON.parse(json);
	};

	var uploadTabs = function(action, tabs) {
		var encryptedTabs = {};

		$.each(tabs, function(id, tab) {
			encryptedTabs[id] = encrypt(tab);
			console.log(id, encryptedTabs[id]);
		});

		$.post(serverPath, {
			'userId': userId,
			"clientId": clientId,
			'action': action,
			'tabs': JSON.stringify(encryptedTabs)
		}, function(result) {
			console.dir(result);
		}, 'json');
	}

	// TODO delete me
	this.encrypt = function(payload) {
		return encrypt(payload);
	}

	// TODO delete me
	this.decrypt = function(payload) {
		return decrypt(payload);
	}

	this.replaceTabs = function(tabs) {
		uploadTabs('replaceTabs', tabs);
	}

	this.updateTabs = function(tab) {
		uploadTabs('updateTab', tabs);
	}

	this.setTabs = function(tabs) {
		this.putObjectForKey('browserTabs', tabs, function(response) {
			// console.dir(response);
		});
	}

	this.clientRegistrationUrl = function() {
		var newClientId = randomUUID();
		console.dir(key);
		console.dir(GibberishAES.a2h(key));
		var url = 'tabulatabs:/register?uid=' + userId + '&cid=' + newClientId + '&k=' + GibberishAES.a2h(key);
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
		
		encryptedValue = JSON.stringify(encrypt(value));

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
}
