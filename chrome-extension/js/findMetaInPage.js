window.setTimeout(function() {
	var getMetaTagContentByProperty = function(property) {
		var metaTags = document.getElementsByTagName('meta');

		for (i = 0; i < metaTags.length; i++) {
			if (metaTags[i].getAttribute('property') == property) {
				return metaTags[i].getAttribute('content');
			}
		}

		return null;
	}
	
	var getMetaTagContentByName = function(name) {
		var metaTags = document.getElementsByTagName('meta');

		for (i = 0; i < metaTags.length; i++) {
			if (metaTags[i].getAttribute('name') == name) {
				return metaTags[i].getAttribute('content');
			}
		}

		return null;
	}
	
	var findThumbnail = function() {
		var findImageInPage = function() {
			var images = document.getElementsByTagName('img');

			var bestMatch = null;
			var bestArea = 0;

			var adSizes = [
				{width: 728, height: 90},
				{width: 468, height: 60},
				{width: 120, height: 600},
				{width: 160, height: 600},
				{width: 200, height: 200},
				{width: 250, height: 250},
				{width: 300, height: 250},
				{width: 336, height: 280}
			];

			var isHidden = function(el) {
				try {
					if (computedStyle.getPropertyValue('display') == 'hidden') {
						return true;
					}
				} catch(e) {

				}

				if (el.parentNode) {
					return isHidden(el.parentNode);
				}

				return false;
			}

			var debug = function(image, message, color) {

				if (message) {
					image.setAttribute('title', message);
					console.log(message + ' ' + image.src);
				}

				if (!color) color = 'red';
				image.style.border = '3px solid ' + color + ' !important';
			}

			debug = function() {};

			for (var i = 0; i < images.length; i++)  {
				var image = images[i];

				if (image.height == 0) {
					debug(image, 'no height given');
					continue;
				}

				var ratio = image.width / image.height;
				var area = image.width * image.height;

				if (ratio < 0.3 || ratio > 5) {
					debug(image, 'wrong ration of ' + ratio);
					continue;
				}

				if (image.y > window.innerHeight || image.x > window.innerWidth) {
					debug(image, 'outside of visible area');
					continue;
				}

				if (area < 40000) {
					debug(image, 'to small (area: ' + area + ' sq px)');
					continue;
				}

				if (image.x == 0 && image.y == 0) {
					debug(image, 'position: 0,0');
					continue;
				}

				/*
				for(var i = 0; i < adSizes.length; i++) {
					var adSize = adSizes[i];
					if (image.width == adSize.width && image.height == adSize.height) {
						debug(image, 'ad: ' + adSize.width + 'x' + adSize.height);
					}
				}
				*/
				/*
				if (isHidden(image)) {
					debug(image, 'is hidden');
					continue;
				}
				*/

				debug(image, 'valid candidate (area: ' + area + ' ratio: ' + ratio + ')', 'yellowgreen')

				if (area > bestArea) {
					bestArea = area;
					bestMatch = image;
				} else {
					debug(image, 'valid candidate, allready beaten (area: ' + area + ' ratio: ' + ratio + ')', 'yellow')
				}
			}

			if (bestMatch) {
				debug(bestMatch, 'best match: ' + bestArea, 'green');

				return bestMatch.src;
			}
		}

		var findFacebookImageInPage = function() {
			return getMetaTagContentByProperty('og:image');
		}

		var thumbSrc = findFacebookImageInPage();
		if (!thumbSrc) thumbSrc = findImageInPage();

		if (thumbSrc) {
			chrome.extension.sendRequest({articleImage: thumbSrc});
		}
	}

	var findTitle = function() {
		var title = getMetaTagContentByProperty('og:title');
		if (!title) title = getMetaTagContentByName('fulltitle');
		if (!title) title = getMetaTagContentByName('DC.title');
		chrome.extension.sendRequest({articleTitle: title});
	}

	var findType = function() {
		var type = getMetaTagContentByProperty('og:type');
		chrome.extension.sendRequest({articleType: type});
	}

	var findURL = function() {
		var url = getMetaTagContentByProperty('og:url');
		if (!url) url = getMetaTagContentByName('DC.identifier');
		chrome.extension.sendRequest({articleURL: url});
	}

	var findSiteName = function() {
		var siteName = getMetaTagContentByProperty('og:site_name');
		chrome.extension.sendRequest({siteName: siteName});
	}

	var findDescription = function() {
		var description = getMetaTagContentByProperty('og:description');
		if (!description) description = getMetaTagContentByName('DC.description');
		chrome.extension.sendRequest({articleDescription: description});
	}

	findTitle();
	findType();
	findURL();
	findSiteName();
	findDescription();
	findThumbnail();

}, 5000);