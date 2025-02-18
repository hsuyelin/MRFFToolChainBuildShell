#! /usr/bin/env bash
#
# Copyright (C) 2021 Matt Reach<qianlongxu@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# https://github.com/Javernaut/ffmpeg-android-maker

function install_depends() {
    local name="$1"

    if [[ "$name" == "libmp3lame" ]]; then
        install_libmp3lame
        return
    fi

    local r=$(brew list | grep "^$name$")
    if [[ -z $r ]]; then
        echo "will use brew install ${name}."
        brew install "$name"
    fi

    echo "[✅] ${name}: $(eval $name --version)"
}

function install_libmp3lame() {
    local url="https://nchc.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
    local temp_dir=$(mktemp -d)
    local tar_file="$temp_dir/lame.tar.gz"
    local old_dir=$(pwd)
    
    echo "[✅] libmp3lame: Downloading libmp3lame..."
    curl -L "$url" -o "$tar_file" || { echo "[❌] Download failed!"; exit 1; }
    
    echo "[✅] libmp3lame: Extracting libmp3lame..."
    tar -xzf "$tar_file" -C "$temp_dir" || { echo "[❌] Extraction failed!"; exit 1; }
    
    cd "$temp_dir/lame-3.100" || exit

    echo "[✅] libmp3lame: Configuring libmp3lame..."
    ./configure \
        --prefix=/usr/local \
        --host=arm-apple-darwin \
        --enable-static \
        --disable-shared \
        CFLAGS="-arch arm64 -O2 -fPIC" \
        LDFLAGS="-arch arm64" || { echo "[❌] Configuration failed!"; exit 1; }
    
    echo "[✅] libmp3lame: Compiling libmp3lame..."
    make -j$(sysctl -n hw.logicalcpu) || { echo "[❌] Compilation failed!"; exit 1; }
    
    echo "[✅] libmp3lame: Installing libmp3lame..."
    sudo make install || { echo "[❌] Installation failed!"; exit 1; }

    local pkgconfig_dir="/usr/local/lib/pkgconfig"
    sudo mkdir -p "$pkgconfig_dir"
    sudo tee "$pkgconfig_dir/mp3lame.pc" > /dev/null <<EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: mp3lame
Description: LAME MP3 encoding library
Version: 3.100
Libs: -L\${libdir} -lmp3lame
Cflags: -I\${includedir}
EOF
    echo "[✅] libmp3lame: Created mp3lame.pc"

    export PATH="/usr/local/bin:$PATH"
    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

    echo "[✅] libmp3lame: Setting up environment variables..."

    echo "[ℹ️] Checking installation..."
    lame_version=$(lame --version 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        echo "[✅] LAME version: $lame_version"
    else
        echo "[❌] LAME command not found!"
        exit 1
    fi

    echo "[ℹ️] Checking pkg-config..."
    pkg-config --libs mp3lame
    if [[ $? -eq 0 ]]; then
        echo "[✅] pkg-config found mp3lame!"
    else
        echo "[❌] pkg-config could not find mp3lame!"
        exit 1
    fi

    echo "[✅] libmp3lame: Cleaning up..."
    rm -rf "$temp_dir"

    cd "$old_dir"
    echo "[🎉] libmp3lame installation complete!"
}

case "$OSTYPE" in
  darwin*)  HOST_TAG="darwin-x86_64"; export -f install_depends; export -f install_libmp3lame ;;
  linux*)   HOST_TAG="linux-x86_64" ;;
  msys)
    case "$(uname -m)" in
      x86_64) HOST_TAG="windows-x86_64" ;;
      i686)   HOST_TAG="windows" ;;
    esac
  ;;
esac

if [[ $OSTYPE == "darwin"* ]]; then
  HOST_NPROC=$(sysctl -n hw.physicalcpu)
else
  HOST_NPROC=$(nproc)
fi

export MR_FORCE_CROSS=true
# The variable is used as a path segment of the toolchain path
export MR_HOST_TAG="$HOST_TAG"
# Number of physical cores in the system to facilitate parallel assembling
export MR_HOST_NPROC="$HOST_NPROC"
# for ffmpeg --target-os
export MR_TAGET_OS="android"
# 
export MR_PLAT="android"
# Using Make from the Android SDK
export MR_MAKE_EXECUTABLE=${ANDROID_NDK_HOME}/prebuilt/${MR_HOST_TAG}/bin/make
# Init Android plat env
export MR_DEFAULT_ARCHS="armv7a arm64 x86 x86_64"