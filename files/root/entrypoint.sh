#!/bin/sh

if [ -z "${VNCPASSWORD}" ]; then
	echo "VNCPASSWORD environment variable not set. Aborting"
	exit 1
fi

echo -e "${VNCPASSWORD}\n${VNCPASSWORD}\nn\n" | vncpasswd /root/.vnc/passwd
exec /usr/bin/supervisord -n
