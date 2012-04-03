var tabMetaInfo;
try {
	tabMetaInfo = JSON.parse(localStorage.getItem('tabMetaInfo'));
} catch(e) {}
if (!tabMetaInfo) tabMetaInfo = {};

function saveTabMeta() {
	localStorage.setItem('tabMetaInfo', JSON.stringify(tabMetaInfo));
}

function getTabMetaProperty(url, key) {
	if (!tabMetaInfo[url]) return null;
	return tabMetaInfo[url][key];
}

function setTabMetaProperty(url, key, value) {
	if (!tabMetaInfo[url]) tabMetaInfo[url] = {};
	tabMetaInfo[url][key] = value;
    console.log('tabMetaInfo.length: ' + Object.keys(tabMetaInfo).length);
	saveTabMeta();
}

function unsetTabMeta(url) {
	delete tabMetaInfo[url];
	saveTabMeta();
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
		colorPalette: getTabMetaProperty(tab.url, 'colorPalette')
	};

	findMetaInPageTitle(tabulatab);

	if (tabMetaInfo[tab.url]) {
		if (tabMetaInfo[tab.url].articleImage) {
			tabulatab.pageThumbnail = tabMetaInfo[tab.url].articleImage;
		}

		if (tabMetaInfo[tab.url].siteName) {
			tabulatab.siteTitle = tabMetaInfo[tab.url].siteName;
		}
	}

	return tabulatab;
}

function collectAllTabs() {
	console.log('started uploading');

	chrome.browserAction.setIcon({path: 'chasingArrows.gif'});

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
        thisBrowser().saveTabs(tabs, function() {
            console.log('saved tabs');
			chrome.browserAction.setIcon({path: 'icon.png'});
            
            $.each(chrome.extension.getViews(), function(index, view) {
            	console.dir(view.document);
            	if (view.document.onTabsSaved) {
            		view.document.onTabsSaved();
            	}
            });
        })
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

				setTabMetaProperty(tab.url, 'colorPalette', colorPalette);
			});
		}
	});

	startUploadTabsTimeout();
});

chrome.extension.onRequest.addListener(function(request, sender, callback) {
	if (request.articleImage) {
		setTabMetaProperty(sender.tab.url, 'articleImage', request.articleImage);
	}

	if (request.articleTitle) {
		setTabMetaProperty(sender.tab.url, 'articleTitle', request.articleTitle);
	}

	if (request.articleType) {
		setTabMetaProperty(sender.tab.url, 'articleType', request.articleType);
	}

	if (request.articleURL) {
		setTabMetaProperty(sender.tab.url, 'articleURL', request.articleURL);
	}

	if (request.siteName) {
		setTabMetaProperty(sender.tab.url, 'siteName', request.siteName);
	}

	if (request.articleDescription) {
		setTabMetaProperty(sender.tab.url, 'articleDescription', request.articleDescription);
	}
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
    console.dir(['registeredClients', thisBrowser().clients]);
    if (thisBrowser().clients.length == 0) {
        openOptions(true);
    }
}));
