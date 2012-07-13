function TabulatabsSocketIo(username, password, categories) {
    if (!categories) categories = ['tabs', 'clients', 'browsers'];

    var socket = io.connect(tabulatabsServerPath);

    socket.on('connect', function() {
        console.log('connect');
        socket.emit('login', {
            username: username,
            password: password,
            categories: ['tabs', 'clients', 'browsers']
        }, function(result) {
            console.dir(result);
        });
    });

    socket.on('tabsReplaced', function(data) {
        console.dir({ tabsReplaced: data });
    });

    socket.on('tabsUpdated', function(data) {
        console.dir({ tabsUpdated: data });
    });

    socket.on('claimClient', function(data) {
        console.dir({ claimClient: data });
    });

    socket.on('clientSeen', function(data) {
        console.dir({ clientSeen: data });
    });

    socket.on('clientRemoved', function(data) {
        console.dir({ clientRemoved: data });
    });

    socket.on('browserUpdated', function(data) {
        console.dir({ browserUpdated: data });
    });
}