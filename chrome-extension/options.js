var tabulatabs = new TabulatabsClient('Chrome');

$().ready(function() {
	drawQrCode(tabulatabs.clientRegistrationUrl(), 1, $('#qrCode')[0]);
});