#!/bin/bash

# Setup of Phonegap and required modules for phonegap migration.
# Requires Node http://nodejs.org/

# dependencies: file containing a list of all modules required for migration from older Phonegap versions.
module_list_file="phonegap-migration-modules.txt"

app_name="ohmage MWF"

project_name="ohmage-mwf"

bundle_id="org.ohmage.mwf"

# check if node is installed. 
if ! hash node 2>/dev/null; then
  printf >&2 "I require node but it's not installed.\nInstall it from http://nodejs.org/\n"
  exit 1
fi

# if the cordova npm module isn't installed, install it
if ! hash cordova 2>/dev/null; then

  read -p "Cordova module not installed. Install it globally (requires password)? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]] 
  then
    sudo npm install -g cordova
    echo >&2 "Installing cordova module globally..."
  else 
    echo "This requires the cordova npm module. Installation instructions here: http://phonegap.com/install/"
    exit 1
  fi
fi

# rename our directory in preparation for it being moved.
mv www www-temp

# prepare local notification directories for being moved
# move the LocalNotification plugin replacement files into a new temp directory `localnot`
# -p option makes intermediate directories
mkdir -p localnot/plugins/com\.cmpsoft\.mobile\.plugin\.localnotification

# `$_` invokes the last arg passed
mv plugins/com\.cmpsoft\.mobile\.plugin\.localnotification/www $_

mkdir -p "localnot/platforms/ios/${app_name}"
mv "platforms/ios/${app_name}/Classes" "$_/Classes"


echo "************"
echo "creating ${app_name} Phonegap project in current directory..."
echo "************"
cordova create temp $bundle_id $project_name

mv res temp/res

# Remove auto-generated www directory, replace with ours
rm -R temp/www
mv www-temp temp/www

# Remove auto-generated config.xml, replace with ours
rm temp/config.xml
mv config.xml temp/config.xml

echo "************"
echo "adding iOS platform to project..."
echo "************"
cd temp
cordova platform add ios

# Remove auto-generated iOS platform splash images directory, replace with ours
rm -R "platforms/ios/${app_name}/Resources/splash"
cd ..
cp -R "temp/res/ios/splash" "temp/platforms/ios/${app_name}/Resources/splash"

# move the contents of temp into current directory
cp -R temp/. .

rm -R temp



# gets the list of plugin modules to install from our text file.
modules=( `cat $module_list_file | tr '\n' ' '` )

echo "************"
echo "installing modules..."
echo "************"
for module in "${modules[@]}"; do
  cordova plugin add "$module"
done

# Remove auto-generated localnotification plugin files, replace with ours
rm plugins/com.cmpsoft.mobile.plugin.localnotification/www/LocalNotification.js
mv localnot/plugins/com.cmpsoft.mobile.plugin.localnotification/www/LocalNotification.js plugins/com.cmpsoft.mobile.plugin.localnotification/www/LocalNotification.js

rm "platforms/ios/${app_name}/Classes/AppDelegate.m"
mv "localnot/platforms/ios/${app_name}/Classes/AppDelegate.m" "platforms/ios/${app_name}/Classes/AppDelegate.m"
rm -R localnot

echo "************"
echo "Setup complete. Build with:"
echo "cordova build ios"
echo "************"