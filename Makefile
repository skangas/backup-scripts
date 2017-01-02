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

INSTALL = install
PREFIX = /usr/local
SBINDIR = ${PREFIX}/sbin

all:
	@echo "Run \"make install\" to install in ${SBINDIR}"

install:
	install -m 755 mount-backup.sh ${SBINDIR}/mount-backup.sh
	install -m 755 rsnapshot-wrapper.sh ${SBINDIR}/rsnapshot-wrapper.sh

uninstall:
	rm ${SBINDIR}/mount-backup.sh
	rm ${SBINDIR}/rsnapshot-wrapper.sh
