#!/bin/bash

# Copyright (C) 2016 Stefan Kangas.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# CONFIGURATION
KEYFILE=/root/.luks-backup-key-2017-12
MOUNTPOINT=/mnt/backup
VOLUME_GROUPS="skbak1 skbak2"
MAPPING_NAME="bak-home"

# PATHS
MOUNT="/bin/mount"
VGS="/sbin/vgs"
VGSCAN="/sbin/vgscan"
LVCHANGE="/sbin/lvchange"
VGCHANGE="/sbin/vgchange"
CRYPTSETUP="/sbin/cryptsetup"

# INTERNAL VARIABLES
SCRIPT=$(readlink -f $0)
PIDFILE=/var/run/mount-backup.sh
vgs_exists=()

function usage {
    echo "usage: $SCRIPT [mount|umount]"
}

function run_vgscan {
    # Find out which volume groups exists
    $VGSCAN &> /dev/null
    for vg in $VOLUME_GROUPS; do
        $VGS $vg &> /dev/null \
            && vgs_exists+=($vg)
    done
}

if [ "$1" == "mount" ]; then
    run_vgscan
    if [ "${#vgs_exists[@]}" == 0 ]; then
        echo "No volume groups found  (tried: $VOLUME_GROUPS)"
        exit 1
    fi
    for vg in "${vgs_exists[@]}"; do
        # vgchange will touch all of them - we only need one
        # $VGCHANGE -a y $vg &> /dev/null
        $LVCHANGE -a y $vg/home
        $CRYPTSETUP open --type luks --key-file $KEYFILE \
                   /dev/$vg/home $MAPPING_NAME
        $MOUNT /dev/mapper/$MAPPING_NAME $MOUNTPOINT
        if [ `mount | grep "on $MOUNTPOINT type" > /dev/null` ]; then
            echo "Unable to mount $vg: " `lvscan`
            exit 1
        fi
    done
elif [ "$1" == "umount" ]; then
    run_vgscan
    umount $MOUNTPOINT &> /dev/null
    for vg in "${vgs_exists[@]}"; do
        $CRYPTSETUP close $MAPPING_NAME
        # $LVCHANGE -a n $vg/home
        $VGCHANGE -a n $vg > /dev/null
        # ok to remove usb device at this point...
    done
elif [ "$1" == "" ]; then
    usage
    exit 2
else
    usage
    echo "$SCRIPT: Unknown operation '$1'"
    exit 1
fi

exit 0
