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

# This script is based on projects below
# https://github.com/bilibili/ijkplayer

set -e

error_handler() {
    echo "An error occurred!"
    tail -n20 ${MR_BUILD_SOURCE}/ffbuild/config.log
}

trap 'error_handler' ERR

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

# ffmpeg config options
source $MR_SHELL_CONFIGS_DIR/ffconfig/module.sh
source $MR_SHELL_CONFIGS_DIR/ffconfig/auto-detect-third-libs.sh

CFG_FLAGS=
CFG_FLAGS="$CFG_FLAGS $COMMON_FF_CFG_FLAGS"
CFG_FLAGS="$CFG_FLAGS $THIRD_CFG_FLAGS"
# CFG_FLAGS="$CFG_FLAGS --enable-demuxer=dash --enable-libxml2"
# # use system xml2 lib
# XML_CFLAGS=
# C_FLAGS="$C_FLAGS $XML_CFLAGS"
# LDFLAGS="$XML_CFLAGS -L${MR_TOOLCHAIN_ROOT}/lib -lxml2"

# Android 15 with 16 kb page size support
# https://developer.android.com/guide/practices/page-sizes#compile-r27
# EXTRA_LDFLAGS="-Wl,-z,max-page-size=16384 -fuse-ld=lld"
EXTRA_LDFLAGS=
C_FLAGS="$C_FLAGS $MR_OTHER_CFLAGS"
LDFLAGS="$C_FLAGS $EXTRA_LDFLAGS"
EXTRA_LIBS="-lpthread"

# Check if libmp3lame is installed and update CFLAGS and LDFLAGS
LIBMP3LAME_INCLUDE="/opt/local/lame/lame-3.99.5/include"
LIBMP3LAME_LIB="/opt/local/lame/lame-3.99.5/lib"

if [ -d "$LIBMP3LAME_INCLUDE" ]; then
    C_FLAGS="$C_FLAGS -I$LIBMP3LAME_INCLUDE"
    echo "[✅] Added LAME include path to CFLAGS: $LIBMP3LAME_INCLUDE"
else
    echo "[❌] LAME include path not found: $LIBMP3LAME_INCLUDE"
fi

if [ -d "$LIBMP3LAME_LIB" ]; then
    LDFLAGS="$LDFLAGS -L$LIBMP3LAME_LIB"
    echo "[✅] Added LAME library path to LDFLAGS: $LIBMP3LAME_LIB"
else
    echo "[❌] LAME library path not found: $LIBMP3LAME_LIB"
fi

echo "----------------------"
echo "[*] configure"

if [[ ! -d $MR_BUILD_SOURCE ]]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find $MR_BUILD_SOURCE directory for $MR_BUILD_NAME"
    echo "!! Run 'init-*.sh' first"
    echo ""
    exit 1
fi

cd $MR_BUILD_SOURCE

if [[ -f "./config.h" ]]; then
    echo 'reuse configure'
else
    echo
    echo "CC: $MR_CC"
    echo "CFLAGS: $C_FLAGS"
    echo "LDFLAG:$LDFLAGS"
    echo "FF_CFG_FLAGS: $CFG_FLAGS"
    echo

    ./configure \
        $CFG_FLAGS \
        --cc=${MR_TRIPLE_CC} \
        --as=${MR_TRIPLE_CC} \
        --ld=${MR_TRIPLE_CC} \
        --ar=${MR_AR} \
        --nm=${MR_NM} \
        --strip=${MR_STRIP} \
        --ranlib=${MR_RANLIB} \
        --extra-cflags="-I/usr/local/include $C_FLAGS" \
        --extra-cxxflags="$C_FLAGS" \
        --extra-ldflags="-L/usr/local/lib $LDFLAGS" \
        --pkg-config=${MR_PKG_CONFIG_EXECUTABLE} \
        --extra-libs="$EXTRA_LIBS"
fi

#----------------------
echo "----------------------"
echo "[*] compile"

# V=1
make -j$MR_HOST_NPROC >/dev/null

echo "----------------------"
echo "[*] install"

cp config.* $MR_BUILD_PREFIX
make install >/dev/null
mkdir -p $MR_BUILD_PREFIX/include/libffmpeg
cp -f config.h $MR_BUILD_PREFIX/include/libffmpeg/
[ -e config_components.h ] && cp -f config_components.h $MR_BUILD_PREFIX/include/libffmpeg/