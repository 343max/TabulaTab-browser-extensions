function TabulatabsSocketIo(username, password, key, categories) {
    var self = this;

    if (!categories) categories = ['tabs', 'clients', 'browsers'];
    var encryption = new TabulatabsEncryption(key);

    var socket = null;
    this.socket = null;

    this.connected = function() {};
    this.connectionError = function() {};
    this.tabsReplaced = function(tabs) {};
    this.tabsUpdated = function(tabs) {};
    this.clientClaimed = function(client) {};
    this.clientSeen = function(client) {};
    this.clientRemoved = function(client) {};
    this.browserUpdated = function(browser) {};

    this.connect = function() {
        this.socket = socket = io.connect(tabulatabsServerPath);

        socket.on('connect', function() {
            socket.emit('login', {
                username: username,
                password: password,
                categories: categories
            }, function(result) {
                if (result.success) {
                    self.connected();
                } else {
                    self.connectionError();
                }
            });
        });

        socket.on('tabsReplaced', function(response) {
            var tabs = $.map(response.tabs, function(encryptedTab) {
                return new TabulatabsTab(encryption.decrypt(encryptedTab));
            });
            self.tabsReplaced(tabs);
        });

        socket.on('tabsUpdated', function(response) {
            var tabs = $.map(response.tabs, function(encryptedTab) {
                return new TabulatabsTab(encryption.decrypt(encryptedTab));
            });
            self.tabsUpdated(tabs);
        });

        socket.on('claimClient', function(response) {
            var client = new TabulatabsClient(encryption);
            client.fromData(response.client);
            self.clientClaimed(client);
        });

        socket.on('clientSeen', function(response) {
            var client = new TabulatabsClient(encryption);
            client.fromData(response.client);
            self.clientSeen(client);
        });

        socket.on('clientRemoved', function(response) {
            var client = new TabulatabsClient(encryption);
            client.fromData(response.client);
            self.clientRemoved(client);
        });

        socket.on('browserUpdated', function(response) {
            var browser = new TabulatabsBrowser(encryption);
            browser.fromData(response.browser);
            self.browserUpdated(browser);
        });

        return this;
    }
}