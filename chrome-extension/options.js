$().ready(function() {
    var client = thisBrowser().newClient();

    client.createWithBrowser(thisBrowser(), thisBrowser().encryption.generatePassword(), function() {
		console.log(client.registrationURL());
        drawQrCode(client.registrationURL(), 1, $('#qrCode')[0]);
    })
});

function loadTabs() {
    var client = thisBrowser().newClient();

    client.createWithBrowser(thisBrowser(), thisBrowser().encryption.generatePassword(), function() {
       client.claim(client.claimingPassword, thisBrowser().encryption.generatePassword(), function() {
          client.loadTabs(function() {
             console.dir(client.tabs);
          });
       });
    });
}