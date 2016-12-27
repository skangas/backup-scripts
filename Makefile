INSTALL = install
PREFIX = /usr/local
SBINDIR = ${PREFIX}/sbin

install:
	install -m 755 mount-backup.sh ${SBINDIR}/mount-backup.sh
	install -m 755 rsnapshot-wrapper.sh ${SBINDIR}/rsnapshot-wrapper.sh

uninstall:
	rm ${SBINDIR}/mount-backup.sh
	rm ${SBINDIR}/rsnapshot-wrapper.sh
