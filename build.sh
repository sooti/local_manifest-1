#!/bin/bash
set -e
if [ "$1" == "new" ] || [ "$2" == "new" ];then
  repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r38 --depth=1
  wget https://github.com/aosp-tissot/local_manifest/raw/aosp-10.0/local_manifest.xml .repo/local_manifest.xml
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-11.0/patch.sh
  wget https://github.com/phhusson/treble_experimentations/releases/download/v309/patches.zip
  wget https://raw.githubusercontent.com/aosp-tissot/local_manifest/aosp-11.0/patch.zip
  unzip ./patches.zip
  unzip ./patch.zip
  repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
  bash patch.sh ./
  patch -p1 < patch.txt
  cd -
fi
if [ "$1" == "clean" ] || [ "$2" == "clean" ];then
  repo init -u https://android.googlesource.com/platform/manifest -b android-11.0.0_r38 --depth=1
  repo forall -c 'git reset --hard ; git clean -fdx'
  if [ -f "patches.zip" ]; then
     rm patches.zip
  fi
  if [ -d "patches" ]; then
     rm -rf patches
  fi
  wget https://github.com/phhusson/treble_experimentations/releases/download/v309/patches.zip
  unzip ./patches.zip
  repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
  bash patch.sh ./
  patch -p1 < patch.txt
fi
cd device/phh/treble
bash generate.sh
cd -
. build/envsetup.sh
if [ "$1" == "arm64-gapps" ] || [ "$2" == "arm64-gapps" ];then
   lunch treble_arm64_bgN-user
fi
if [ "$1" == "arm64-gapps-go" ] || [ "$2" == "arm64-gapps-go" ];then
   lunch treble_arm64_boN-user
fi
if [ "$1" == "arm32-gapps-go" ] || [ "$2" == "arm32-gapps-go" ];then
   lunch treble_arm_aoN-user
fi
if [ "$1" == "arm64-vanilla" ] || [ "$2" == "arm64-vanilla" ];then
   lunch treble_arm64_bvN-user
fi
if [ "$1" == "clean" ];then
   make installclean
fi
make -j3 systemimage
threads = "cat /proc/cpuinfo | grep processor | wc -l"
xz -c -v ./out/target/product/phhgsi_arm64_ab/system.img -T$threads > system.img.xz
