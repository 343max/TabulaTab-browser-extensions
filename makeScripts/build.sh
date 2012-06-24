#!/bin/sh

chromeVersion=`cat ../TabulaTabs.safariextension/manifest.json | jsawk 'return this.version'`
cat chrome-extension-updates.xml | sed "s/__version__/$chromeVersion/g" > /tmp/chrome-extension-updates.xml

echo "{chrome:\"$chromeVersion\",safari:\"$safariBuildNumber\"}" > ../TabulaTabs.safariextension/version.json

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --pack-extension=../TabulaTabs.safariextension --pack-extension-key=../chrome-extension.pem

rsync --progress ../TabulaTabs.safariextension.crx 343max.de:"/var/www/tabulatabs.com/www/TabulaTabs.crx"
rsync --progress /tmp/chrome-extension-updates.xml 343max.de:"/var/www/tabulatabs.com/www/"

cd ..
rm TabulaTabs.chrome.zip
zip -r TabulaTabs.chrome.zip TabulaTabs.safariextension/*
