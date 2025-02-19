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
        echo "will use sourcecode install ${name}."
        install_libmp3lame
        configure_libmp3lame
        echo "[✅] ${name}: $(eval $name --version)"
        return
    fi

    local r=$(brew list | grep "^$name$")
    if [[ -z $r ]]; then
        echo "will use brew install ${name}."
        brew install "$name"
    fi

    echo "[✅] ${name}: $(eval $name --version)"
}

# Install libmp3lame 3.99.5
function install_libmp3lame() {
    # Create a temporary directory
    local tmp_dir
    tmp_dir=$(mktemp -d)

    # Change to the temporary directory
    pushd "$tmp_dir" > /dev/null || exit 1

    # Install dependencies
    brew install automake autoconf libtool nasm

    # Download LAME 3.99.5 source code
    curl -LO https://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
    tar -xvzf lame-3.99.5.tar.gz
    cd lame-3.99.5 || exit 1
    curl -LO 'https://git.savannah.gnu.org/cgit/config.git/plain/config.sub'
    curl -LO 'https://git.savannah.gnu.org/cgit/config.git/plain/config.guess'

    # Configure, compile, and install
    ./configure \
        --prefix=/usr/local \
        --enable-static \
        --disable-shared \
        CFLAGS="-arch arm64 -O2 -fPIC" \
        LDFLAGS="-arch arm64"
    make -j$(sysctl -n hw.ncpu)
    sudo make install

    # Return to the original directory and remove the temporary directory
    popd > /dev/null
    rm -rf "$tmp_dir"
}

# Configure mp3lame.pc for pkg-config
function configure_libmp3lame() {
    # Ensure the pkg-config directory exists
    sudo mkdir -p /usr/local/lib/pkgconfig

    # Create the mp3lame.pc file
    sudo tee /usr/local/lib/pkgconfig/mp3lame.pc > /dev/null <<EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: mp3lame
Description: LAME MP3 encoder library
Version: 3.99.5
Libs: -L\${libdir} -lmp3lame
Cflags: -I\${includedir}
EOF

    # Configure PKG_CONFIG_PATH globally using /etc/paths.d/
    echo "/usr/local/lib/pkgconfig" | sudo tee /etc/paths.d/mp3lame > /dev/null
}

export -f install_depends
export -f install_libmp3lame
export -f configure_libmp3lame