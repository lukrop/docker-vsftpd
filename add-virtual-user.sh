#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

DB=/etc/vsftpd/virtual-users.db

if [ "$#" -lt 2 ] || [ "$#" -gt 4 ]; then
    echo "Usage: $0 [-d] <user> <password> [<home>]" >&2
    echo >&2
    echo "[ -d ] Delete the database first" >&2
    exit 1
fi

if [ "$1" == "-d" ]; then
    if [ -f $DB ]; then
        rm $DB
    fi
    shift
fi

echo -e "$1\n$2" | db5.3_load -T -t hash $DB

if [ ! -z "$3" ]; then
    echo "local_root=$3" > /etc/vsftpd/user_conf/$1
fi

