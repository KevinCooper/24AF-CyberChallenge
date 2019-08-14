#!/bin/sh

### BEGIN INIT INFO
# Provides:		proftpd
# Required-Start:	$remote_fs $syslog
# Required-Stop:	$remote_fs $syslog
# Default-Start:	2 3 4 5
# Default-Stop:		1
# Short-Description:	Very secure FTP server
### END INIT INFO

set -e

DAEMON="/usr/local/sbin/proftpd"
NAME="proftpd"
PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin"
LOGFILE="/var/log/proftpd.log"
CHROOT="/var/run/proftpd/empty"

test -x "${DAEMON}" || exit 0

if [ ! -e "${LOGFILE}" ]
then
	touch "${LOGFILE}"
	chmod 640 "${LOGFILE}"
	chown root:adm "${LOGFILE}"
fi

if [ ! -d "${CHROOT}" ]
then
	mkdir -p "${CHROOT}"
fi

Check_standalone_mode ()
{
	# Return 1 if proftpd.conf doesn't have listen=yes or listen_ipv6=yes
	# (mandatory for standalone operation).

	CONFFILE="/etc/proftpd.conf"

}

case "${1}" in
	start)
		Check_standalone_mode || exit 0
		echo -n "Starting FTP server: "

		start-stop-daemon --start --background -m --oknodo --pidfile /var/run/proftpd/proftpd.pid --exec ${DAEMON}

		echo "${NAME}."
		;;

	stop)
		echo -n "Stopping FTP server: "

		start-stop-daemon --stop --pidfile /var/run/proftpd/proftpd.pid --oknodo --exec ${DAEMON}
		rm -f /var/run/proftpd/proftpd.pid

		echo "${NAME}."

		;;

	restart)
		echo -n "Stopping FTP server: "

		start-stop-daemon --stop --pidfile /var/run/proftpd/proftpd.pid --oknodo --exec ${DAEMON}
		rm -f /var/run/proftpd/proftpd.pid

		echo "${NAME}."
		Check_standalone_mode || exit 0
		echo -n "Starting FTP server: "

		start-stop-daemon --start --background -m --pidfile /var/run/proftpd/proftpd.pid --exec ${DAEMON}

		echo "${NAME}."
		;;

	reload|force-reload)
		echo "Reloading FTP server configuration: "

		start-stop-daemon --stop --pidfile /var/run/proftpd/proftpd.pid --signal 1 --exec $DAEMON

		echo "${NAME}."
		;;

	status)
		PID="$(cat /var/run/proftpd/proftpd.pid 2>/dev/null)" || true

		if [ ! -f /var/run/proftpd/proftpd.pid ] || [ -z "${PID}" ]
		then
			echo "${NAME} is not running"
			exit 3
		fi

		if ps "${PID}" >/dev/null 2>&1
		then
			echo "${NAME} is running"
			exit 0
		else
			echo "${NAME} is not running"
			exit 1
		fi
		;;

	*)
		echo "Usage: /etc/init.d/${NAME} {start|stop|restart|reload|status}"
		exit 1
		;;
esac

exit 0