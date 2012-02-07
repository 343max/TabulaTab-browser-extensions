tabulatabsDocumentVersion = 1;

var tabulatabsServerPath = 'https://tabulatabs.heroku.com/';
//var tabulatabsServerPath = 'htt://localhost:3000/';

function TabulatabsEncryption(key) {
	this.key = key;
	this.forcedIv = null;

	var generateRandomByteArray = function(length) {
		var bytes = new Uint8Array(length);
		window.crypto.getRandomValues(bytes);
		return bytes;
	};

	var generateKey = function() {
		return generateRandomByteArray(32);
	};

	var generateIv = function() {
		return generateRandomByteArray(16);
	}

	this.generateHexKey = function() {
		var key = GibberishAES.a2h(generateKey());
		return key;
	}

	if (!this.key) {
		this.key = this.generateHexKey();
	}

	this.encrypt = function(payload) {
		var iv = this.forcedIv || generateIv();
		var ic = GibberishAES.Base64.encode(GibberishAES.rawEncrypt(GibberishAES.s2a(JSON.stringify(payload)), this.key, iv), false);
		return {iv: GibberishAES.a2h(iv), ic: ic};
	};

	this.decrypt = function(encryptedObject) {
		var iv = GibberishAES.h2a(encryptedObject.iv);
		var json = GibberishAES.rawDecrypt(GibberishAES.Base64.decode(encryptedObject.ic), this.key, iv, false);
		return JSON.parse(json);
	};
}

function TabulatabsBrowser(encryption) {
	var self = this;
	var encryption = encryption;
	this.useragent = '';
	this.label = '';
	this.description = '';
	this.iconURL = '';

	this.username = null;
	this.password = null;

	this.clients = [];

	this.register = function(password, callback) {
		if (!callback) callback = function() {};

		this.password = password;

		var payload = encryption.encrypt({useragent: this.useragent, label: this.label, description: this.description, iconURL: this.iconURL});
		payload.password = password;

		$.post(tabulatabsServerPath + 'browsers.json', JSON.stringify(payload), function(result) {
			self.username = result.username;

			callback(result);
		});
	}

	var _load = function(username, password, callback) {
		if (!callback) callback = function() {};

		$.ajax(tabulatabsServerPath + 'browsers.json', {
			type: 'GET',
			username: username,
			password: password,
			success: function(result) {
				result.payload = encryption.decrypt(result);
				delete(result.iv);
				delete(result.ic);

				self.useragent = result.payload.useragent;
				self.label = result.payload.label;
				self.description = result.payload.description;
				self.iconURL = result.payload.iconURL;

				callback(result);
			}
		});
	}

	this.load = function(callback) {
		_load(this.username, this.password, callback);
	}

	this.loadWithClient = function(client, callback) {
		_load(client.username, client.password, callback);
	}

	this.loadClients = function(callback) {
		if (!callback) callback = function() {};

		$.ajax(tabulatabsServerPath + 'browsers/clients.json', {
			type: 'GET',
			username: self.username,
			password: self.password,
			success: function(result) {
				self.clients = [];

				if(result.length) {
					$.each(result, function(index, data) {
						data.payload = encryption.decrypt(data);
						delete(data.iv);
						delete(data.ic);

						client = new TabulatabsClient();

						client.useragent = data.payload.useragent;
						client.label = data.payload.label;
						client.description = data.payload.description;
						client.iconURL = data.payload.iconURL;

						self.clients.push(client);
					});
				}

				callback(result);
			}
		});
	}

	this.saveTabs = function(tabs, callback) {
		if (!callback) callback = function() {};

		var encryptedTabs = [];

		$.each(tabs, function(index, tab) {
			var encryptedTab = encryption.encrypt(tab);
			encryptedTab.identifier = tab.identifier;

			encryptedTabs.push(encryptedTab);
		});

		$.ajax(tabulatabsServerPath + 'browsers/tabs.json', {
			type: 'POST',
			username: self.username,
			password: self.password,
			data: JSON.stringify(encryptedTabs),
			success: function(result) {
				callback(result);
			}
		});
	}
}

function TabulatabsClient(encryption) {
	var self = this;

	this.encryption = encryption;
	
	this.username = '';
	this.password = '';

	this.useragent = '';
	this.label = '';
	this.description = '';
	this.iconURL = '';

	this.tabs = [];

	this.claimingPassword = '';

	this.registrationURL = function() {
		return 'tabulatabs://registerClient?username=' + this.username + '&password=' + this.claimingPassword + '&key=' + encryption.key;
	}

	this.registerWithBrowser = function(browser, claimingPassword, callback) {
		if (!callback) callback = function() {};

		$.ajax(tabulatabsServerPath + 'browsers/clients.json', {
			type: 'POST',
			username: browser.username,
			password: browser.password,
			data: JSON.stringify({password: claimingPassword}),
			success: function(result) {
				self.claimingPassword = claimingPassword;
				self.username = result.username;
				
				callback(result);
			}
		});
	};

	this.claim = function(claimingPassword, permanentPassword, callback)  {
		if (!callback) callback = function() {};

		var payload = this.encryption.encrypt({useragent: self.useragent, label: self.label, description: self.description, iconURL: self.iconURL});
		payload.password = permanentPassword;

		$.ajax(tabulatabsServerPath + 'browsers/clients/claim.json', {
			type: 'PUT',
			username: self.username,
			password: claimingPassword,
			data: JSON.stringify(payload),
			success: function(result) {
				self.password = permanentPassword;
				callback(result);
			}
		});
	};

	this.loadTabs = function(callback) {
		$.ajax(tabulatabsServerPath + 'browsers/tabs.json', {
			type: 'GET',
			username: self.username,
			password: self.password,
			success: function(result) {
				tabs = [];

				$.each(result, function(index, encryptedTab) {
					var tab = new TabulatabsTab(encryption.decrypt(encryptedTab));
					tabs.push(tab);
				});

				self.tabs = tabs;

				callback(result);
			}
		});
	}
}

function TabulatabsTab(data) {
	var self = this;

	this.identifier = '';
	this.title = '';
	this.URL = '';
	this.selected = false;
	this.favIconURL = '';
	this.windowId = '';
	this.index = 0;
	this.pageColors = [];

	if (data) {
		this.identifier = data.identifier;
		this.title = data.title;
		this.URL = data.URL;
		this.selected = data.selected;
		this.favIconURL = data.favIconURL;
		this.windowId = data.windowId;
		this.index = data.index;
		this.pageColors = data.pageColors;
	}
}

function thisBrowser() {
	var encryption = new TabulatabsEncryption(localStorage.getItem('key'));
	localStorage.setItem('key', encryption.key);

	var browser = new TabulatabsBrowser(encryption);
	browser.username = localStorage.getItem('username');
	browser.password = localStorage.getItem('password');

	if (!browser.username) {
		browser.register(encryption.generateHexKey(), function(result) {
			localStorage.setItem('username', browser.username);
			localStorage.setItem('password', browser.password);
		});
	}

	return browser;
}
