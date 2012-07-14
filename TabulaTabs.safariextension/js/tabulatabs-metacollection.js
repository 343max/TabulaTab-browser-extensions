function tabulatabForTab(tab, id, next) {
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

            favIconColorsForTabulatab(tabulatab, next);
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
                        next();
                    });
                });
            } else {
                $.extend(tabulatab, collection);
                next();
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

    var tabsComplete = 0;

    var nextTabCollected = function(forceCompletion) {
        tabsComplete++;
        console.log('Tab ' + tabsComplete + ' of ' + tabulatabs.length);

        if (forceCompletion || tabsComplete == tabulatabs.length) {
            console.log('uploading...');
            thisBrowser().whenReady(function() {
                thisBrowser().saveTabs(tabulatabs, function() {
                    stopProgressAnimation();
                }, function() {
                    stopProgressAnimation();
                });
            });
        }
    }

    if (isChrome()) {
        chrome.windows.getAll({populate: true}, function(chromeWindows) {
            $.each(chromeWindows, function(index, chromeWindow) {
                if (!chromeWindow.incognito && chromeWindow.type == 'normal') {
                    $.each(chromeWindow.tabs, function(index, chromeTab) {
                        var tabulatab = tabulatabForTab(chromeTab, chromeTab.id, nextTabCollected);
                        if (tabulatab) {
                            tabulatab.windowFocused = chromeWindow.focused;
                            tabulatab.windowId = chromeTab.windowId;
                            tabulatab.index = chromeTab.index;
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

                if (!tab.id) {
                    tab.id = nextTabIdenitifier++;
                }

                var tabulatab = tabulatabForTab(tab, tab.id, nextTabCollected);
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
        nextTabCollected(true);
    }, 10000);
}
