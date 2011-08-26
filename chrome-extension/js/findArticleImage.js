window.setTimeout(function() {
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

		if (area < 60000) {
			debug(image, 'to small (area: ' + area + ' sq px)');
			continue;
		}

		if (image.x == 0 && image.y == 0) {
			debug(image, 'position: 0,0');
			continue;
		}

		for(var i = 0; i < adSizes.length; i++) {
			var adSize = adSizes[i];
			if (image.width == adSize.width && image.height == adSize.height) {
				debug(image, 'ad: ' + adSize.width + 'x' + adSize.height);
				continue(2);
			}
		}

		if (isHidden(image)) {
			debug(image, 'is hidden');
			continue;
		}

		debug(image, 'valid candidate (area: ' + area + ' ratio: ' + ratio + ')', 'yellowgreen')

		if (area > bestArea) {
			bestArea = area;
			bestMatch = image;
		} else {
			debug(image, 'valid candidate, allready beaten (area: ' + area + ' ratio: ' + ratio + ')', 'yellow')
		}
	}

	if (bestMatch) {
		var image = bestMatch;
		debug(image, 'best match: ' + bestArea, 'green');

		chrome.extension.sendRequest({articleImage: bestMatch.src});
	}
}, 5000);