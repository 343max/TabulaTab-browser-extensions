var tabulatabs = new TabulatabsClient('TabulaTabsChromeExtension');

function refresh() {
	if(!tabulatabs.loggedIn()) {
		$('#unlocked').hide();
		$('#locked').show();
	} else {
		$('#unlocked').show();
		$('#locked').hide();

		$('#data').text(JSON.stringify(tabulatabs.getTabs()));
	}
}

$().ready(function() {
	refresh();
});

$('#logout').live('click', function() {
	tabulatabs.logout();
	refresh();
	return false;
})

$('#login').live('submit', function(e) {
	e.preventDefault();

	var $this = $(this);

	tabulatabs.login($this.find('[name=username]').val());

	refresh();
	return false;
});

$('#changeEncryptionPassword').live('submit', function(e) {
	e.preventDefault();

	var $this = $(this);

	var passwd1 = $this.find('#passwd1');
	var passwd2 = $this.find('#passwd2');

	var val1 = passwd1.val();
	var val2 = passwd2.val();

	passwd1.val('');
	passwd2.val('');

	if(val1 != val2) {
		alert('Please enter the same password twice');
		passwd1.focus();
		return;
	}

	tabulatabs.setEncryptionPassword(val1);

	alert('Password changed!');
});