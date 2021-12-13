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

# you can export GIT_OPUS_UPSTREAM=git@xx:yy/opusfile.git use your mirror
if [[ "$GIT_OPUS_UPSTREAM" != "" ]] ;then
    export GIT_UPSTREAM="$GIT_OPUS_UPSTREAM"
else
    export GIT_UPSTREAM=https://gitlab.xiph.org/xiph/opusfile.git
fi

export GIT_LOCAL_REPO=extra/opus
export GIT_COMMIT=v0.12
export DIR_NAME=opus

./tools/init-repo.sh $*