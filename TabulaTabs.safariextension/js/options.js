
function registerNewClient() {
    $('#addDeviceModal').modal('show');
	thisBrowser().whenReady(function() {
		var client = thisBrowser().newClient();

		client.createWithBrowser(thisBrowser(), thisBrowser().encryption.generatePassword(), function() {
			// console.log(client.registrationURL());
			drawQrCode(client.registrationURL(), 1, $('#qrCode')[0]);
			$('.sendRegistrationMail').show().attr('href', 'mailto:?body=' + escape(client.registrationURL() + ' send your self an mail with this link and open it on your iPod.'));
		});
	});
}

function listItem(client) {
    var li = $('<li>');
    li.css('background-image', 'url(' + client.iconURL + ')').attr('id', 'client_' + client.id);

    console.log(client.accessedAt);
    var a = moment(client.accessedAt);

    var left = $('<span>').addClass('left');
    left.append($('<span>').addClass('title').text(client.label));
    if (a) {
        var accessedAt = $('<span>').addClass("lastSeen").text('last seen ' + a.fromNow());
        left.append(accessedAt);
    };
    li.append(left);

    var deleteLink = $('<a>').text('Remove').addClass('delete').addClass('btn').addClass('btn-danger');
    deleteLink.click(function() {
        $('#removeClientModal .device').text(client.label);
        $('#removeClientModal .remove').unbind().click(function() {
            $('#removeClientModal').modal('hide');
            thisBrowser().destroyClient(client, function() {
                li.remove();
            });
        });
        $('#removeClientModal').modal();
    });

    li.append(deleteLink);

    return li;
}

function registeredClients() {
	var browser = thisBrowser();

	browser.loadClients(function() {
        if (browser.clients.length == 0) {
            registerNewClient();
        }

        $('#clients').empty();

        browser.clients.sort(function(a, b) {
            return a.accessedAt - b.accessedAt;
        })

        $.each(browser.clients, function(i, client){
            $('#clients').prepend(listItem(client));
        });
	});
}

function prefillProperties() {
	var browser = thisBrowser();
	browser.load(function() {
		$('#label').val(browser.label);
		$('#description').val(browser.description);
		$('#save').attr("disabled", null);
	})
}

function docReady() {

    thisBrowser().whenReady(function() {
        var socket = new TabulatabsSocketIo(thisBrowser().username,
                                            thisBrowser().password,
                                            thisBrowser().encryption.hexKey(),
                                            ['clients']).connect();

        socket.clientSeen = function(client) {
            console.log('clientSeen');
            console.dir(client);
            var span = $('#client_' + client.id + ' .lastSeen');
            var a = moment(client.accessedAt);
            if (a) span.text('last seen ' + a.fromNow());
        }

        socket.clientClaimed = function(client) {
            console.log('clientClaimed');
            console.dir(client);
            $('#addDeviceModal').modal('hide');
            window.setTimeout(function() {
                $('#clients').prepend(listItem(client));
            }, 700);
        }

        socket.clientRemoved = function(client) {
            $('#client_' + client.id).remove();
        }
    });

    $('.container').css('display', 'block');

	if (isChrome()) {
		$('.browserName').text('Chrome');
	}

	if (isSafari()) {
		$('.browserName').text('Safari');
	}

    thisBrowser().whenReady(function() {
    	var client = thisBrowser().newClient();

	    prefillProperties();
		registeredClients();

		$('#propertiesForm').bind('submit', function() {
			var browser = thisBrowser();

			browser.label = $('#label').val();
			browser.description = $('#description').val();
			$('#save').attr('disabled', 'disabled').val('Saving…');
			browser.update(function() {
				window.setTimeout(function() {
					$('#save').attr("disabled", null).val('Save');
				}, 1500);
			});

			return false;
		});
    });

    $('.addDevice').click(function() {
    	registerNewClient();
    });
};

if (isSafari()) {
	safari.self.addEventListener("message", function(msgEvent) {
		if (msgEvent.name == 'settings') {
			var params = msgEvent.message;
			var encryption = new TabulatabsEncryption(params.key);
	        _tabulatabsCurrentBrowser = new TabulatabsBrowser(encryption);
	        _tabulatabsCurrentBrowser.username = params.username;
	        _tabulatabsCurrentBrowser.password = params.password;
	        docReady();
		};
	}, false);
	safari.self.tab.dispatchMessage('settings', null);
} else {
	$(document).ready(function($) {
		docReady();
	});
}

















