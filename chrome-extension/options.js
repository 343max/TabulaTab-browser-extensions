
function registeredClients() {
	
}

$().ready(function() {
    var client = thisBrowser().newClient();

    client.createWithBrowser(thisBrowser(), thisBrowser().encryption.generatePassword(), function() {
		console.log(client.registrationURL());
		console.log(JSON.stringify(client.encryption.encrypt({message: 'Hello', recipient: 'world'})));
        drawQrCode(client.registrationURL(), 1, $('#qrCode')[0]);
    })
});
