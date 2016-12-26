#!/bin/bash

KEYFILE=/root/.luks-backup-key-2017-12
MOUNTPOINT=/mnt/backup
VGS="skbak1 skbak2"
MAPPING_NAME="bak-home"

PIDFILE=/var/run/mkbackup.sh
lvs=()

function usage {
    echo "usage: $0 [mount|umount]"
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
    # First unmount, just to be sure...
    umount $MOUNTPOINT &> /dev/null

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
else
    echo "$0: Unknown operation '$1'"
fi
