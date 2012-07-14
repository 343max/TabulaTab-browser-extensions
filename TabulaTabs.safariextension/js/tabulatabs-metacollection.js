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

var cachedTabulatabs = {};

function invalidateTabulaTab(tabIdentifier) {
    delete cachedTabulatabs[tabIdentifier];
}

function collectAllTabs(forceCompleteUpload) {
    if (syncInProgress) {
        return;
    };

    startProgressAnimation();
    var allTabulaTabs = [];
    var changedTabulaTabs = [];

    var tabsComplete = 0;
    var tabUploadStarted = false;

    var uploadTabs = function(forcedUpload) {
        if (tabUploadStarted) {
            return;
        }

        if (tabsComplete == allTabulaTabs.length || forcedUpload) {
            tabUploadStarted = true;
            thisBrowser().whenReady(function() {
                if (forceCompleteUpload) {
                    console.log('replacing ' + allTabulaTabs.length + ' tabs');
                    thisBrowser().saveTabs(allTabulaTabs, function() {
                        stopProgressAnimation();
                    }, function() {
                        stopProgressAnimation();
                    });
                } else {
                    console.log('updating ' + changedTabulaTabs.length + ' of ' + allTabulaTabs.length + ' tabs');
                    if (changedTabulaTabs.length > 0) {
                        thisBrowser().updateTabs(changedTabulaTabs, function() {
                            stopProgressAnimation();
                        }, function() {
                            stopProgressAnimation();
                        });
                    }
                }
            });
        }
    }

    var nextTabCollected = function() {
        tabsComplete++;

        uploadTabs(false);
    }

    var tabListComplete = function() {
        if (tabsComplete == allTabulaTabs.length) {
            uploadTabs(false);
        } else {
            window.setTimeout(function() {
                uploadTabs(true);
            }, 10000);
        }
    }

    if (isChrome()) {
        chrome.windows.getAll({populate: true}, function(chromeWindows) {
            $.each(chromeWindows, function(windowIndex, chromeWindow) {
                if (!chromeWindow.incognito && chromeWindow.type == 'normal') {
                    $.each(chromeWindow.tabs, function(tabIndex, chromeTab) {
                        var tabulatab = null;
                        var tabWasUpdated = false;

                        if (cachedTabulatabs[chromeTab.id]) {
                            tabulatab = cachedTabulatabs[chromeTab.id];
                            nextTabCollected();
                        } else {
                            tabulatab = tabulatabForTab(chromeTab, chromeTab.id, nextTabCollected);
                            tabWasUpdated = true;
                        }

                        if (tabulatab) {
                            if (tabulatab.windowFocused != chromeWindow.focused) tabWasUpdated = true;
                            if (tabulatab.windowId != chromeTab.windowId) tabWasUpdated = true;
                            if (tabulatab.index != chromeTab.index) tabWasUpdated = true;
                            if (tabulatab.active != chromeTab.active) tabWasUpdated = true;
                            if (tabulatab.pinned != chromeTab.pinned) tabWasUpdated = true;

                            tabulatab.windowFocused = chromeWindow.focused;
                            tabulatab.windowId = chromeTab.windowId;
                            tabulatab.index = chromeTab.index;
                            tabulatab.active = chromeTab.active;
                            tabulatab.pinned = chromeTab.pinned;

                            allTabulaTabs.push(tabulatab);

                            if (tabWasUpdated) {
                                changedTabulaTabs.push(tabulatab);
                            }

                            cachedTabulatabs[chromeTab.id] = tabulatab;
                        }
                    });
                }

                if (chromeWindows.length == windowIndex + 1) {
                    tabListComplete();
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
                    tabulatab.pinned = false;

                    allTabulaTabs.push(tabulatab);
                };
            });
        });

        tabListComplete();
    }
}
