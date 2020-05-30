#!/bin/sh
echo "*********************************"
echo "Build Started"
echo "*********************************"

echo "*********************************"
echo "Beginning Build Process"
echo "*********************************"

xcodebuild -project "${1}" -target "${2}" -sdk iphoneos -verbose CONFIGURATION_BUILD_DIR="${3}"

#echo "*********************************"
#echo "Creating IPA"
#echo "*********************************"

#/usr/bin/xcrun -verbose -sdk iphoneos PackageApplication -v "${3}/${4}.app" -o "${5}/app.ipa"
