#!/bin/sh

#increasing chrome build
cat ../TabulaTabs.safariextension/manifest.json | jsawk 'this.version = (parseInt(this.version) + 1).toString()' | pp > /tmp/manifest.json
mv /tmp/manifest.json ../TabulaTabs.safariextension/manifest.json

#increasing safari build
safariBuildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ../TabulaTabs.safariextension/Info.plist)
safariBuildNumber=$(($safariBuildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $safariBuildNumber" ../TabulaTabs.safariextension/Info.plist
