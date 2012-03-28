
function registeredClients() {
	var browser = thisBrowser();

	browser.loadClients(function() {
		if ($('#clients>li').length != browser.clients.length) {
			$('#clients').empty();

			$.each(browser.clients, function(i, client){
				var li = $('<li>').text(client.label);
				li.css('background-image', 'url(' + client.iconURL + ')');
				var deleteLink = $('<a>').text('Delete').addClass('delete');
				deleteLink.click(function() {
					if (window.confirm('Are you sure you want to revoke access for the client "' + client.label + '"?' + "\n\n" + 'This device wont be able to access the tablist of this browser anymore.')) {

						browser.destroyClient(client, function() {
							li.remove();
						});
					}
				});

				li.append(deleteLink);

				$('#clients').prepend(li);
			});
		}
		window.setTimeout(function() { registeredClients() }, 3000);
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

$().ready(function() {
    var client = thisBrowser().newClient();

    client.createWithBrowser(thisBrowser(), thisBrowser().encryption.generatePassword(), function() {
		console.log(client.registrationURL());
		console.log(JSON.stringify(client.encryption.encrypt({message: 'Hello', recipient: 'world'})));
        drawQrCode(client.registrationURL(), 1, $('#qrCode')[0]);
    });

    prefillProperties();
	registeredClients();

	$('#propertiesForm').bind('submit', function() {
		var browser = thisBrowser();

		browser.label = $('#label').val();
		browser.description = $('#description').val();
		$('#save').attr('disabled', 'disabled');
		browser.update(function() {
			$('#save').attr("disabled", null);
		});

		return false;
	});
});
