var tabulatabs = new TabulatabsClient('Chrome');
var tabMetaInfo;
try {
	tabMetaInfo = JSON.parse(localStorage.getItem('tabMetaInfo'));
} catch(e) {}
if (!tabMetaInfo) tabMetaInfo = {};

function saveTabMeta() {
	localStorage.setItem('tabMetaInfo', JSON.stringify(tabMetaInfo));
}

function setTabMetaProperty(url, key, value) {
	if (!tabMetaInfo[url]) tabMetaInfo[url] = {};
	tabMetaInfo[url][key] = value;
	saveTabMeta();
}

function purgeUnusedThumbnails() {
	chrome.windows.getAll({populate: true}, function(chromeWindows) {

		var activeTabMetaInfo = {};
		$.each(chromeWindows, function(index, chromeWindow) {
			if (!chromeWindow.incognito) {

				$.each(chromeWindow.tabs, function(index, chromeTab) {

					if (tabMetaInfo[chromeTab.url]) {
						activeTabMetaInfo[chromeTab.url] = tabMetaInfo[chromeTab.url];
					}

				});
			}
		});

		console.log('Purging tab thumbs from ' + tabMetaInfo.length + ' to ' + activeTabMetaInfo.length);
		tabMetaInfo = activeTabMetaInfo;
		saveTabMeta();
	});
}

purgeUnusedThumbnails();
window.setInterval(function() {
	purgeUnusedThumbnails();
}, 1000 * 60);

function unsetTabMeta(url) {
	delete tabMetaInfo[url];
	saveTabMeta();
}

function tabulatabForTab(tab) {
	if (!tab.url.match(/^https?:\/\//)) {
		return null;
	}

	var tabulatab = {
		id: tab.id,
		title: tab.title,
		url: tab.url,
		selected: tab.selected,
		favIconUrl: tab.favIconUrl,
		windowId: tab.windowId,
		index: tab.index
	};

	findMetaInPageTitle(tabulatab);

	if (tabMetaInfo[tab.url]) {
		if (tabMetaInfo[tab.url].articleImage) {
			tabulatab.pageThumbnail = tabMetaInfo[tab.url].articleImage;
		} else if (tabMetaInfo[tab.url].pageThumbnail) {
			tabulatab.pageThumbnail = tabMetaInfo[tab.url].pageThumbnail;
		}

		if (tabMetaInfo[tab.uri].siteName) {
			tabulatab.siteTitle = tabMetaInfo[tab.uri].siteName;
		}
	}

	return tabulatab;
}

function collectAllTabs() {
	console.log('started uploading');

	var tabs = {};

	chrome.windows.getAll({populate: true}, function(chromeWindows) {
		$.each(chromeWindows, function(index, chromeWindow) {
			if (!chromeWindow.incognito) {

				$.each(chromeWindow.tabs, function(index, chromeTab) {
					var tabulatab = tabulatabForTab(chromeTab);
					if (tabulatab) {
						tabs[tabulatab.id] = tabulatab;
					}
				});
			}
		});
		tabulatabs.replaceTabs(tabs);
	});
}

function resizeThumbnail(dataUrl, maxWidth, maxHeight, callback) {
	var img = new Image();

	var canvas = document.createElement('canvas');
	canvas.setAttribute('width', maxWidth);
	canvas.setAttribute('height', maxHeight);

	var context = canvas.getContext('2d');

	img.onload = function() {
		var height = maxHeight;
		var width = img.width * (height / img.height);

		context.drawImage(img, 0, 0, width, height);

		$('body').append(canvas);
		callback(canvas.toDataURL('image/jpeg'));
	}

	img.src = dataUrl;
}

function captureThumbnailOfCurrentVisibleTab() {
	chrome.tabs.captureVisibleTab(null, {format: 'png'}, function(dataUrl) {
		chrome.tabs.getSelected(null, function(tab) {
			if(!tab.url.match(/^https?:\/\//)) return;
			resizeThumbnail(dataUrl, 256, 144, function(resizedDataUrl) {
				setTabMetaProperty(tab.url, 'pageThumbnail', resizedDataUrl);
			});
		});
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
	console.log('onMoved');console.dir(moveInfo);
	startUploadTabsTimeout();
});

chrome.tabs.onRemoved.addListener(function(tabId) {
	console.log('onRemoved');console.dir(tabId);
	startUploadTabsTimeout();
});

chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
	console.log('onSelectionChanged');console.dir(selectInfo);
	startUploadTabsTimeout();
	captureThumbnailOfCurrentVisibleTab();
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
	console.log('onUpdated');console.dir(changeInfo);
	startUploadTabsTimeout();
	if (changeInfo.status == 'complete') {
		captureThumbnailOfCurrentVisibleTab();
	}
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

if(!tabulatabs.getRegisteredClients().length == 0) {
	openOptions(true);
}