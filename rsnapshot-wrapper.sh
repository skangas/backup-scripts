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
BACKUP_DIRECTORY=/mnt/backup
RSNAPSHOT_VERBOSE=""

# PATHS
NICE="/usr/bin/nice"
IONICE="/usr/bin/ionice"
RSNAPSHOT="/usr/bin/rsnapshot"
RSNAPSHOT_CMD="$NICE -n 19 $IONICE -c 3 $RSNAPSHOT"

# INTERNAL VARIABLES
SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
EXIT=0

# Mount
$SCRIPTPATH/mount-backup.sh mount #&> /dev/null
[ $? -eq 0 ] || exit 1

full=$(df -h | grep $BACKUP_DIRECTORY)
full_percent=$(echo $full | awk '{ print $5 }' | sed 's/%//g')
if ((full_percent == 100))
then
    echo "WARNING: Backup destination $BACKUP_DIRECTORY is FULL:"
    echo $full
    $RSNAPSHOT_CMD du
    echo "Proceeding with backup, full output:"
    RSNAPSHOT_VERBOSE="-v"
fi

# Run rsnapshot
$RSNAPSHOT_CMD $RSNAPSHOT_VERBOSE "$@"
EXIT=$?

# Unmount
$SCRIPTPATH/mount-backup.sh umount
[ $? -eq 0 ] || exit 1

exit $EXIT

