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
# 
# 
# brew install nasm
# If you really want to compile without asm, configure with --disable-asm.

# LIB_DEPENDS_BIN using string because bash can't export array chttps://stackoverflow.com/questions/5564418/exporting-an-array-in-bash-script
# configure: error: Package requirements (openssl) were not met

export LIB_NAME='mp3lame'
export LIPO_LIBS="libmp3lame"
export LIB_DEPENDS_BIN="autoconf automake libtool"
export CMAKE_TARGET_NAME=mp3lame
export GIT_LOCAL_REPO=extra/mp3lame
export GIT_COMMIT=lame3_100_with_psymodel_v3_99_5
export REPO_DIR=mp3lame
export GIT_REPO_VERSION=3.100
export PRE_COMPILE_TAG=mp3lame-3.100-250212113037

# you can export GIT_OPUS_UPSTREAM=git@xx:yy/opusfile.git use your mirror
if [[ "$GIT_MP3LAME_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_MP3LAME_UPSTREAM"
else
    export GIT_UPSTREAM=https://github.com/rbrito/deprecated-lame-mirror.git
fi