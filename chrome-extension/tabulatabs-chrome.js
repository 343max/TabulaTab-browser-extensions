var pageMetaInfo;
try {
	pageMetaInfo = JSON.parse(localStorage.getItem('pageMetaInfo'));
} catch(e) {}
if (!pageMetaInfo) pageMetaInfo = {};

function savePageMeta() {
	localStorage.setItem('pageMetaInfo', JSON.stringify(pageMetaInfo));
}

function getPageMetaProperty(url, key) {
	if (!pageMetaInfo[url]) return null;
	return pageMetaInfo[url][key];
}

function setPageMetaProperty(url, key, value) {
	if (!pageMetaInfo[url]) pageMetaInfo[url] = {};
	pageMetaInfo[url][key] = value;
    console.log('pageMetaInfo.length: ' + Object.keys(pageMetaInfo).length);
	savePageMeta();
}

function deletePageMeta(url) {
	delete pageMetaInfo[url];
	savePageMeta();
}

function iconAnimation(path, imageCount) {
	var i = 0;
	return window.setInterval(function() {
		i++;
		if(i > imageCount) i = 1;
		chrome.browserAction.setIcon({path: path + '/' + i + '.png'});
	}, 50);
}

function tabulatabForTab(tab) {
	if (!tab.url.match(/^https?:\/\//)) {
		return null;
	}

	var tabulatab = {
		identifier: tab.id,
		title: tab.title,
		URL: tab.url,
		selected: tab.selected,
		favIconURL: tab.favIconUrl,
		windowId: tab.windowId,
		index: tab.index,
		colorPalette: getPageMetaProperty(tab.url, 'colorPalette')
	};

	findMetaInPageTitle(tabulatab);

	chrome.tabs.sendRequest(tab.id, {method: 'tabinfo'}, function(collection) {
		$.extend(tabulatab, collection);
	})

	return tabulatab;
}

function collectAllTabs() {
	console.log('started uploading');

	var animation = iconAnimation('chasingArrows', 8);

	var tabs = [];

	chrome.windows.getAll({populate: true}, function(chromeWindows) {
		$.each(chromeWindows, function(index, chromeWindow) {
			if (!chromeWindow.incognito) {

				$.each(chromeWindow.tabs, function(index, chromeTab) {
					var tabulatab = tabulatabForTab(chromeTab);
					if (tabulatab) {
						tabs.push(tabulatab);
					}
				});
			}
		});
		window.setTimeout(function() {
	        thisBrowser().saveTabs(tabs, function() {
	            console.log('saved tabs');
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
		}, 2000);
	});
}

var uploadTabTimout = null;

function startUploadTabsTimeout() {

	if(uploadTabTimout != null) window.clearTimeout(uploadTabTimout);

	uploadTabTimout = window.setTimeout(function() {
		collectAllTabs();
		uploadTabTimout = null;
	}, 7000);

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

	chrome.tabs.get(tabId, function(tab) {
		if (tab.favIconUrl) {
			imageColors('chrome://favicon/' + tab.url, function(colors, totalPixelCount) {
				var colorPalette = [];
				for(var i = 0; i < Math.min(5, colors.length); i++) {
					colorPalette.push([colors[i].red, colors[i].green, colors[i].blue]);
				}

				setPageMetaProperty(tab.url, 'colorPalette', colorPalette);
			});
		}
	});

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

if(thisBrowser().loadClients(function() {
    if (thisBrowser().clients.length == 0) {
        openOptions(true);
    }
}));
