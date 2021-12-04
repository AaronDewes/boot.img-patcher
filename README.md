I'm not responsible for any damage to your devices by running this tool.

Please note that you may loose warranty when using this, although (This is not legal advice and I'm not a lawyer) you won't always loose it in the EU:
https://netzpolitik.org/2012/garantieanspruch-auch-nach-rooten-und-flashen-von-geraten/

---

# Tolino hacking

A tool to hack Tolino ebook readers.

**THIS DOES NOT WORK FOR THE VISION 6**

---

This tool allows you to enable adb, root access and the developer options on your Tolino.

### Included scripts

`boot_adb_mode.sh`: This boots your Tolino into a rooted mode with adb enabled. From this mode, you can, until a reboot, apply modifications to the OS. The modifications you apply will be kept, adb and root access won't.


`enable_dev_options.sh` This will permanently enable the developer options on your Tolino. This only works while the Tolino is in adb mode (via `boot_adb_mode.sh`). To access the developer options, press the search icon on the tolino homepage.

### Other things

`mkbootimg_V6.py` has a hardcoded OS version and patch level because I couldn't figure out how these are generated (yet).

