function TabulatabsBrowser(encryption) {
	var self = this;
	this.encryption = encryption;
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

		var payload = encryption.encrypt({label: this.label, description: this.description, iconURL: this.iconURL});
		payload.password = password;
		payload.useragent = this.useragent;

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
			beforeSend: tabulatabsFixChromeAuthentifiaction,
			success: function(result) {
				result.payload = encryption.decrypt(result);
				delete(result.iv);
				delete(result.ic);

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
			beforeSend: tabulatabsFixChromeAuthentifiaction,
			data: JSON.stringify(encryptedTabs),
			success: function(result) {
				callback(result);
			}
		});
	}

    this.newClient = function() {
        return new TabulatabsClient(encryption);
    }
}

var _tabulatabsCurrentBrowser = null;

function thisBrowser() {
    if (!_tabulatabsCurrentBrowser) {
        var encryption = new TabulatabsEncryption(localStorage.getItem('key'));
        localStorage.setItem('key', encryption.hexKey());

        _tabulatabsCurrentBrowser = new TabulatabsBrowser(encryption);
        _tabulatabsCurrentBrowser.username = localStorage.getItem('username');
        _tabulatabsCurrentBrowser.password = localStorage.getItem('password');

        if (!_tabulatabsCurrentBrowser.username) {
			_tabulatabsCurrentBrowser.useragent = navigator.userAgent;
			_tabulatabsCurrentBrowser.label = 'Chrome';
			_tabulatabsCurrentBrowser.description = 'Your desktop Browser';

            _tabulatabsCurrentBrowser.register(encryption.generatePassword(), function(result) {
                localStorage.setItem('username', _tabulatabsCurrentBrowser.username);
                localStorage.setItem('password', _tabulatabsCurrentBrowser.password);
            });
        }
    }
	return _tabulatabsCurrentBrowser;
}
