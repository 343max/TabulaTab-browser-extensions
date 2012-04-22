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
		collectAllTabs();
	};
}, true);

function tabulatabForTab(tab, id) {
	var tabulatab = {
		identifier: id,
		title: tab.title,
		URL: tab.url
		// selected: tab.selected,
		// favIconURL: tab.favIconUrl,
		// windowId: tab.windowId,
		// windowFocused: false,
	};

	findMetaInPageTitle(tabulatab);

	var messageListener = function(msgEvent) {
		tab.removeEventListener('message', messageListener);

		$.extend(tabulatab, msgEvent.message.collection);
		// console.dir(msgEvent);

		if (tabulatab.favIconUrl) {
			imageColors(tabulatab.favIconUrl, function(colors, totalPixelCount) {
				var colorPalette = [];
				for(var i = 0; i < Math.min(5, colors.length); i++) {
					colorPalette.push([colors[i].red, colors[i].green, colors[i].blue]);
				}

				tabulatab.colorPalette = colorPalette;
			});
		}
	};
	tab.addEventListener('message', messageListener, false);

	tab.page.dispatchMessage('collectMeta', {tabId: id});

	return tabulatab;
}

function collectAllTabs() {
	var tabulatabs = [];
	var id = 0;

	$.each(safari.application.browserWindows, function(i, browserWindow) {
		var isActiveWindow = browserWindow == safari.application.activeBrowserWindow;

		$.each(browserWindow.tabs, function(j, tab) {
			var isActiveTab = tab == browserWindow.activeTab;

			var tabulatab = tabulatabForTab(tab, id++);

			tabulatab.selected = isActiveTab;
			tabulatab.windowFocused = isActiveWindow;
			tabulatab.index = j;

			tabulatabs.push(tabulatab);
		});
	});

	window.setTimeout(function() {
		console.dir(tabulatabs);
	}, 3000);
}

window.setTimeout(function() {
	collectAllTabs();
}, 10000);
