#!/usr/bin/env bash
#
# HAProxy Configuration Update Script
#
# This script will:
#
# 1) check that rsyslog is running and start it if it is not
# 2) check that haproxy is running and start it if it is not
# 3) download the latest version of the haproxy config file from supplied URL $1
# 4) compare the downloaded file with the current haproxy.cfg and
#
#   a) if they are the same then exit (no changes required)
#
#   or
#
#   b) if the new file is different then
#
#       i) overwrite the haproxy.cfg to be the new version
#       ii) do a soft restart so that haproxy updates its config
#
#

/etc/init.d/rsyslog status 2>&1 | logger &
if [ $? -ne 0 ]; then
    echo "rsyslog is not running so starting it..."
    /etc/init.d/rsyslog start
    if [ $? -ne 0 ]; then
        echo "rsyslog failed to start!"
    fi
fi

/etc/init.d/haproxy status 2>&1 | logger &
if [ $? -ne 0 ]; then
    echo "haproxy is not running so starting it..."
    /etc/init.d/haproxy start
    if [ $? -ne 0 ]; then
        echo "haproxy failed to start!"
        exit 1
    fi
fi

if [ -z "$1" ]
  then
    echo "No argument supplied for haproxy configuration url"
    exit 1
fi

curl -s -o /etc/haproxy/haproxy.cfg.latest $1
if [ $? -ne 0 ]; then
    echo "Failed to download latest haproxy config from $1"
    exit 1
fi

cmp --silent /etc/haproxy/haproxy.cfg.latest /etc/haproxy/haproxy.cfg
if [ $? -eq 0 ]; then
    exit 0
fi

echo "haproxy configuration has changed so overwriting and reloading..."
rm /etc/haproxy/haproxy.cfg
if [ $? -ne 0 ]; then
    echo "failed to delete legacy haproxy.cfg"
    exit 1
fi

mv /etc/haproxy/haproxy.cfg.latest /etc/haproxy/haproxy.cfg
if [ $? -ne 0 ]; then
    echo "failed to rename legacy /etc/haproxy/haproxy.cfg.latest to /etc/haproxy/haproxy.cfg"
    exit 1
fi

/etc/init.d/haproxy reload
if [ $? -ne 0 ]; then
    echo "haproxy failed to reload :-("
else
    echo "haproxy configuration reload was successful :-)"
fi

exit $?

