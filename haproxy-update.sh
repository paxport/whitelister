#!/usr/bin/env bash
echo "$(date): executing haproxy reload script"

echo "checking haproxy current status"
/etc/init.d/haproxy status
if [ $? -ne 0 ]; then
    echo "haproxy is not running so starting it"
    /etc/init.d/haproxy start
    if [ $? -ne 0 ]; then
        echo "haproxy failed to start"
        exit 1
    fi
fi

echo "Downloading latest haproxy config from $HAPROXY_CONFIG_URL"
curl -o /etc/haproxy/haproxy.cfg.latest $HAPROXY_CONFIG_URL
if [ $? -ne 0 ]; then
    echo "Failed to download latest haproxy config"
    exit 1
fi

cmp -silent /etc/haproxy/haproxy.cfg.latest /etc/haproxy/haproxy.cfg
if [ $? -ne 0 ]; then
    echo "No changes detected in latest haproxy configuration"
    exit 0
fi

echo "haproxy configuration has changed so reloading..."
/etc/init.d/haproxy reload
if [ $? -ne 0 ]; then
    echo "haproxy failed to reload"
else
    echo "haproxy configuration reload was successful"
fi

exit $?

