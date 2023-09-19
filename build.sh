#!/bin/bash

path= pwd #or just add pwd here


L1()
{
	git config --global user.email "sapangajjar101105@gmail.com"
	git config --global user.name "isg32"
	
} 

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
    mkdir pe
    cd pe
    echo -ne '\n' | repo init -u https://github.com/PixelExperience/manifest -b thirteen-plus --git-lfs --depth=1
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
    rm -r .repo
    sed -i "/ro.control_privapp_permissions=enforce/d" vendor/aosp/config/common.mk
    cd $path/pe
    cd system/core/init
    rm -r service.h
    wget https://github.com/RaghuVarma331/scripts/raw/master/Patches/service.h &> /dev/null
}

L4()
{
    cd $path/pe
    git clone https://github.com/fuyukihidekii/android_device_motorola_sm6150-common -b lineage-20 --depth=1 device/motorola/hanoip
    git clone https://github.com/fuyukihidekii/proprietary_vendor_motorola -b lineage-20 --depth=1 vendor/motorola/hanoip
    git clone https://github.com/fuyukihidekii/android_kernel_motorola_sm6150 -b lineage-20 --depth=1 kernel/motorola/sm6150
    . build/envsetup.sh && lunch aosp_hanoip-userdebug && make -j$(nproc --all) target-files-package otatools
    romname=$(cat $path/pe/out/target/product/hanoip/system/build.prop | grep org.pixelexperience.version.display | cut -d "=" -f 2)
    sign_target_files_apks -o -d $path/keys $path/pe/out/target/product/hanoip/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip $path/pe/out/target/product/hanoip/signed-target-files.zip
    ota_from_target_files -k $path/keys/releasekey $path/pe/out/target/product/hanoip/signed-target-files.zip $path/pe/out/target/product/hanoip/$romname.zip
    cp -r out/target/product/*/PixelExperience**.zip $path
    rm -r out/target/product/*
    rm -r device/moto*
    rm -r kernel/moto*
    rm -r vendor/moto*
    rm -r vendor/aosp
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
echo "Downloading Pixel Experience Plus source code.."
echo "____________________________________________________"
L3
echo "____________________________________________________"
echo "Building Pixel Experience Plus for Moto G60/G40F.."
echo "____________________________________________________"
L4
