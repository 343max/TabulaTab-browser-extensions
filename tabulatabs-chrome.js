var tabulatabs = new TabulatabsClient();

function each(array, callback) {
	for(var i = 0; i < array.length; i++) {
		callback(array[i]);
	}
}

function collectAllTabs() {
	if(!tabulatabs.loggedIn()) return false;

	var tabs = [];

	chrome.windows.getAll({'populate': true}, function(wins) {
		each(wins, function(win) {

			each(win.tabs, function(cTab) {
				if(!cTab.url.match(/^https?:\/\//)) return;

				var tab = {
					title: cTab.title,
					url: cTab.url,
					windowId: win.id,
					tabSelected: cTab.selected,
					windowFocused: win.focused
				};

				tabs.push(tab);

			});
		});

		tabulatabs.setTabs(tabs);
	});
}

function resizeThumbnail(dataUrl, maxWidth, maxHeight, callback) {

	var maxWidth = 320;
	var maxHeight = 240;

	var img = new Image();

	var canvas = document.createElement('canvas');
	canvas.setAttribute('width', maxWidth);
	canvas.setAttribute('height', maxHeight);

	var context = canvas.getContext('2d');

	img.onload = function() {

		var width = maxWidth;
		var height = img.height * (width / img.width);

		context.drawImage(img, 0, 0, width, height);

		$('body').append(canvas);
		callback(canvas.toDataURL('image/jpeg'));
	}

	img.src = dataUrl;
}

function resizeAndUploadThumb(selectedTab, dataUrl, maxWidth, maxHeight) {
	resizeThumbnail(dataUrl, maxWidth, maxHeight, function(resizedDataUrl) {
		tabulatabs.setThumbnail(selectedTab.url, maxWidth, maxHeight, resizedDataUrl);
	});
}

function uploadTabThumb(tabId, changeInfo) {
	chrome.tabs.get(tabId, function(updatedTab) {
		if(!updatedTab.url.match(/^https?:\/\//)) return;

		chrome.tabs.getSelected(updatedTab.windowId, function(selectedTab) {
			if(selectedTab.id != updatedTab.id) return;

			chrome.tabs.captureVisibleTab(null, {}, function(dataUrl) {
				resizeAndUploadThumb(selectedTab, dataUrl, 320, 240);
				resizeAndUploadThumb(selectedTab, dataUrl, 180, 180);
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
});

chrome.tabs.onSelectionChanged.addListener(function(tabId, selectInfo) {
	startUploadTabsTimeout();
});

chrome.tabs.onUpdated.addListener(function(tabId, changeInfo) {
	startUploadTabsTimeout();
	uploadTabThumb(tabId, changeInfo);
});



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

if(!tabulatabs.loggedIn()) {
	openOptions(true);
}