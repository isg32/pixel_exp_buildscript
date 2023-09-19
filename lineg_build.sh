#!/bin/bash

path= pwd #or add pwd here

L1()
{
	git config --global user.email "sapangajjar101105@gmail.com"
	git config --global user.name "isg32"
} &> /dev/null

L2()
{
    cd $path
    mkdir bin
    PATH=$path/bin:$PATH
    curl https://storage.googleapis.com/git-repo-downloads/repo > $path/bin/repo
    chmod a+x $path/bin/repo
}

L3()
{
    cd $path
    git clone https://github.com/fuyukihidekii/android_device_motorola_sm6150-common -b lineage-20 keys
    mkdir los
    cd los
    echo -ne '\n' | repo init -u https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs --depth=1
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
    sed -i "/ro.control_privapp_permissions=enforce/d" vendor/lineage/config/common.mk
    rm -r external/chromium-webview/prebuilt
    git clone https://github.com/LineageOS/android_external_chromium-webview_prebuilt_arm -b main external/chromium-webview/prebuilt/arm
    git clone https://github.com/LineageOS/android_external_chromium-webview_prebuilt_arm64 -b main external/chromium-webview/prebuilt/arm64
    git clone https://github.com/LineageOS/android_external_chromium-webview_prebuilt_x86 -b main external/chromium-webview/prebuilt/x86
    git clone https://github.com/LineageOS/android_external_chromium-webview_prebuilt_x86_64 -b main external/chromium-webview/prebuilt/x86_64
    cd $path/los/external/chromium-webview/prebuilt/arm  && git lfs pull
    cd $path/los/external/chromium-webview/prebuilt/arm64  && git lfs pull
    cd $path/los/external/chromium-webview/prebuilt/x86  && git lfs pull
    cd $path/los/external/chromium-webview/prebuilt/x86_64  && git lfs pull
    cd $path/los
    cd system/core/init
    rm -r property_service.cpp
    rm -r service.h
    wget https://github.com/RaghuVarma331/scripts/raw/master/Patches/service.h &> /dev/null
    wget https://github.com/RaghuVarma331/scripts/raw/master/Patches/property_service.cpp &> /dev/null
}

L4()
{
    cd $path/los
    git clone https://github.com/fuyukihidekii/android_device_motorola_sm6150-common -b lineage-20 --depth=1 device/motorola/hanoip
    git clone https://github.com/fuyukihidekii/proprietary_vendor_motorola -b lineage-20 --depth=1 vendor/motorola/hanoip
    git clone https://github.com/fuyukihidekii/android_kernel_motorola_sm6150 -b lineage-20 --depth=1 kernel/motorola/sm6150
    . build/envsetup.sh && lunch lineage_hanoip-userdebug && make -j$(nproc --all) target-files-package otatools
    romname=$(cat $path/los/out/target/product/hanoip/system/build.prop | grep ro.lineage.version | cut -d "=" -f 2)
    sign_target_files_apks -o -d $path/keys $path/los/out/target/product/hanoip/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip $path/los/out/target/product/hanoip/signed-target-files.zip
    ota_from_target_files -k $path/keys/releasekey $path/los/out/target/product/hanoip/signed-target-files.zip $path/los/out/target/product/hanoip/lineage-$romname.zip
    cp -r out/target/product/*/lineage-20.0**.zip $path
    rm -r out/target/product/*
    rm -r device/moto*
    rm -r kernel/moto*
    rm -r vendor/moto*
    rm -r vendor/lineage
}

echo "____________________________________________________"
echo "Initialising setup.."
echo "____________________________________________________"
L1
echo "____________________________________________________"
echo "Setting up repo launcher.."
echo "____________________________________________________"
L2
echo "____________________________________________________"
echo "Downloading LineageOS 20.0 source code.."
echo "____________________________________________________"
L3
echo "____________________________________________________"
echo "Building LineageOS 20.0 for Moto G60/G40F.."
echo "____________________________________________________"
L4
