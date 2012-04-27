function TabulatabsBrowser(encryption) {
	var self = this;
	this.encryption = encryption;
	this.useragent = '';
	this.label = '';
	this.description = '';
	this.iconURL = '';
	this.id = 0;

	this.username = null;
	this.password = null;

	this.clients = [];

	this.whenReadyCallbacks = [];

	this.register = function(password, callback) {
		if (!callback) callback = function() {};

		this.password = password;
		var self = this;

		var payload = encryption.encrypt({label: this.label, description: this.description, iconURL: this.iconURL});
		payload.password = password;
		payload.useragent = this.useragent;

		$.post(tabulatabsServerPath + 'browsers.json', JSON.stringify(payload), function(result) {
			self.username = result.username;
			self.id = result.id;

			callback(result);

			$.each(self.whenReadyCallbacks, function(index, callback) {
				callback();
			});
			self.whenReadyCallbacks = [];
		});
	}

	this.update = function(callback) {
		if (!callback) callback = function() {};
		
		var payload = encryption.encrypt({label: this.label, description: this.description, iconURL: this.iconURL});

		$.ajax(tabulatabsServerPath + 'browsers/update.json', {
			type: 'POST',
			username: self.username,
			password: self.password,
			data: JSON.stringify(payload),
			beforeSend: tabulatabsFixChromeAuthentifiaction,
			success: function(result) {
				callback(result);
			}
		});
	}

	var _load = function(username, password, callback) {
		if (!callback) callback = function() {};

		$.ajax(tabulatabsServerPath + 'browsers.json', {
			type: 'GET',
			username: username,
			password: password,
			beforeSend: tabulatabsFixChromeAuthentifiaction,
			success: function(result) {
				result.payload = encryption.decrypt(result);
				delete(result.iv);
				delete(result.ic);

				self.id = result.id;
				self.useragent = result.useragent;
				self.label = result.payload.label;
				self.description = result.payload.description;
				self.iconURL = result.payload.iconURL;

				callback(result);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.dir([jqXHR, textStatus, errorThrown]);
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
			beforeSend: tabulatabsFixChromeAuthentifiaction,
			success: function(result) {
				self.clients = [];

				if(result.length) {
					$.each(result, function(index, data) {
						data.payload = encryption.decrypt(data);
						delete(data.iv);
						delete(data.ic);

						client = new TabulatabsClient();

						client.id = data.id;
						client.useragent = data.useragent;
						client.label = data.payload.label;
						client.description = data.payload.description;
						client.iconURL = data.payload.iconURL;
						if (data.accessed_at) {
							client.accessedAt = new Date(data.accessed_at);
						}

						self.clients.push(client);
					});
				}

				callback(result);
			}
		});
	}

	this.destroyClient = function(client, callback) {
		if (!callback) callback = function() {};

		$.ajax(tabulatabsServerPath + 'browsers/clients/' + client.id + '.json', {
			type: 'DELETE',
			username: self.username,
			password: self.password,
			beforeSend: tabulatabsFixChromeAuthentifiaction,
			success: callback
		});
	}

	this.saveTabs = function(tabs, callback, errorCallback) {
		if (!callback) callback = function() {};
		if (!errorCallback) errorCallback = function() {};

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
			beforeSend: tabulatabsFixChromeAuthentifiaction,
			data: JSON.stringify(encryptedTabs),
			success: function(result) {
				callback(result);
			},
			error: errorCallback
		});
	}

    this.newClient = function() {
        return new TabulatabsClient(encryption);
    }

    this.whenReady = function(callback) {
    	if (this.username) {
    		callback();
    	} else {
    		this.whenReadyCallbacks.push(callback);
    	}
    }
}

var _tabulatabsCurrentBrowser = null;

function thisBrowser(browserRegisteredCallback) {
    if (!_tabulatabsCurrentBrowser) {
        var encryption = new TabulatabsEncryption(localStorage.getItem('key'));
        localStorage.setItem('key', encryption.hexKey());

        _tabulatabsCurrentBrowser = new TabulatabsBrowser(encryption);
        _tabulatabsCurrentBrowser.username = localStorage.getItem('username');
        _tabulatabsCurrentBrowser.password = localStorage.getItem('password');

        if (!_tabulatabsCurrentBrowser.username) {
			_tabulatabsCurrentBrowser.useragent = navigator.userAgent;
			if (typeof(safari) != 'undefined') _tabulatabsCurrentBrowser.label = 'Safari';
			if (typeof(chrome) != 'undefined') _tabulatabsCurrentBrowser.label = 'Chrome';
			_tabulatabsCurrentBrowser.description = '';

            _tabulatabsCurrentBrowser.register(encryption.generatePassword(), function(result) {
                localStorage.setItem('username', _tabulatabsCurrentBrowser.username);
                localStorage.setItem('password', _tabulatabsCurrentBrowser.password);

                if (browserRegisteredCallback) {
                	browserRegisteredCallback();
                };
            });
        }
    }
	return _tabulatabsCurrentBrowser;
}