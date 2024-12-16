#! /usr/bin/env bash
#
# Copyright (C) 2022 Matt Reach<qianlongxu@gmail.com>

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


function install_plat() {
    
    export XC_DOWNLOAD_ONAME="$LIB_NAME-apple-xcframework-$VER.zip"
    export XC_DOWNLOAD_URL="https://github.com/debugly/MRFFToolChainBuildShell/releases/download/$PRE_COMPILE_TAG/$XC_DOWNLOAD_ONAME"
    export XC_UNCOMPRESS_DIR="$XC_XCFRMK_DIR"

    ./download-uncompress.sh
}

if test -z $PRE_COMPILE_TAG ;then
    echo "tag can't be nil"
    usage
    exit
fi

# opus-1.3.1-231124151836
LIB_NAME=$(echo $PRE_COMPILE_TAG | awk -F - '{print $1}')
VER=$(echo $PRE_COMPILE_TAG | awk -F - '{print $2}')

install_plat