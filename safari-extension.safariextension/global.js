// SafariActivateEvent / activate
// SafariOpenEvent / open
// SafariNavigateEvent / navigate
// SafariDeactivateEvent / deactivate
// SafariCloseEvent / close

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
		$popover('p#options').click(function() {
			console.log('click!');
			openOptions();
		});
	};
}, true);

function iconAnimation(path, imageCount) {
	var i = 0;
	return window.setInterval(function() {
		i++;
		if(i > imageCount) i = 1;
		safari.extension.toolbarItems[0].image = safari.extension.baseURI + path + '/' + i + '.png';
	}, 50);
}

var progressAnimation;

function startProgressAnimation() {
	$popover('p#progress').addClass('inprogress').text('Synchronizing tabs');
	progressAnimation = iconAnimation('chasingArrows', 8);
}

function stopProgressAnimation() {
	$popover('p#progress').removeClass('inprogress').text('Synchronization complete');
	window.clearTimeout(progressAnimation);
	safari.extension.toolbarItems[0].image = safari.extension.baseURI + 'icon.png';

	window.setTimeout(function() {
		safari.extension.popovers.syncPopover.hide();
	}, 10000);
}

function $popover(el) {
	return safari.extension.popovers.syncPopover.contentWindow.$(el);
}

function tabulatabForTab(tab, id) {
	if (!tab.url) {
		return null;
	}

	var tabulatab = {
		identifier: id,
		title: tab.title,
		URL: tab.url
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
	startProgressAnimation();
	var tabulatabs = [];
	var id = 0;

	$.each(safari.application.browserWindows, function(i, browserWindow) {
		var isActiveWindow = browserWindow == safari.application.activeBrowserWindow;

		$.each(browserWindow.tabs, function(j, tab) {
			var isActiveTab = tab == browserWindow.activeTab;

			var tabulatab = tabulatabForTab(tab, id++);
			if (tabulatab) {
				tabulatab.selected = isActiveTab;
				tabulatab.windowFocused = isActiveWindow;
				tabulatab.index = j;

				tabulatabs.push(tabulatab);
			};
		});
	});

	window.setTimeout(function() {
		console.dir(tabulatabs);
		stopProgressAnimation();
	}, 3000);
}

function openOptions(firstTime) {
	var url = "js-shared/options.html";
	if (firstTime)
		url += "?firstTime=true";

	var fullUrl = safari.extension.baseURI + url;

	var win;
	if (safari.application.activeBrowserWindow) {
		win = safari.application.activeBrowserWindow;
	} else if (safari.application.browserWindows.length > 0) {
		win = safari.application.browserWindows[0];
		win.activate();
	} else {
		win = safari.application.openBrowserWindow();
	}

	var tab = win.openTab();
	tab.url = fullUrl;
}

window.setTimeout(function() {
	collectAllTabs();
}, 10000);
