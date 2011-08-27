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

function unsetTabMeta(url) {
	delete tabMetaInfo[url];
	saveTabMeta();
}

function collectAllTabs() {
	var windows = [];

	var dump = [];

	chrome.windows.getAll({populate: true}, function(chromeWindows) {
		$.each(chromeWindows, function(index, chromeWindow) {
			if (!chromeWindow.incognito) {
				var window = {id: chromeWindow.id, focused: chromeWindow.focused, tabs: []};

				$.each(chromeWindow.tabs, function(index, chromeTab) {
					if(!chromeTab.url.match(/^https?:\/\//)) return;

					var tab = {
						title: chromeTab.title,
						url: chromeTab.url,
						selected: chromeTab.selected,
						favIconUrl: chromeTab.favIconUrl
					};

					enrichWithMetaInfo(tab);

					if (tabMetaInfo[chromeTab.url]) {
						if (tabMetaInfo[chromeTab.url].articleImage) {
							tab.pageThumbnail = tabMetaInfo[chromeTab.url].articleImage;
						} else {
							tab.pageThumbnail = tabMetaInfo[chromeTab.url].pageThumbnail;
						}
					}

					dump.push(tab);

					window.tabs.push(tab);
				});

				if (window.tabs.length > 0) {
					windows.push(window);
				}
			}
		});

		//console.dir(windows);
		tabulatabs.setTabs(windows);
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
	chrome.tabs.getSelected(null, function(tab) {
		if(!tab.url.match(/^https?:\/\//)) return;
		
		chrome.tabs.captureVisibleTab(null, {format: 'png'}, function(dataUrl) {
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
	startUploadTabsTimeout();
});

chrome.tabs.onRemoved.addListener(function(tabId) {
	startUploadTabsTimeout();
	unsetTabMeta(tabId);
});

chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
	startUploadTabsTimeout();
	captureThumbnailOfCurrentVisibleTab();
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
	startUploadTabsTimeout();
	if (changeInfo.status == 'complete') {
		captureThumbnailOfCurrentVisibleTab();
	}
});

chrome.extension.onRequest.addListener(function(request, sender, callback) {
	if (request.articleImage) {
		setTabMetaProperty(sender.tab.url, 'articleImage', request.articleImage);
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