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

set -e

THIS_DIR=$(DIRNAME=$(dirname "$0"); cd "$DIRNAME"; pwd)
cd "$THIS_DIR"

echo "=== [$0] check env begin==="
env_assert "MR_ARCH"
env_assert "MR_BUILD_NAME"
env_assert "MR_CC"
env_assert "MR_BUILD_SOURCE"
env_assert "MR_BUILD_PREFIX"
env_assert "MR_SYS_ROOT"
env_assert "MR_HOST_NPROC"
echo "MR_DEBUG:$MR_DEBUG"
echo "===check env end==="

CFG_FLAGS="--prefix=$MR_BUILD_PREFIX --enable-static --disable-shared --silent"
CFLAGS="-arch $MR_ARCH $MR_OTHER_CFLAGS"

# for cross compile
if [[ $(uname -m) != "$MR_ARCH" || "$MR_FORCE_CROSS" ]];then
    echo "[*] cross compile, on $(uname -m) compile $MR_PLAT $MR_ARCH."
    # https://www.gnu.org/software/automake/manual/html_node/Cross_002dCompilation.html
    CFLAGS="$CFLAGS -isysroot $MR_SYS_ROOT"
    CFG_FLAGS="$CFG_FLAGS --host=$MR_ARCH-apple-darwin --with-sysroot=$MR_SYS_ROOT"
fi

cd $MR_BUILD_SOURCE

echo 
echo "CC: $MR_CC"
echo "CFG_FLAGS: $CFG_FLAGS"
echo "CFLAGS: $CFLAGS"
echo 

echo "----------------------"
echo "[*] configurate $LIB_NAME"
echo "----------------------"

echo "generate configure"

./autogen.sh 1>/dev/null

./configure $CFG_FLAGS \
   CC="$MR_CC" \
   CFLAGS="$CFLAGS" \
   LDFLAGS="$CFLAGS" 1>/dev/null

#----------------------
echo "----------------------"
echo "[*] compile $LIB_NAME"
echo "----------------------"

make -j$MR_HOST_NPROC install 1>/dev/null