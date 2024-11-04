#!/bin/bash

now_dir=$(pwd)
clone_dir="${now_dir}/../git_clone_temporary_space"
mkdir -p "$clone_dir"

function github_partial_clone() {
    local author_name="$1"
    local repository_name="$2"
    local branch_name="$3"
    local required_dir="$4"
    local saved_dir="$5"

    local url_prefix="https://github.com/"
    local branch_option=""

    if [ "$branch_name" != "use_default_branch" ]; then
        branch_option="-b ${branch_name}"
    fi

    mkdir -p "$saved_dir"

    # Clone the repository only if it hasn't been cloned yet
    if [ ! -d "${clone_dir}/${repository_name}" ]; then
        git clone --depth=1 ${branch_option} "${url_prefix}${author_name}/${repository_name}.git" "${clone_dir}/${repository_name}"
    fi

    # Move required files and clean up
    mv "${clone_dir}/${repository_name}/${required_dir}/"* "$saved_dir"
    rm -rf "${clone_dir}/${repository_name}"
}

# Svn checkout packages from immortalwrt's repository
pushd customfeeds

# Function to clone and clean up
function clone_and_cleanup() {
    local dir_path="$1"
    local author="$2"
    local repo="$3"
    local branch="$4"
    local required="$5"
    local saved="$6"

    rm -rf "$dir_path"
    github_partial_clone "$author" "$repo" "$branch" "$required" "$saved"
}

# Add luci-app-eqos
clone_and_cleanup "luci/applications/luci-app-eqos" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-eqos" "luci/applications/luci-app-eqos"

# Add luci-app-softethervpn
clone_and_cleanup "luci/applications/luci-app-softethervpn" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-softethervpn" "luci/applications/luci-app-softethervpn"

# Add luci-proto-modemmanager
clone_and_cleanup "luci/protocols/luci-proto-modemmanager" "immortalwrt" "luci" "use_default_branch" "protocols/luci-proto-modemmanager" "luci/protocols/luci-proto-modemmanager"

# Add dufs
clone_and_cleanup "luci/applications/luci-app-dufs" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-dufs" "luci/applications/luci-app-dufs"
clone_and_cleanup "packages/net/dufs" "immortalwrt" "packages" "use_default_branch" "net/dufs" "packages/net/dufs"

# Add tmate
git clone --depth=1 https://github.com/immortalwrt/openwrt-tmate

# Add gotop
clone_and_cleanup "packages/admin/gotop" "immortalwrt" "packages" "openwrt-18.06" "admin/gotop" "packages/admin/gotop"

# Add minieap
clone_and_cleanup "packages/net/minieap" "immortalwrt" "packages" "use_default_branch" "net/minieap" "packages/net/minieap"
clone_and_cleanup "luci/applications/luci-app-minieap" "immortalwrt" "luci" "use_default_branch" "applications/luci-app-minieap" "luci/applications/luci-app-minieap"

# Replace watchcat with the official version
clone_and_cleanup "packages/utils/watchcat" "openwrt" "packages" "use_default_branch" "utils/watchcat" "packages/utils/watchcat"

# Replace adguardhome
clone_and_cleanup "packages/net/adguardhome" "immortalwrt" "packages" "use_default_branch" "net/adguardhome" "packages/net/adguardhome"

# replace luci-app-smartdns
rm -rf luci/applications/luci-app-smartdns
git clone https://github.com/pymumu/luci-app-smartdns luci/applications/luci-app-smartdns

popd

# Set to local feeds
pushd customfeeds/packages
export packages_feed="$(pwd)"
popd

pushd customfeeds/luci
export luci_feed="$(pwd)"
popd

sed -i '/src-git packages/d' feeds.conf.default
echo "src-link packages $packages_feed" >> feeds.conf.default
sed -i '/src-git luci/d' feeds.conf.default
echo "src-link luci $luci_feed" >> feeds.conf.default

echo >> feeds.conf.default
echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default
./scripts/feeds update istore
./scripts/feeds install -d y -p istore luci-app-store

# Update feeds
./scripts/feeds update -a