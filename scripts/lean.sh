#!/bin/bash
#=================================================
# File name: lean.sh
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================
now_dir=$(pwd)
clone_dir=${now_dir}"/../git_clone_temporary_space"
if [ ! -d "$clone_dir" ]; then
  mkdir "$clone_dir"
fi
function github_partial_clone(){
    url_prefix="https://github.com/" author_name="$1" repository_name="$2" branch_name="$3" required_dir="$4" saved_dir="$5"
    if [ "$branch_name" == "use_default_branch" ]; then
        branch_option=""
    else        
        branch_option="-b "${branch_name}
    fi
    if [ ! -d ${saved_dir} ]; then
        mkdir -vp ${saved_dir}
    fi
    if [ ! -d ${clone_dir}"/"${repository_name} ]; then
        git clone --depth=1 ${branch_option} ${url_prefix}${author_name}"/"${repository_name}".git" ${clone_dir}"/"${repository_name}
    fi
    mv ${clone_dir}"/"${repository_name}"/"${required_dir}/* ${saved_dir}
    rm -rf ${clone_dir}"/"${repository_name}
}

# Clone community packages to package/community

rm -rf package/base-files/files/lib/preinit/80_mount_root
cp -f $GITHUB_WORKSPACE/80_mount_root package/base-files/files/lib/preinit/80_mount_root
# wget -P package/base-files/files/lib/preinit https://raw.githubusercontent.com/DHDAXCW/lede-rockchip/stable/package/base-files/files/lib/preinit/80_mount_root 
# rm -rf package/libs/libnl-tiny
# rm -rf package/kernel/mac80211
# rm -rf package/kernel/mt76
# rm -rf package/network/services/hostapd
# rm -rf package/wwan
# github_partial_clone DHDAXCW lede-rockchip use_default_branch package/wwan package/wwan
# github_partial_clone openwrt openwrt use_default_branch package/libs/libnl-tiny package/libs/libnl-tiny
# github_partial_clone openwrt openwrt use_default_branch package/kernel/mac80211 package/kernel/mac80211
# github_partial_clone DHDAXCW lede-rockchip use_default_branch package/kernel/mt76 package/kernel/mt76
# github_partial_clone openwrt openwrt use_default_branch package/network/services/hostapd package/network/services/hostapd

# gloang
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

mkdir package/community
pushd package/community

# Add luci-app-watchcat-plus
git clone https://github.com/MilesPoupart/luci-app-watchcat-plus.git

# Add Lienol's Packages
git clone --depth=1 https://github.com/Lienol/openwrt-package
rm -rf ../../customfeeds/luci/applications/luci-app-kodexplorer
rm -rf ../../customfeeds/luci/applications/luci-app-socat
rm -rf ../../customfeeds/luci/applications/luci-app-ipsec-server
rm -rf openwrt-package/verysync
rm -rf openwrt-package/luci-app-verysync

# Add luci-app-netdata
rm -rf ../../customfeeds/luci/applications/luci-app-netdata
git clone --depth=1 https://github.com/sirpdboy/luci-app-netdata

# Add luci-app-partexp
git clone --depth=1 https://github.com/sirpdboy/luci-app-partexp

# Add luci-app-netspeedtest
git clone --depth=1 https://github.com/sirpdboy/NetSpeedTest

# Add luci-app-autotimeset
git clone --depth=1 https://github.com/sirpdboy/luci-app-autotimeset
sed -i "s/\"control\"/\"system\"/g" luci-app-autotimeset/luasrc/controller/autotimeset.lua

# Add luci-app-dockerman
rm -rf ../../customfeeds/luci/collections/luci-lib-docker
rm -rf ../../customfeeds/luci/applications/luci-app-docker
rm -rf ../../customfeeds/luci/applications/luci-app-dockerman
github_partial_clone lisaac luci-app-dockerman use_default_branch applications/luci-app-dockerman luci-app-dockerman
github_partial_clone lisaac luci-lib-docker use_default_branch collections/luci-lib-docker luci-lib-docker

# Add mosdns
rm -rf ../../customfeeds/packages/net/mosdns
rm -rf ../../customfeeds/packages/utils/v2dat
rm -rf ../../customfeeds/luci/applications/luci-app-mosdns
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns

# apppppppp
# git clone --depth=1 https://github.com/DHDAXCW/dhdaxcw-app

# Add luci-app-ssr-plus
git clone --depth=1 https://github.com/fw876/helloworld
# git clone --depth=1 -b patch-1 https://github.com/MilesPoupart/helloworld

# Add luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall-packages

# Add luci-app-unblockneteasemusic
rm -rf ../../customfeeds/luci/applications/luci-app-unblockmusic
git clone --depth=1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git

# Add luci-app-vssr <M>
git clone --depth=1 https://github.com/jerrykuku/lua-maxminddb.git
git clone --depth=1 https://github.com/MilesPoupart/luci-app-vssr

# Add luci-proto-minieap
git clone --depth=1 https://github.com/ysc3839/luci-proto-minieap

# Add luci-app-onliner (need luci-app-nlbwmon)
git clone --depth=1 https://github.com/rufengsuixing/luci-app-onliner

# Add ServerChan
rm -rf ../../customfeeds/luci/applications/luci-app-serverchan
git clone -b openwrt-18.06 --depth=1 https://github.com/tty228/luci-app-wechatpush.git

# Add ddnsto & linkease
github_partial_clone linkease nas-packages-luci use_default_branch luci/luci-app-ddnsto luci-app-ddnsto
github_partial_clone linkease nas-packages-luci use_default_branch luci/luci-app-linkease luci-app-linkease
github_partial_clone linkease nas-packages use_default_branch network/services/ddnsto ddnsto
github_partial_clone linkease nas-packages use_default_branch network/services/linkease linkease
github_partial_clone linkease nas-packages use_default_branch network/services/linkmount linkmount
github_partial_clone linkease nas-packages use_default_branch multimedia/ffmpeg-remux ffmpeg-remux

# Add OpenClash
github_partial_clone vernesong OpenClash use_default_branch luci-app-openclash luci-app-openclash

# Add luci-app-poweroff
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff

# Add luci-theme
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config
rm -rf ../../customfeeds/luci/themes/luci-theme-argon
rm -rf ../../customfeeds/luci/applications/luci-app-argon-config
rm -rf ../../customfeeds/luci/themes/luci-theme-argon-mod
rm -rf ./luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
cp -f $GITHUB_WORKSPACE/data/bg1.jpg luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
git clone https://github.com/DHDAXCW/theme
rm -rf ../../customfeeds/luci/themes/luci-theme-design
rm -rf ../../customfeeds/luci/applications/luci-app-design-config
git clone --depth=1 https://github.com/MilesPoupart/luci-app-design-config
git clone --depth=1 https://github.com/MilesPoupart/luci-theme-design

# Add subconverter
git clone --depth=1 https://github.com/tindy2013/openwrt-subconverter

# Add luci-app-lucky
rm -rf ../../customfeeds/packages/net/lucky
git clone --depth=1 https://github.com/gdy666/luci-app-lucky

# alist
rm -rf ../../customfeeds/packages/net/alist
rm -rf ../../customfeeds/luci/applications/luci-app-alist
git clone -b lua --depth=1 https://github.com/sbwml/luci-app-alist

# qbittorrent
rm -rf ../../customfeeds/packages/net/qBittorrent
rm -rf ../../customfeeds/packages/libs/rblibtorrent
git clone --depth=1 https://github.com/sbwml/luci-app-qbittorrent
rm -rf luci-app-qbittorrent/luci-app-qbittorrent

# Add luci-app-smartdns & smartdns
rm -rf ../../customfeeds/luci/applications/luci-app-smartdns
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns

# Add luci-app-wolplus
github_partial_clone sundaqiang openwrt-packages use_default_branch luci-app-wolplus luci-app-wolplus

# Add apk (Apk Packages Manager)
# rm -rf ../../customfeeds/packages/utils/apk
# github_partial_clone openwrt packages use_default_branch utils/apk apk

# Add OpenAppFilter
git clone --depth=1 https://github.com/destan19/OpenAppFilter

# Add luci-aliyundrive-webdav
rm -rf ../../customfeeds/luci/applications/luci-app-aliyundrive-webdav
rm -rf ../../customfeeds/packages/multimedia/aliyundrive-webdav
github_partial_clone messense aliyundrive-webdav use_default_branch openwrt/aliyundrive-webdav aliyundrive-webdav
github_partial_clone messense aliyundrive-webdav use_default_branch openwrt/luci-app-aliyundrive-webdav luci-app-aliyundrive-webdav

# easytier
git clone --depth=1 https://github.com/EasyTier/luci-app-easytier.git

popd

# Add Pandownload
pushd package/lean
github_partial_clone immortalwrt packages use_default_branch net/pandownload-fake-server pandownload-fake-server
popd

# Mod zzz-default-settings
pushd package/lean/default-settings/files
sed -i '/http/d' zzz-default-settings
sed -i '/18.06/d' zzz-default-settings
export orig_version=$(cat "zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
export date_version=$(date -d "$(rdate -n -4 -p ntp.aliyun.com)" +'%Y-%m-%d')
sed -i "s/${orig_version}/${orig_version} (${date_version})/g" zzz-default-settings
popd

# Fix libssh
pushd feeds/packages/libs
rm -rf libssh
github_partial_clone openwrt packages use_default_branch libs/libssh libssh
popd

# rm -rf nas-packages-luci/luci/luci-app-istorex
# rm -rf package/feeds/packages/libmbim
# rm -rf package/feeds/packages/lame
# rm -rf package/feeds/packages/apk
# rm -rf package/feeds/packages/adguardhome

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd


# Modify default IP
sed -i 's/192.168.1.1/192.168.4.1/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.4.1/g' package/base-files/luci2/bin/config_generate
sed -i '/uci commit system/i\uci set system.@system[0].hostname='MilesWrt'' package/lean/default-settings/files/zzz-default-settings
sed -i "s/LEDE /MilesPoupart @ MilesWrt /g" package/lean/default-settings/files/zzz-default-settings
# Test kernel 6.1
# sed -i 's/6.1/5.15/g' target/linux/x86/Makefile

rm -rf target/linux/x86/base-files/etc/board.d/02_network
cp -f $GITHUB_WORKSPACE/02_network target/linux/x86/base-files/etc/board.d/02_network
# wget -P target/linux/x86/base-files/etc/board.d https://raw.githubusercontent.com/DHDAXCW/lede-rockchip/stable/target/linux/x86/base-files/etc/board.d/02_network

rm package/base-files/files/etc/banner
touch package/base-files/files/etc/banner
echo -e "------------------------------------" >> package/base-files/files/etc/banner
echo -e "   __  ____ __      _      __    __ " >> package/base-files/files/etc/banner
echo -e "  /  |/  (_) /__ __| | /| / /___/ /_" >> package/base-files/files/etc/banner
echo -e " / /|_/ / / / -_|_-< |/ |/ / __/ __/" >> package/base-files/files/etc/banner
echo -e "/_/  /_/_/_/\__/___/__/|__/_/  \__/ " >> package/base-files/files/etc/banner
echo -e "------------------------------------" >> package/base-files/files/etc/banner
echo -e "MilesPoupart's MilesWrt built on "$(date +%Y.%m.%d)"\n------------------------------------" >> package/base-files/files/etc/banner

# cp -r ../target/linux/generic/pending-6.1/ ./target/linux/generic/
