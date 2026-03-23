#!/bin/sh
#######################################################################################
# If not stated otherwise in this file or this component's Licenses.txt file the
# following copyright and licenses apply:
#
#  Copyright 2018 RDK Management
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#######################################################################################

. "$(dirname "$0")/speedtest_shared.sh"  

#This script is used to execute speedtest-client binary to retrieve version
LOG_FILE=/tmp/.speedtest-client-version.log

if [ -f /usr/bin/speedtest-client ]; then
    /usr/bin/speedtest-client -v > "$LOG_FILE"
elif [ -f /etc/dsm.config ]; then
    # If the package already exists, then no need to install it again. Just set the state to active.
    if [ ! -d /apps/packages/speedtest_client ]; then
        install_speedtest_client_with_dsm
    fi

    LD_LIBRARY_PATH="/apps/packages/speedtest_client/rootfs/usr/lib" /apps/packages/speedtest_client/rootfs/usr/bin/speedtest-client -v > "$LOG_FILE"
else
    echo "Unsupported device model" > "$LOG_FILE"
fi
