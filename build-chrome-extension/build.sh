#! /bin/sh

mkdir /tmp/extension/

# increasing version
cat ../chrome-extension/manifest.json | jsawk 'this.version = (parseInt(this.version) + 1).toString()' | pp > /tmp/manifest.json
mv /tmp/manifest.json ../chrome-extension/manifest.json

version=`cat ../chrome-extension/manifest.json | jsawk 'return this.version'`
cat chrome-extension-updates.xml | sed "s/__version__/$version/g" > /tmp/extension/chrome-extension-updates.xml

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --pack-extension=../chrome-extension --pack-extension-key=../chrome-extension.pem

rsync --progress ../chrome-extension.crx 343max.de:/var/www/tabulatabs.com/www/
rsync --progress /tmp/extension/chrome-extension-updates.xml 343max.de:/var/www/tabulatabs.com/www/
