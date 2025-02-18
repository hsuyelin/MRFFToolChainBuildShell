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

if [[ "$MR_PLAT" != 'macos' ]]; then
    export MR_FORCE_CROSS=true
fi

if [[ "$MR_PLAT" == 'ios' ]]; then
    export MR_DEFAULT_ARCHS="arm64 arm64_simulator x86_64_simulator"
    elif [[ "$MR_PLAT" == 'macos' ]]; then
    export MR_DEFAULT_ARCHS="x86_64 arm64"
    elif [[ "$MR_PLAT" == 'tvos' ]]; then
    export MR_DEFAULT_ARCHS="arm64 arm64_simulator x86_64_simulator"
fi

# Number of physical cores in the system to facilitate parallel assembling
export MR_HOST_NPROC=$(sysctl -n hw.physicalcpu)
# for ffmpeg --target-os
export MR_TAGET_OS="darwin"
export DEBUG_INFORMATION_FORMAT=dwarf-with-dsym

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
    curl -L "$url" -o "$tar_file"

    echo "[✅] libmp3lame: Extracting libmp3lame..."
    tar -xzf "$tar_file" -C "$temp_dir"

    cd "$temp_dir/lame-3.100" || exit

    echo "[✅] libmp3lame: Configuring libmp3lame..."
    ./configure \
        --prefix=/usr/local \
        --host=arm-apple-darwin \
        --enable-static \
        --disable-shared \
        CFLAGS="-arch arm64 -O2 -fPIC" \
        LDFLAGS="-arch arm64"

    echo "[✅] libmp3lame: Compiling libmp3lame..."
    make -j$(sysctl -n hw.logicalcpu)

    echo "[✅] libmp3lame: Installing libmp3lame..."
    sudo make install

    echo "[✅] libmp3lame: Cleaning up..."
    rm -rf "$temp_dir"

    export PATH="/usr/local/bin:$PATH"
    echo "[✅] libmp3lame: Setting up environment variables..."

    cd "$old_dir"
    echo "[✅] libmp3lame installation complete!"
}

export -f install_depends
export -f install_libmp3lame