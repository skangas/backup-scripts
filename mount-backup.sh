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
VGS="skbak1 skbak2"
MAPPING_NAME="bak-home"

# INTERNAL VARIABLES
SCRIPT=$(readlink -f $0)
PIDFILE=/var/run/mkbackup.sh
lvs=()

function usage {
    echo "usage: $SCRIPT [mount|umount]"
}

function run_vgscan {
    # Find out which volume groups exists
    vgscan &> /dev/null
    vgs_exists=()
    for vg in $VGS; do
        vgs $vg &> /dev/null \
            && vgs_exists+=($vg)
    done
}

if [ "$1" == "mount" ]; then
    run_vgscan
    for vg in "${vgs_exists[@]}"; do
        # vgchange will touch all of them - we only need one
        # vgchange -a y $vg &> /dev/null
        lvchange -a y $vg/home
        cryptsetup open --type luks --key-file $KEYFILE \
                   /dev/$vg/home $MAPPING_NAME
        mount /dev/mapper/$MAPPING_NAME $MOUNTPOINT
        if [ `mount | grep "on $MOUNTPOINT type" > /dev/null` ]; then
            echo "Unable to mount $vg: " `lvscan`
            exit 1
        fi
    done
elif [ "$1" == "umount" ]; then
    run_vgscan
    umount $MOUNTPOINT &> /dev/null
    for vg in "${vgs_exists[@]}"; do
        cryptsetup close $MAPPING_NAME
        # lvchange -a n $vg/home
        vgchange -a n $vg > /dev/null
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
