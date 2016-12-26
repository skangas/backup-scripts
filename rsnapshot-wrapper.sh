#!/bin/bash

# CONFIGURATION
BACKUP_DIRECTORY=/mnt/backup

# INTERNAL VARIABLES
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`

# Mount
$SCRIPTPATH/mount-backup.sh mount #&> /dev/null
[ $? -eq 0 ] || exit 1

# Run rsnapshot
nice -n 19 ionice -c 3 rsnapshot "$@"

# Unmount
$SCRIPTPATH/mount-backup.sh umount
[ $? -eq 0 ] || exit 1

exit 0
