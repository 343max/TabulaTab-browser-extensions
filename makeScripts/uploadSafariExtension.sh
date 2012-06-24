#!/bin/sh

#upload the extension
rsync --progress ../TabulaTabs.safariextz 343max.de:"/var/www/tabulatabs.com/www/"


#build update XML
bundleVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ../TabulaTabs.safariextension/Info.plist)
safariBuildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ../TabulaTabs.safariextension/Info.plist)
cat safari-extension-updates.plist | sed "s/__buildNumber__/$safariBuildNumber/g" | sed "s/__bundleVersion__/$bundleVersion/g" > /tmp/safari-extension-updates.plist

#upload update XML
rsync --progress /tmp/safari-extension-updates.plist 343max.de:"/var/www/tabulatabs.com/www/"
