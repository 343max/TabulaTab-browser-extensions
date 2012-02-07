var tabulatabs = new Tabulatabs('Chrome');

$().ready(function() {
	drawQrCode(tabulatabs.clientRegistrationUrl(), 1, $('#qrCode')[0]);
});