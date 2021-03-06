tabulatabsDocumentVersion = 1;

if (typeof(tabulatabsServerPath) == 'undefined')
	tabulatabsServerPath = 'http://apiv1.tabulatabs.com/';
    // tabulatabsServerPath = 'http://localhost:4242/';

if (typeof(settingsStorage) != 'undefined' && settingsStorage.getItem('apiServer')) {
    tabulatabsServerPath = settingsStorage.getItem('apiServer');
}

// we are running on a webserver - lets assume its a testserver
if (document.location.protocol.match(/^https?:$/)) {
    tabulatabsServerPath = document.location.origin + '/';
}

$.ajaxSetup({
	beforeSend: function(jqXHR, settings) {
		// fix authorization in some chorme versions
		if (settings.username != null) {
			jqXHR.setRequestHeader('Authorization', 'Basic ' + base64_encode(settings.username + ':' + settings.password));
		}

		// add correct request content type
		if ((settings.type == 'POST') || (settings.type == 'PUT')) {
			jqXHR.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
			settings.contentType = 'application/json; charset=UTF-8';
		};

        settings.accepts = 'application/json';
	}
});

function TabulatabsClient(encryption) {
	var self = this;

	this.encryption = encryption;

	this.id = 0;

	this.username = '';
	this.password = '';

	this.useragent = '';
	this.label = '';
	this.description = '';
	this.iconURL = '';
	this.accessedAt = null;
    this.version = 2;

	this.tabs = [];

	this.claimingPassword = '';

    this.fromData = function(data) {
        data.payload = this.encryption.decrypt(data);

        this.id = data.id;
        this.useragent = data.useragent;
        this.label = data.payload.label;
        this.description = data.payload.description;
        this.iconURL = data.payload.iconURL;
        this.version = data.version;

        if (data.accessed_at) {
            this.accessedAt = new Date(data.accessed_at);
        }
    }

	this.registrationURL = function() {
		return 'tabulatabs://client/claim/' + [this.username, this.claimingPassword, encryption.hexKey()].join('/');
	}

	this.create = function(username, password, claimingPassword, callback) {
		if (!callback) callback = function() {};

		$.ajax(tabulatabsServerPath + 'browsers/clients.json', {
			type: 'POST',
			username: username,
			password: password,
			data: JSON.stringify({password: claimingPassword}),
			success: function(result) {
				self.claimingPassword = claimingPassword;
				self.username = result.username;

				callback(result);
			}
		});
	}

	this.createWithBrowser = function(browser, claimingPassword, callback) {
		self.create(browser.username, browser.password, claimingPassword, callback);
	};

	this.claim = function(claimingPassword, permanentPassword, callback)  {
		if (!callback) callback = function() {};

		var payload = this.encryption.encrypt({label: self.label, description: self.description, iconURL: self.iconURL});
		payload.password = permanentPassword;
		payload.useragent = self.useragent;

		$.ajax(tabulatabsServerPath + 'browsers/clients/claim.json', {
			type: 'PUT',
			username: self.username,
			password: claimingPassword,
			data: JSON.stringify(payload),
			success: function(result) {
				self.password = permanentPassword;
				self.id = result.id;
				callback(result);
			}
		});
	};

	this.loadTabs = function(callback) {
		$.ajax(tabulatabsServerPath + 'browsers/tabs.json', {
			type: 'GET',
			username: self.username,
			password: self.password,
            data: { client_version: this.version },
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
	this.windowFocused = false;
	this.index = 0;
	this.colorPalette = [];
	this.pageTitle = '';
	this.shortDomain = '';
	this.siteTitle = '';
	this.pageThumbnail = '';

	if (data) {
		this.identifier = data.identifier;
		this.title = data.title;
		this.URL = data.URL;
		this.selected = data.selected;
		this.favIconURL = data.favIconURL;
		this.windowId = data.windowId;
		this.windowFocused = data.windowFocused;
		this.index = data.index;
		this.colorPalette = data.colorPalette;
		this.pageTitle = data.pageTitle;
		this.shortDomain = data.shortDomain;
		this.siteTitle = data.siteTitle;
		this.pageThumbnail = data.pageThumbnail;
	}
}
