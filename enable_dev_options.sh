#!/usr/bin/env bash

# cd into the dir which contains this file
cd "$(dirname "${BASH_SOURCE}")"

# Delete leftovers from a potential previous run
rm ePub.xml
# Pull the app config
adb pull /data/data/de.telekom.epub/shared_prefs/ePub.xml
# Delete every line from ePub.xml which contains DEBUG in any way
sed -i '/DEBUG/d' ePub.xml
# The file should end with </map>
# Before that line, insert these two lines:
#  <string name="de.telekom.epub.DEBUG_DIALOG_LAST_OPEN_CODE">d820afedd912b83340429595ad855b893815bb85661b2b50e0892f7b3d720e6c8ebad365623f8896ba946957c1ff70a3fcf51a2127041804fb17c46c671c37c0</string>
#  <boolean name="de.telekom.epub.PREFS_DEBUG_DIALOG_QUICK_ACCESS" value="true" />
sed -i 's/<\/map>/    <string name="de.telekom.epub.DEBUG_DIALOG_LAST_OPEN_CODE">d820afedd912b83340429595ad855b893815bb85661b2b50e0892f7b3d720e6c8ebad365623f8896ba946957c1ff70a3fcf51a2127041804fb17c46c671c37c0<\/string>\n    <boolean name="de.telekom.epub.PREFS_DEBUG_DIALOG_QUICK_ACCESS" value="true" \/>\n<\/map>/' ePub.xml
# Push the modified file to the device
adb push ePub.xml /data/data/de.telekom.epub/shared_prefs/ePub.xml
# Restart the app
adb shell am force-stop de.telekom.epub
