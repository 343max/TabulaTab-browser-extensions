// SafariActivateEvent / activate
// SafariOpenEvent / open
// SafariNavigateEvent / navigate
// SafariDeactivateEvent / deactivate
// SafariCloseEvent / close

// SafariExtensionMessageEvent / message https://developer.apple.com/library/safari/#documentation/UserExperience/Reference/ExtensionMessageClassRef/SafariExtensionMessage/SafariExtensionMessage.html#//apple_ref/doc/uid/TP40009785
// SafariCommandEvent / command / https://developer.apple.com/library/safari/#documentation/UserExperience/Reference/SafariExtensionCommandEventClassRef/SafariCommandEvent/SafariCommandEvent.html#//apple_ref/doc/uid/TP40009892

// safari.application.addEventListener('open', function(e) {
// 	console.dir(['open', e]);
// }, true);

// safari.application.addEventListener('close', function(e) {
// 	console.dir(['close', e]);
// }, true);

// safari.application.addEventListener('activate', function(e) {
// 	console.dir(['activate', e]);
// }, true);

// safari.application.addEventListener('beforeNavigate', function(e) {
// 	console.dir(['beforeNavigate', e]);
// }, true);

safari.application.addEventListener("popover", function(e) {
	if (e.target.identifier == 'syncPopover') {
		startTabSync();
	};
}, true);

function startTabSync() {
	console.log('startTabSync');
}