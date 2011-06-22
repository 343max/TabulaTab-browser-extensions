var tabulatabs = new TabulatabsClient('TabulaTabsChromeExtension');

$().ready(function() {
	drawQrCode(tabulatabs.clientRegistrationUrl(), 1, $('#qrCode')[0]);
});