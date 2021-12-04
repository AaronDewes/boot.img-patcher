#!/usr/bin/env bash

# cd into the dir which contains this file
cd "$(dirname "${BASH_SOURCE}")"

# Download https://download.pageplace.de/ereader/15.2.0/OS81/update.zip to work-v6/update.zip
# Unzip work-v6/update.zip to work-v6/update
# If update.ip doesn't already exist in work-v6
mkdir -p work-v6
echo "Downloading update..."
if [ ! -f work-v6/update.zip ]; then
  # Download https://download.pageplace.de/ereader/15.2.0/OS81/update.zip to work-v6/update.zip
  curl -L -o work-v6/update.zip https://download.pageplace.de/ereader/15.2.0/OS81/update.zip
fi

rm -rf work-v6/update work-v6/boot-15.2.0

# Extract only the boot.img from the update.zip
echo "Extracting boot.img from update.zip..."
unzip -j work-v6/update.zip boot.img -d work-v6/update
echo "Extracting ramdisk from boot.img..."
./unpack_bootimg.py --boot_img work-v6/update/boot.img --out work-v6/boot-15.2.0 
echo "Unpacking ramdisk..."
mkdir work-v6/boot-15.2.0/ramdisk-unpacked
cd work-v6/boot-15.2.0/ramdisk-unpacked
gunzip -c ../ramdisk | cpio -i

rm default.prop
echo "Hacking ramdisk to enable adb..."
# Put new, multiline content into default.prop
cat ../../../patched/default-v6.prop > default.prop

echo "Repacking ramdisk..."
find . | cpio -o -H newc | gzip > ../repack-ramdisk
cd ..
rm -rf ramdisk-unpacked
rm -rf ramdisk
mv repack-ramdisk ramdisk

echo "Creating new boot.img..."
cd ..
cd ..
./mkbootimg_V6.py --kernel work-v6/boot-15.2.0/kernel --ramdisk work-v6/boot-15.2.0/ramdisk \
  --cmdline "selinux=1 androidboot.selinux=permissive buildvariant=user"\
  --kernel_offset 0x30008000 --ramdisk_offset 0x32000000\
  --second_offset 0x30f00000 --tags_offset 0x30000100\
  --os_patch_level 268697895\
  -o work-v6/boot-15.2.0-patched.img

# Now, wait for the user to press enter
echo
echo "Preparations done!"
echo "Please now boot your tolino into recovery mode by holding the power button until the screen refreshes and shows the Tolino logo."
echo "This can take up to 1 minute."
fastboot boot work-v6/boot-15.2.0-patched.img
