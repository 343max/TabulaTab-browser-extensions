#!/bin/sh

cp -r ../TabulaTabs.safariextension /tmp/
cd /tmp/TabulaTabs.safariextension
cat manifest.json | jsawk 'this.update_url = undefined' > ../manifest.json ; mv ../manifest.json ./

zip -r /Users/max/Documents/TabulaTabs/browser-extensions/TabulaTabs.ChromeWebStore.zip *