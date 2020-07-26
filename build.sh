#!/bin/bash
set -e
repo forall -c 'git reset --hard ; git clean -fdx' 
repo init -u https://android.googlesource.com/platform/manifest -b android-10.0.0_r40
if [ "$2" == "new" ];then
  wget https://github.com/aosp-tissot/local_manifest/raw/aosp-10.0/local_manifest.xml .repo/local_manifest.xml
fi
repo sync -c -j 16 -f --force-sync --no-tag --no-clone-bundle --optimized-fetch --prune
if [ "$1" == "clean" ]
  rm patches.zip
  rm -rf patches
  wget https://github.com/phhusson/treble_experimentations/releases/download/v217/patches.zip
  unzip ./patches.zip
fi
bash patch.sh ./
patch -p1 < patch.txt
cd frameworks/base
git fetch https://github.com/aosp-tissot/platform_frameworks_base-1.git Q
git cherry-pick 7dcb550f5f267b4d275240c9d29c331cfedde42b
git fetch "https://github.com/LineageOS/android_frameworks_base" refs/changes/06/267306/21 && git cherry-pick FETCH_HEAD
cd -
cd device/phh/treble
bash generate.sh
cd -
. build/envsetup.sh
lunch treble_arm64_bgN-user
if [ "$1" == "clean" ];then
   make installclean
fi
make -j16 systemimage
xz -c $OUT/system.img -v -T0 > ./system.img.xz