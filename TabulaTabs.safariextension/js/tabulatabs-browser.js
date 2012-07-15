function TabulatabsBrowser(encryption) {
	var self = this;
	this.encryption = encryption;
	this.useragent = '';
	this.label = '';
	this.description = '';
	this.iconURL = '';
	this.id = 0;
    this.streamingEnabledUntil = new Date(null);

	this.username = null;
	this.password = null;

	this.clients = [];

	this.whenReadyCallbacks = [];

	var registrationInProgress = false;

    this.streamingEnabled = function() {
        return this.streamingEnabledUntil > (new Date());
    }

    this.fromData = function(result) {
        result.payload = encryption.decrypt(result);

        self.id = result.id;
        self.useragent = result.useragent;
        self.streamingEnabledUntil = result.streaming_enabled_until;
        self.label = result.payload.label;
        self.description = result.payload.description;
        self.iconURL = result.payload.iconURL;
    }

	this.register = function(password, callback) {
		if (registrationInProgress) {
			return;
		};
		registrationInProgress = true;

		if (!callback) callback = function() {};

		this.password = password;
		var self = this;

		var payload = encryption.encrypt({label: this.label, description: this.description, iconURL: this.iconURL});
		payload.password = password;
		payload.useragent = this.useragent;

		$.post(tabulatabsServerPath + 'browsers.json', JSON.stringify(payload), function(result) {
			self.username = result.username;
			self.id = result.id;
            self.streamingEnabledUntil = new Date(result.streaming_enabled_until);

			callback(result);

			$.each(self.whenReadyCallbacks, function(index, callback) {
				callback();
			});
			self.whenReadyCallbacks = [];
			registrationInProgress = false;
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
			success: function(result) {
                self.fromData(result);

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
			success: function(result) {
				self.clients = [];

				if(result.length) {
					$.each(result, function(index, data) {
                        var client = new TabulatabsClient(encryption);
                        client.fromData(data);
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
			success: callback
		});
	}

	var uploadTabs = function(method, tabs, callback, errorCallback) {
		if (!callback) callback = function() {};
		if (!errorCallback) errorCallback = function() {};

		var encryptedTabs = [];

		$.each(tabs, function(index, tab) {
			var encryptedTab = encryption.encrypt(tab);
			encryptedTab.identifier = tab.identifier;

			encryptedTabs.push(encryptedTab);
		});

		return $.ajax(tabulatabsServerPath + 'browsers/tabs/' + (method == 'PUT' ? 'update' : ''), {
			type: method,
			username: self.username,
			password: self.password,
			data: JSON.stringify(encryptedTabs),
			success: function(result) {
                self.streamingEnabledUntil = new Date(result.streaming_enabled_until);
                callback(result);
			},
			error: errorCallback
		}).fail(errorCallback);
	}

	this.saveTabs = function(tabs, callback, errorCallback) {
		return uploadTabs('POST', tabs, callback, errorCallback);
	}

	this.updateTabs = function(tabs, callback, errorCallback) {
		return uploadTabs('PUT', tabs, callback, errorCallback);
	}

    this.newClient = function() {
        return new TabulatabsClient(encryption);
    }

    this.whenReady = function(callback) {
    	if (self.username) {
    		callback();
    	} else {
    		self.whenReadyCallbacks.push(callback);
    	}
    }
}

