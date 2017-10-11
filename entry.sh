#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

# change UID/GID if environment variables exist
if [ ! -z "$FTP_UID" ]; then
    usermod -u $FTP_UID ftp
fi

if [ ! -z "$FTP_GID" ]; then
    groupmod -g $FTP_GID ftp
fi

# Generate password if hash not set
if [ ! -z "$FTP_PASSWORD" -a -z "$FTP_PASSWORD_HASH" ]; then
  FTP_PASSWORD_HASH=$(echo "$FTP_PASSWORD" | mkpasswd -s -m sha-512)
fi

if [ ! -z "$FTP_USER" -a ! -z "$FTP_PASSWORD_HASH" ]; then
    /add-virtual-user.sh -d "$FTP_USER" "$FTP_PASSWORD_HASH"
fi

if [ "$SSL" == 'true' ]; then
    if [ ! grep -q ssl_enable /etc/vsftpd.conf ]; then
        cat /etc/vsftpd_ssl.part.conf >> /etc/vsftpd.conf
    fi
fi

# Support multiple users
while read user; do
	IFS=: read name pass home <<< ${!user}
	echo "Adding user $name"
    if [ ! -z "$home" ]; then
        /add-virtual-user.sh "$name" "$pass" "$home"
    else
	    /add-virtual-user.sh "$name" "$pass"
    fi
done < <(env | grep "FTP_USER_" | sed 's/^\(FTP_USER_[a-zA-Z0-9]*\)=.*/\1/')

# Support user directories
if [ ! -z "$FTP_USERS_ROOT" ]; then
	sed -i 's/local_root=.*/local_root=\/srv\/$USER/' /etc/vsftpd*.conf
fi

function vsftpd_stop {
  echo "Received SIGINT or SIGTERM. Shutting down vsftpd"
  # Get PID
  pid=$(cat /var/run/vsftpd/vsftpd.pid)
  # Set TERM
  kill -SIGTERM "${pid}"
  # Wait for exit
  wait "${pid}"
  # All done.
  echo "Done"
}

if [ "$1" == "vsftpd" ]; then
  trap vsftpd_stop SIGINT SIGTERM
  echo "Running $@"
  $@ &
  pid="$!"
  echo "${pid}" > /var/run/vsftpd/vsftpd.pid
  wait "${pid}" && exit $?
else
  exec "$@"
fi
