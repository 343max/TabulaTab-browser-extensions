function tabulatabForTab(tab, next) {
    if (!tab.url) {
        return null;
    }

    if (!tab.url.match(/^https?:\/\//)) {
        return null;
    }

    var tabulatab = {
        identifier: tab.id,
        title: tab.title,
        URL: tab.url,
        favIconURL: tab.favIconUrl,
        windowId: 0
    };

    findMetaInPageTitle(tabulatab);

    if (isSafari()) {
        var messageListener = function(msgEvent) {
            tab.removeEventListener('message', messageListener);

            $.extend(tabulatab, msgEvent.message.collection);

            favIconColorsForTabulatab(tabulatab, next);
        };

        tab.addEventListener('message', messageListener, false);
        tab.page.dispatchMessage('collectMeta', {tabId: tab.id});
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

var nextIdenitifier = 1;
var identifierCache = {};

function injectId(object) {
    var hadId = true;

    if (!identifierCache[object]) {
        identifierCache[object] = nextIdenitifier++;
        hadId = false;
    }
    var id = identifierCache[object];
    object.id = id;

    return hadId;
}

var currentUploadConnection = null;

function forceTabSync() {
    if (currentUploadConnection) {
        currentUploadConnection.abort();
    }
    syncInProgress = false;
    collectAllTabs(true);
}

function collectAllTabs(forceCompleteUpload) {
    console.log('started collection of tabs, forceCompleteUpload: ' + forceCompleteUpload);
    if (syncInProgress) {
        return;
    };

    if (forceCompleteUpload) {
        cachedTabulatabs = {};
    }

    startProgressAnimation();
    var allTabulaTabs = [];
    var changedTabulaTabs = [];

    var tabsWithCompleteInformation = 0;
    var tabUploadStarted = false;
    var listsOfTabsAreComplete = false;

    var uploadTabs = function(forcedUpload) {
        if (tabUploadStarted) {
            return;
        }

        if (tabsWithCompleteInformation == allTabulaTabs.length || forcedUpload) {
            tabUploadStarted = true;
            thisBrowser().whenReady(function() {
                if (forceCompleteUpload) {
                    console.log('replacing ' + allTabulaTabs.length + ' tabs');
                    currentUploadConnection = thisBrowser().saveTabs(allTabulaTabs, function() {
                        console.log('upload complete');
                        currentUploadConnection = null;
                        stopProgressAnimation();
                    }, function() {
                        console.log('error!');
                        currentUploadConnection = null;
                        stopProgressAnimation();
                    });
                } else {
                    console.log('updating ' + changedTabulaTabs.length + ' of ' + allTabulaTabs.length + ' tabs');
                    if (changedTabulaTabs.length > 0) {
                        currentUploadConnection = thisBrowser().updateTabs(changedTabulaTabs, function() {
                            console.log('upload complete');
                            currentUploadConnection = null;
                            stopProgressAnimation();
                        }, function() {
                            console.log('error!');
                            currentUploadConnection = null;
                            stopProgressAnimation();
                        });
                    }
                }
            });
        }
    }

    var nextTabCollected = function() {
        tabsWithCompleteInformation++;

        if (listsOfTabsAreComplete) {
            uploadTabs(false);
        }
    }

    var tabListComplete = function() {
        listsOfTabsAreComplete = true;

        if (tabsWithCompleteInformation == allTabulaTabs.length) {
            uploadTabs(false);
        } else {
            window.setTimeout(function() {
                console.log('timeout...');
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
                            tabulatab = tabulatabForTab(chromeTab, nextTabCollected);
                            tabWasUpdated = true;
                        }

                        if (tabulatab) {
                            if (tabulatab.windowFocused != chromeWindow.focused) tabWasUpdated = true;
                            if (tabulatab.windowId != chromeTab.windowId) tabWasUpdated = true;
                            if (tabulatab.index != chromeTab.index) tabWasUpdated = true;
                            if (tabulatab.selected != chromeTab.active) tabWasUpdated = true;
                            if (tabulatab.pinned != chromeTab.pinned) tabWasUpdated = true;

                            tabulatab.windowFocused = chromeWindow.focused;
                            tabulatab.windowId = chromeTab.windowId;
                            tabulatab.index = chromeTab.index;
                            tabulatab.selected = chromeTab.active;
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
        for (var i = 0; i < safari.application.browserWindows.length; i++) {
            var browserWindow = safari.application.browserWindows[i];
            var isActiveWindow = browserWindow == safari.application.activeBrowserWindow;

            if (!injectId(browserWindow)) {
                console.log('forcing upload because window has no id');
                forceCompleteUpload = true;
            }

            for (var j = 0; j < browserWindow.tabs.length; j++) {
                var tab = browserWindow.tabs[j];

                var isActiveTab = tab == browserWindow.activeTab;

                if (!injectId(tab)) {
                    console.log('forcing upload because tab has no id');
                    forceCompleteUpload = true;
                }

                var tabWasUpdated = false;
                var tabulatab = null;

                if (cachedTabulatabs[tab]) {
                    tabulatab = cachedTabulatabs[tab];
                    nextTabCollected();
                } else {
                    console.log('creating new tabulatabs');
                    tabulatab = tabulatabForTab(tab, nextTabCollected);
                    tabWasUpdated = true;
                }

                if (tabulatab) {
                    if (tabulatab.windowFocused != isActiveWindow) tabWasUpdated = true;
                    if (tabulatab.windowId != browserWindow.id) tabWasUpdated = true;
                    if (tabulatab.index != j) tabWasUpdated = true;
                    if (tabulatab.selected != isActiveTab) tabWasUpdated = true;

                    tabulatab.selected = isActiveTab;
                    tabulatab.windowFocused = isActiveWindow;
                    tabulatab.index = j;
                    tabulatab.windowId = browserWindow.id;
                    tabulatab.pinned = false;

                    allTabulaTabs.push(tabulatab);
                    if (tabWasUpdated) {
                        changedTabulaTabs.push(tabulatab);
                    }

                    cachedTabulatabs[tab] = tabulatab;
                };
            }
        }

        console.log('tab list complete');
        tabListComplete();
    }
}
