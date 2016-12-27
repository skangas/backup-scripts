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
