#! /bin/sh

# increasing version
cat ../TabulaTabs.safariextension/manifest.json | jsawk 'this.version = (parseInt(this.version) + 1).toString()' | pp > /tmp/manifest.json
mv /tmp/manifest.json ../TabulaTabs.safariextension/manifest.json

chromeVersion=`cat ../TabulaTabs.safariextension/manifest.json | jsawk 'return this.version'`
cat chrome-extension-updates.xml | sed "s/__version__/$chromeVersion/g" > /tmp/chrome-extension-updates.xml

bundleVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ../TabulaTabs.safariextension/Info.plist)
safariBuildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ../TabulaTabs.safariextension/Info.plist)
safariBuildNumber=$(($safariBuildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $safariBuildNumber" ../TabulaTabs.safariextension/Info.plist

cat safari-extension-updates.plist | sed "s/__buildNumber__/$safariBuildNumber/g" | sed "s/__bundleVersion__/$bundleVersion/g" > /tmp/safari-extension-updates.plist

echo "{chrome:\"$chromeVersion\",safari:\"$safariBuildNumber\"}" > ../TabulaTabs.safariextension/version.json

/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --pack-extension=../TabulaTabs.safariextension --pack-extension-key=../chrome-extension.pem

rsync --progress ../TabulaTabs.safariextension.crx 343max.de:"/var/www/tabulatabs.com/www/TabulaTabs.crx"
rsync --progress /tmp/chrome-extension-updates.xml 343max.de:"/var/www/tabulatabs.com/www/"
rsync --progress /tmp/safari-extension-updates.plist 343max.de:"/var/www/tabulatabs.com/www/"
