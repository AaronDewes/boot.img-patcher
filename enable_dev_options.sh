#!/usr/bin/env bash

# cd into the dir which contains this file
cd "$(dirname "${BASH_SOURCE}")"

rm ePub.xml
adb pull /data/data/de.telekom.epub/shared_prefs/ePub.xml
# Delete every line from ePub.xml which contains DEBUG in any way
sed -i '/DEBUG/d' ePub.xml
# The file should end with </map>
# Before that line, insert these two lines:
#  <string name="de.telekom.epub.PREFS_DEBUG_DIALOG_LAST_OPEN_CODE">c5af5651b57b1db0fe9f373e95cd4042997ccfb7bd2c5fa0b0b45ebc7717d83a9b71fb695e22478c1d4e9dd3d85330e3d385c5c49a892972484e45d5533532c6</string>
#  <boolean name="de.telekom.epub.PREFS_DEBUG_DIALOG_QUICK_ACCESS" value="true" />
sed -i 's/<\/map>/    <string name="de.telekom.epub.PREFS_DEBUG_DIALOG_LAST_OPEN_CODE">c5af5651b57b1db0fe9f373e95cd4042997ccfb7bd2c5fa0b0b45ebc7717d83a9b71fb695e22478c1d4e9dd3d85330e3d385c5c49a892972484e45d5533532c6<\/string>\n    <boolean name="de.telekom.epub.PREFS_DEBUG_DIALOG_QUICK_ACCESS" value="true" \/>\n<\/map>/' ePub.xml
# Push the modified file to the device
adb push ePub.xml /data/data/de.telekom.epub/shared_prefs/ePub.xml
adb shell am force-stop de.telekom.epub
