#!/usr/bin/env bash
#echo "$(date): executing haproxy reload script"

/etc/init.d/rsyslog status
if [ $? -ne 0 ]; then
    echo "rsyslog is not running so starting it"
    /etc/init.d/rsyslog start
    if [ $? -ne 0 ]; then
        echo "rsyslog failed to start!"
    fi
fi

/etc/init.d/haproxy status
if [ $? -ne 0 ]; then
    logger -s "haproxy is not running so starting it"
    /etc/init.d/haproxy start
    if [ $? -ne 0 ]; then
        echo "haproxy failed to start"
        exit 1
    fi
fi

if [ -z "$1" ]
  then
    logger -s  "No argument supplied for haproxy configuration url"
    exit 1
fi

curl -s -o /etc/haproxy/haproxy.cfg.latest $1
if [ $? -ne 0 ]; then
    logger -s  "Failed to download latest haproxy config from $1"
    exit 1
fi

cmp --silent /etc/haproxy/haproxy.cfg.latest /etc/haproxy/haproxy.cfg
if [ $? -eq 0 ]; then
    #echo "No changes detected in latest haproxy configuration"
    exit 0
fi

logger -s "haproxy configuration has changed so overwriting and reloading..."
rm /etc/haproxy/haproxy.cfg
if [ $? -ne 0 ]; then
    logger -s "failed to delete legacy haproxy.cfg"
    exit 1
fi

mv /etc/haproxy/haproxy.cfg.latest /etc/haproxy/haproxy.cfg
if [ $? -ne 0 ]; then
    logger -s "failed to rename legacy /etc/haproxy/haproxy.cfg.latest to /etc/haproxy/haproxy.cfg"
    exit 1
fi

/etc/init.d/haproxy reload
if [ $? -ne 0 ]; then
    logger -s "haproxy failed to reload :-("
else
    logger -s "haproxy configuration reload was successful :-)"
fi

exit $?

