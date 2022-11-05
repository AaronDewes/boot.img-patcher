#!/usr/bin/env bash

# cd into the dir which contains this file
cd "$(dirname "${BASH_SOURCE}")"

mkdir -p work
echo "Tolino update wird heruntergeladen..."
if [ ! -f work/update-16.0.0.zip ]; then
  # Download https://download.pageplace.de/ereader/15.2.0/OS44/update.zip to work/update.zip
  curl -L -o work/update-16.0.0.zip https://download.pageplace.de/ereader/16.0.0/OS44/update.zip
fi

rm -rf work/update work/boot-16.0.0

#sleep 3
# Extract only the boot.img from the update.zip
echo "Update wird entpackt..."
unzip -j work/update-16.0.0.zip boot.img -d work/update > /dev/null
#sleep 3
echo "Firmware wird extrahiert..."
./unpack_bootimg.py --boot_img work/update/boot.img --out work/boot-16.0.0 > /dev/null
#sleep 3
echo "Ramdisk wird geladen..."
mkdir work/boot-16.0.0/ramdisk-unpacked
cd work/boot-16.0.0/ramdisk-unpacked
gunzip -c ../ramdisk | cpio -i > /dev/null 2> /dev/null
#sleep 3
echo "Ramdisk wird modifiziert..."
# Put new, multiline content into default.prop
cat << EOF > default.prop
#
# ADDITIONAL_DEFAULT_PROPERTIES
#
persist.sys.strictmode.visual=0
persist.sys.strictmode.disable=1
ro.secure=0
ro.allow.mock.location=0
ro.debuggable=1
persist.service.adb.enable=1
persist.sys.usb.config=mass_storage,adb
EOF
#sleep 3
echo "Vollständiger Zugriff wird aktiviert..."
cp -f "../../../patched/adbd" sbin/adbd
chmod +x sbin/adbd

#sleep 4
echo "Ramdisk wird neu komprimiert..."
find . | cpio -o -H newc  2> /dev/null | gzip > ../repack-ramdisk
cd ..
rm -rf ramdisk ramdisk-unpacked
mv repack-ramdisk ramdisk
#sleep 5
echo "Modifizierte Firmware wird erstellt..."
cd ..
cd ..
./mkbootimg.py --kernel work/boot-16.0.0/kernel --ramdisk work/boot-16.0.0/ramdisk \
  --cmdline "console=ttymxc0,115200 init=/init androidboot.console=ttymxc0 max17135:pass=2, fbmem=6M video=mxcepdcfb:E060SCM,bpp=16 no_console_suspend"\
  --board ntx_6sl\
  --kernel_offset 0x70808000 --ramdisk_offset 0x71800000\
  --second_offset 0x71700000 --tags_offset 0x70800100\
  -o work/boot-16.0.0-patched.img > /dev/null
#sleep 2
# Now, wait for the user to press enter
echo
echo "Vorbereitung abgeschlossen!"
echo "Bitte halte jetzt den Anschaltknopf am Tolino gedrückt, bis das Tolino-Logo angezeigt wird. Dies kann bis zu 1 Minute dauern."
# Measure the time fastboot boot work-v6/boot-15.2.0-patched.img takes
# Start the timer
start=$(date +%s)
# Boot the patched boot.img
fastboot boot work/boot-16.0.0-patched.img
# Stop the timer
end=$(date +%s)
# Calculate the difference
diff=$(( $end - $start ))
# Print the time
echo "Es hat $diff Sekunden gedauert."
echo

