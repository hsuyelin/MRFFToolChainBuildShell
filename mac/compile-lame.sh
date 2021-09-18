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

export LIB_NAME='lame'
export LIPO_LIBS="libmp3lame"

which nasm
if [[ $? -eq 0 ]];then
    echo $(nasm --version)
else
    brew install nasm
fi

source ./common-env.sh
./tools/compile-any.sh "$*"

if [[ $? -eq 0 ]];then
    echo "🎉  Congrats"
    echo "🚀  ${LIB_NAME} successfully built."
fi