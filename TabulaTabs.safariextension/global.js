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

function isSafari() {
	return typeof(safari) != 'undefined';
}

function isChrome() {
	return typeof(chrome) != 'undefined';
}

if (isSafari()) {
	safari.application.addEventListener("popover", function(e) {
		if (e.target.identifier == 'syncPopover') {
			collectAllTabs();
			$popover('p#options').click(function() {
				openOptions();
			});
		};
	}, true);
};

function iconAnimation(path, imageCount) {
	var i = 0;
	return window.setInterval(function() {
		i++;
		if(i > imageCount) i = 1;
		if (isSafari()) {
			safari.extension.toolbarItems[0].image = safari.extension.baseURI + path + '/' + i + '.png';
		};

		if (isChrome()) {
			chrome.browserAction.setIcon({path: path + '/' + i + '.png'});
		};

	}, 50);
}

var progressAnimation;
var syncInProgress = false;

function startProgressAnimation() {
	syncInProgress = true;
	if (isSafari()) {
		$popover('p#progress').addClass('inprogress').text('Synchronizing tabs');
		progressAnimation = iconAnimation('chasingArrows', 8);
	} else if (isChrome()) {
    	progressAnimation = iconAnimation('chasingArrows', 8);
	};
}

function stopProgressAnimation() {
	syncInProgress = false;
	if (isSafari()) {
		$popover('p#progress').removeClass('inprogress').text('Synchronization complete');
		window.clearTimeout(progressAnimation);
		safari.extension.toolbarItems[0].image = safari.extension.baseURI + 'icon-safari.png';

		window.setTimeout(function() {
			safari.extension.popovers[0].hide();
		}, 10000);
	} else {
		window.clearTimeout(progressAnimation);
		chrome.browserAction.setIcon({path: 'icon-chrome.png'});
        
        $.each(chrome.extension.getViews(), function(index, view) {
        	if (view.document.onTabsSaved) {
        		view.document.onTabsSaved();
        	}
        });
	}
}

function $popover(el) {
	return safari.extension.popovers[0].contentWindow.$(el);
}

function favIconColorsForTabulatab(tabulatab) {
	console.dir(tabulatab);
	if (tabulatab.favIconURL) {
		var favIconURL = tabulatab.favIconURL;

		if (isChrome()) {
			favIconURL = 'chrome://favicon/' + tabulatab.URL;
		};

		console.log(favIconURL);

		imageColors(favIconURL, function(colors, totalPixelCount) {
			var colorPalette = [];
			for(var i = 0; i < Math.min(5, colors.length); i++) {
				colorPalette.push([colors[i].red, colors[i].green, colors[i].blue]);
			}

			tabulatab.colorPalette = colorPalette;
		});
	}
}

function tabulatabForTab(tab, id) {
	if (!tab.url) {
		return null;
	}

	if (!tab.url.match(/^https?:\/\//)) {
		return null;
	}

	var tabulatab = {
		identifier: id,
		title: tab.title,
		URL: tab.url,
		favIconURL: tab.favIconUrl
	};

	findMetaInPageTitle(tabulatab);

	if (isSafari()) {
		var messageListener = function(msgEvent) {
			tab.removeEventListener('message', messageListener);			

			$.extend(tabulatab, msgEvent.message.collection);

			favIconColorsForTabulatab(tabulatab);
		};

		tab.addEventListener('message', messageListener, false);
		tab.page.dispatchMessage('collectMeta', {tabId: id});		
	};

	if (isChrome()) {
		favIconColorsForTabulatab(tabulatab);

		chrome.tabs.sendRequest(tab.id, {method: 'collectMeta'}, function(collection) {
			if (collection == undefined) {
				// try injecting the javascript if it was not injected during the loading of the page
				chrome.tabs.executeScript(tab.id, {file: "js/content-script.js"}, function() {
					chrome.tabs.sendRequest(tab.id, {method: 'tabinfo'}, function(collection) {
						$.extend(tabulatab, collection);
					});
				});
			} else {
				$.extend(tabulatab, collection);
			}
		});
	}


	return tabulatab;
}

function collectAllTabs() {
	if (syncInProgress) {
		return;
	};

	startProgressAnimation();
	var tabulatabs = [];
	var id = 0;

	if (isChrome()) {
		chrome.windows.getAll({populate: true}, function(chromeWindows) {
			$.each(chromeWindows, function(index, chromeWindow) {
				if (!chromeWindow.incognito && chromeWindow.type == 'normal') {
					$.each(chromeWindow.tabs, function(index, chromeTab) {
						var tabulatab = tabulatabForTab(chromeTab, chromeTab.id);
						if (tabulatab) {
							tabulatab.windowFocused = chromeWindow.focused;
							tabulatab.windowId = chromeTab.windowId;
							tabulatabs.push(tabulatab);
						}
					});
				}
			});
		});
	}

	if (isSafari()) {
		$.each(safari.application.browserWindows, function(i, browserWindow) {
			var isActiveWindow = browserWindow == safari.application.activeBrowserWindow;
			var windowId = 'window' + i;
	
			$.each(browserWindow.tabs, function(j, tab) {
				var isActiveTab = tab == browserWindow.activeTab;
	
				var tabulatab = tabulatabForTab(tab, id++);
				if (tabulatab) {
					tabulatab.selected = isActiveTab;
					tabulatab.windowFocused = isActiveWindow;
					tabulatab.index = j;
					tabulatab.windowId = windowId;
	
					tabulatabs.push(tabulatab);
				};
			});
		});
	}

	window.setTimeout(function() {
		thisBrowser().whenReady(function() {
			thisBrowser().saveTabs(tabulatabs, function() {
				stopProgressAnimation();
	        }, function() {
	        	stopProgressAnimation();
	        });
		});
	}, 2000);
}

function openOptions(firstTime) {
	var url = "options.html";
	if (firstTime)
		url += "?firstTime=true";

	if (isSafari()) {
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

	if (isChrome()) {
		var fullUrl = chrome.extension.getURL(url);
		chrome.tabs.getAllInWindow(null, function(tabs) {
			for (var i in tabs) { // check if Options page is open already
				var tab = tabs[i];
				if (tab.url == fullUrl || tab.url.substring(0, fullUrl.length) == fullUrl) {
					chrome.tabs.update(tab.id, { selected: true }); // select the tab
					return;
				}
			}
			chrome.tabs.getSelected(null, function(tab) { // open a new tab next to currently selected tab
				chrome.tabs.create({
					url: url,
					index: tab.index + 1
				});
			});
		});
	}
}

thisBrowser(function() {
	thisBrowser().loadClients(function() {
	    if (thisBrowser().clients.length == 0) {
	        openOptions(true);
	    }
	});
});

window.setTimeout(function() {
	collectAllTabs();
}, 10000);
