if (isSafari()) {
	safari.application.addEventListener("popover", function(e) {
		if (e.target.identifier == 'syncPopover') {
            forceTabSync(true);
			$popover('p#options').unbind().click(function() {
                console.log('click!');
                openOptions();
				safari.extension.popovers[0].hide();
			});
		}
	}, true);
}

if (isSafari()) {
	safari.extension.settings.addEventListener("change", function (e) {
		if (e.key === 'showOptionsCheckbox' && safari.extension.settings.showOptionsCheckbox === true) {
			openOptions();
			safari.extension.settings.showOptionsCheckbox = false;
		};
	}, false);
}

function iconAnimation(path, imageCount) {
	var i = 0;
	return window.setInterval(function() {
		i++;
		if(i > imageCount) i = 1;
		if (isSafari()) {
			safari.extension.toolbarItems[0].image = safari.extension.baseURI + path + '/' + i + '.png';
		}

		if (isChrome()) {
			chrome.browserAction.setIcon({path: path + '/' + i + '.png'});
		}

	}, 75);
}

var progressAnimation;
var syncInProgress = false;

function startProgressAnimation() {
	syncInProgress = true;
	if (isSafari()) {
		$popover('p#progress').addClass('inprogress').text('Synchronizing tabs');
	}
	progressAnimation = iconAnimation('img/chasingArrows', 6);
}

function stopProgressAnimation() {
	syncInProgress = false;
	if (isSafari()) {
		$popover('p#progress').removeClass('inprogress').text('Synchronization complete');
		window.clearTimeout(progressAnimation);
		safari.extension.toolbarItems[0].image = safari.extension.baseURI + 'img/toolbar-icon-safari.png';

		window.setTimeout(function() {
			safari.extension.popovers[0].hide();
		}, 10000);
	} else {
		window.clearTimeout(progressAnimation);
		chrome.browserAction.setIcon({path: 'img/toolbar-icon-chrome.png'});
        
        $.each(chrome.extension.getViews(), function (index, view) {
        	if (view.document.onTabsSaved) {
        		view.document.onTabsSaved();
            }
        });
	}
}

function $popover(el) {
	return safari.extension.popovers[0].contentWindow.$(el);
}

function favIconColorsForTabulatab(tabulatab, next) {
	if (tabulatab.favIconURL) {
		var favIconURL = tabulatab.favIconURL;

		if (isChrome()) {
			favIconURL = 'chrome://favicon/' + tabulatab.URL;
		}

		imageColors(favIconURL, function(colors, totalPixelCount) {
			var colorPalette = [];
			for(var i = 0; i < Math.min(5, colors.length); i++) {
				colorPalette.push([colors[i].red, colors[i].green, colors[i].blue]);
			}

			tabulatab.colorPalette = colorPalette;

            if (next) next();
		});
	}
}


var uploadTabTimout = null;

var needsCompleteUpload = false;
function startUploadTabsTimeout(forceUpload) {
    if (forceUpload) needsCompleteUpload = true;

    thisBrowser().whenReady(function() {
        if (thisBrowser().streamingEnabled()) {
            if (uploadTabTimout != null) {
                return;
            }

            uploadTabTimout = window.setTimeout(function() {
                collectAllTabs(needsCompleteUpload);
                uploadTabTimout = null;
                needsCompleteUpload = false;
            }, 5000);
        }
    });
}

function updateTabs() {
    thisBrowser().whenReady(function() {
        if (thisBrowser().streamingEnabled()) {
            collectAllTabs(false);
        }
    });
}

if (isChrome()) {
	chrome.tabs.onAttached.addListener(function(tabId, attachInfo) {
		startUploadTabsTimeout(true);
	});

	chrome.tabs.onCreated.addListener(function(tab) {
        startUploadTabsTimeout(true);
	});

	chrome.tabs.onMoved.addListener(function(tabId, moveInfo) {
		startUploadTabsTimeout(false);
	});

	chrome.tabs.onRemoved.addListener(function(tabId) {
        invalidateTabulaTab(tabId);
        startUploadTabsTimeout(true);
	});

	chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
        startUploadTabsTimeout(false);
	});

	chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
        if (changeInfo.status == 'complete') {
            invalidateTabulaTab(tabId);
            startUploadTabsTimeout(false);
        }
	});
};

if (isSafari()) {
	safari.application.addEventListener('open', function(e) {
        startUploadTabsTimeout(true);
	}, true);

	safari.application.addEventListener('close', function(e) {
        startUploadTabsTimeout(true);
	}, true);

	safari.application.addEventListener('activate', function(e) {
        startUploadTabsTimeout(false);
	}, true);

	safari.application.addEventListener('navigate', function(e) {
        invalidateTabulaTab(e.target.id);
        startUploadTabsTimeout(false);
	}, true);
};

function openOptions(firstTime) {
	var url = "options.html";
	if (firstTime)
		url += "?firstTime=true";

    if (isSafari()) {
        var fullUrl = safari.extension.baseURI + url;
        var tabFound = false;

        $.each(safari.application.browserWindows, function(i, browserWindow) {
            $.each(browserWindow.tabs, function(i, tab) {
                if (tab.url == fullUrl) {
                    tabFound = true;
                    tab.browserWindow.activate();
                    tab.activate();
                }
            });
        });

        if (tabFound) {
            return;
        };

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
        tab.addEventListener('message', function() {
            thisBrowser().whenReady(function() {
                tab.page.dispatchMessage('settings', {
                    key: thisBrowser().encryption.hexKey(),
                    username: thisBrowser().username,
                    password: thisBrowser().password,
                    apiEndpoint: tabulatabsServerPath
                }, false);
            });
        }, false);
        win.activate();
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

thisBrowser().whenReady(function() {
    window.setTimeout(function() {
        collectAllTabs(true);
    }, 5000);

    if (settingsStorage.getItem('installed') != 'true') {
		settingsStorage.setItem('installed', 'true');
		openOptions(true);
	};
});

function totalReset() {
	settingsStorage.removeItem('installed');
	settingsStorage.removeSecureItem('key');
	settingsStorage.removeSecureItem('username');
	settingsStorage.removeSecureItem('password');
}