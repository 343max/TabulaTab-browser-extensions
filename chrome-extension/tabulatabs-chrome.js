function iconAnimation(path, imageCount) {
	var i = 0;
	return window.setInterval(function() {
		i++;
		if(i > imageCount) i = 1;
		chrome.browserAction.setIcon({path: path + '/' + i + '.png'});
	}, 50);
}

function tabulatabForTab(tab) {
	var tabulatab = {
		identifier: tab.id,
		title: tab.title,
		URL: tab.url,
		selected: tab.selected,
		favIconURL: tab.favIconUrl,
		windowId: tab.windowId,
		windowFocused: false,
		index: tab.index
	};

	findMetaInPageTitle(tabulatab);

	if (tab.favIconUrl) {
		imageColors('chrome://favicon/' + tab.url, function(colors, totalPixelCount) {
			var colorPalette = [];
			for(var i = 0; i < Math.min(5, colors.length); i++) {
				colorPalette.push([colors[i].red, colors[i].green, colors[i].blue]);
			}

			tabulatab.colorPalette = colorPalette;
		});
	}

	chrome.tabs.sendRequest(tab.id, {method: 'collectMeta'}, function(collection) {
		if (collection == undefined) {
			// try injecting the javascript if it was not injected during the loading of the page
			chrome.tabs.executeScript(tab.id, {file: "js-shared/content-script.js"}, function() {
				chrome.tabs.sendRequest(tab.id, {method: 'tabinfo'}, function(collection) {
					$.extend(tabulatab, collection);
				});
			});
		} else {
			$.extend(tabulatab, collection);
		}
	});

	return tabulatab;
}

function collectAllTabs() {
	var animation = iconAnimation('chasingArrows', 8);

	var tabs = [];

	chrome.windows.getAll({populate: true}, function(chromeWindows) {
		$.each(chromeWindows, function(index, chromeWindow) {
			if (!chromeWindow.incognito && chromeWindow.type == 'normal') {
				$.each(chromeWindow.tabs, function(index, chromeTab) {
					var tabulatab = tabulatabForTab(chromeTab);
					if (tabulatab) {
						tabulatab.windowFocused = chromeWindow.focused;
						tabs.push(tabulatab);
					}
				});
			}
		});
		window.setTimeout(function() {
	        thisBrowser().saveTabs(tabs, function() {
	            window.clearTimeout(animation);
				chrome.browserAction.setIcon({path: 'icon.png'});
	            
	            $.each(chrome.extension.getViews(), function(index, view) {
	            	if (view.document.onTabsSaved) {
	            		view.document.onTabsSaved();
	            	}
	            });
	        }, function() {
	            window.clearTimeout(animation);
				chrome.browserAction.setIcon({path: 'icon.png'});	        	
	        });
		}, 1500);
	});
}

var uploadTabTimout = null;

function startUploadTabsTimeout() {

	if(uploadTabTimout != null) window.clearTimeout(uploadTabTimout);

	uploadTabTimout = window.setTimeout(function() {
		collectAllTabs();
		uploadTabTimout = null;
	}, 90000);

}

collectAllTabs();

chrome.tabs.onAttached.addListener(function(tabId, attachInfo) {
	startUploadTabsTimeout();
});

chrome.tabs.onCreated.addListener(function(tab) {
	startUploadTabsTimeout();
});

chrome.tabs.onMoved.addListener(function(tabId, moveInfo) {
//	console.log('onMoved');console.dir(moveInfo);
	startUploadTabsTimeout();
});

chrome.tabs.onRemoved.addListener(function(tabId) {
//	console.log('onRemoved');console.dir(tabId);
	startUploadTabsTimeout();
});

chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
//	console.log('onSelectionChanged');console.dir(selectInfo);
	startUploadTabsTimeout();
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
//	console.log('onUpdated');console.dir(changeInfo);
	startUploadTabsTimeout();
});

startUploadTabsTimeout();

function openOptions(firstTime) {
	var url = "options.html";
	if (firstTime)
		url += "?firstTime=true";

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

if(thisBrowser(function() {
	openOptions(true);
}).loadClients(function() {
    if (thisBrowser().clients.length == 0) {
        openOptions(true);
    }
}));
