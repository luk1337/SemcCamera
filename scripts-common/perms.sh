#!/bin/bash

PKGS=`adb shell pm list packages | grep package:com.sony | grep -v package:com.sony.simdetect | cut -b9- | sort`

for pkg in $PKGS; do
    PERMS=`adb shell pm dump "${pkg}" | grep granted=false | grep -o "android.permission.[A-Z_]\+" | sort`

    if [[ ! -z "${PERMS}" ]]; then
        echo "    <exception package=\"${pkg}\">"
        for perm in $PERMS; do
            echo "        <permission name=\"${perm}\" fixed=\"false\"/>"
        done
        echo "    </exception>"
        echo
    fi
done
