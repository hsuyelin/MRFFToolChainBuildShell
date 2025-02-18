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

    local r=$(brew list | grep "^$name$")
    if [[ -z $r ]]; then
        echo "will use brew install ${name}."
        brew install "$name"
        if [[ "$name" == "lame" ]]; then
            configure_libmp3lame
        fi
    fi

    echo "[✅] ${name}: $(eval $name --version)"
}

function configure_libmp3lame() {
    cat <<EOF > /opt/homebrew/lib/pkgconfig/mp3lame.pc
prefix=/opt/homebrew
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${exec_prefix}/include

Name: LAME
Description: LAME MP3 Encoder
Version: 3.100
Cflags: -I\${includedir}
Libs: -L\${libdir} -lmp3lame
EOF
    grep -q "PKG_CONFIG_PATH=/opt/homebrew/lib/pkgconfig" ~/.bashrc || \
    echo "export PKG_CONFIG_PATH=/opt/homebrew/lib/pkgconfig:\$PKG_CONFIG_PATH" >> ~/.bashrc
    source ~/.bashrc
    pkg-config --cflags --libs mp3lame && echo "[✅] LAME: installed and configured successfully!" || echo "Configuration failed."
}

export -f install_depends
export -f configure_libmp3lame