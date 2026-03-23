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

log_message() {
    echo "$(date +"[%Y-%m-%d %H:%M:%S]") $1" >>"$LOG_FILE"
}

get_speedtest_client_index() {
    index="$(rbuscli getvalue Device.SoftwareModules.DeploymentUnit.*.URL | grep -B2 speedtest_client | grep URL | awk '{print $3}' | cut -d'.' -f4)"

    while [ -z "$index" ]; do
        log_message "Waiting for speedtest-client package to be added to the data model..."
        index="$(rbuscli getvalue Device.SoftwareModules.DeploymentUnit.*.URL | grep -B2 speedtest_client | grep URL | awk '{print $3}' | cut -d'.' -f4)"
        sleep 5
    done

    log_message "Got speedtest-client index on the data model is $index"
    echo "$index"
}

install_speedtest_client_with_dsm() {
    log_message "Installing speedtest-client package for $BOX_TYPE via DSM"
    rbuscli method_values "Device.SoftwareModules.InstallDU()" URL string "$SPEEDTEST_CLIENT_URL"
    index="$(get_speedtest_client_index)"

    status="$(rbuscli getvalue "Device.SoftwareModules.DeploymentUnit.$index.Status" | grep Value | awk '{print $3}')"
    while [ "$status" != "Installed" ]; do
        log_message "Current status of speedtest-client package is $status. Waiting for it to be \"Installed\"..."
        sleep 5
        status="$(rbuscli getvalue "Device.SoftwareModules.DeploymentUnit.$index.Status" | grep Value | awk '{print $3}')"
    done

    log_message "Current status of speedtest-client package is $status"
}
