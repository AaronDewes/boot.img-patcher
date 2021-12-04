#!/usr/bin/env bash

# cd into the dir which contains this file
cd "$(dirname "${BASH_SOURCE}")"

mkdir -p work
echo "Downloading update.zip from Tolino servers..."
if [ ! -f work/update.zip ]; then
  # Download https://download.pageplace.de/ereader/15.2.0/OS44/update.zip to work/update.zip
  curl -L -o work/update.zip https://download.pageplace.de/ereader/15.2.0/OS44/update.zip
fi

rm -rf work/update work/boot-15.2.0

# Extract only the boot.img from the update.zip
echo "Extracting boot.img from update.zip..."
unzip -j work/update.zip boot.img -d work/update > /dev/null
echo "Extracting ramdisk from boot.img..."
./unpack_bootimg.py --boot_img work/update/boot.img --out work/boot-15.2.0 #> /dev/null
echo "Unpacking ramdisk..."
mkdir work/boot-15.2.0/ramdisk-unpacked
cd work/boot-15.2.0/ramdisk-unpacked
gunzip -c ../ramdisk | cpio -i > /dev/null 2> /dev/null

echo "Hacking ramdisk to enable adb..."
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

echo "Patching adbd to allow root..."
cp -f "../../../patched/adbd" sbin/adbd
chmod +x sbin/adbd

echo "Repacking ramdisk..."
find . | cpio -o -H newc  2> /dev/null | gzip > ../repack-ramdisk
cd ..
rm -rf ramdisk ramdisk-unpacked
mv repack-ramdisk ramdisk

echo "Creating new boot.img..."
cd ..
cd ..
./mkbootimg.py --kernel work/boot-15.2.0/kernel --ramdisk work/boot-15.2.0/ramdisk \
  --cmdline "console=ttymxc0,115200 init=/init androidboot.console=ttymxc0 max17135:pass=2, fbmem=6M video=mxcepdcfb:E060SCM,bpp=16 no_console_suspend"\
  --board ntx_6sl\
  --kernel_offset 0x70808000 --ramdisk_offset 0x71800000\
  --second_offset 0x71700000 --tags_offset 0x70800100\
  -o work/boot-15.2.0-patched.img > /dev/null

# Now, wait for the user to press enter
echo
echo "Preparations done!"
echo "Please now boot your tolino into recovery mode by holding the power button until the screen refreshes and shows the Tolino logo."
echo "This can take up to 1 minute."
# Measure the time fastboot boot work-v6/boot-15.2.0-patched.img takes
# Start the timer
start=$(date +%s)
# Boot the patched boot.img
fastboot boot work/boot-15.2.0-patched.img
# Stop the timer
end=$(date +%s)
# Calculate the difference
diff=$(( $end - $start ))
# Print the time
echo "It took $diff seconds to boot the patched boot.img."
echo

