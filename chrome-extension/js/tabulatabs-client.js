tabulatabsDocumentVersion = 1;

var tabulatabsServerPath = 'https://tabulatabs.heroku.com/';
//var tabulatabsServerPath = 'http://localhost:3000/';

var tabulatabsFixChromeAuthentifiaction = function(jqXHR, settings) {
	if (settings.username) {
		jqXHR.setRequestHeader('Authorization', 'Basic ' + base64_encode(settings.username + ':' + settings.password) + '==');
	}
};

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

	this.tabs = [];

	this.claimingPassword = '';

	this.registrationURL = function() {
		return 'tabulatabs://client/claim/' + [this.username, this.claimingPassword, encryption.hexKey()].join('/');
	}

	this.create = function(username, password, claimingPassword, callback) {
		if (!callback) callback = function() {};

		$.ajax(tabulatabsServerPath + 'browsers/clients.json', {
			type: 'POST',
			username: username,
			password: password,
			beforeSend: tabulatabsFixChromeAuthentifiaction,
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
			beforeSend: tabulatabsFixChromeAuthentifiaction,
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
			beforeSend: tabulatabsFixChromeAuthentifiaction,
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
	this.colorPalette = [];
	this.dominantColor = null;
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
		this.index = data.index;
		this.colorPalette = data.colorPalette;
		this.dominantColor = data.dominantColor;
		this.pageTitle = data.pageTitle;
		this.shortDomain = data.shortDomain;
		this.siteTitle = data.siteTitle;
		this.pageThumbnail = data.pageThumbnail;
	}
}
