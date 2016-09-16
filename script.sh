#!/usr/bin/env bash
echo "$(date): executing haproxy reload script"

echo "Downloading latest haproxy config"


echo "checking haproxy current status"
/etc/init.d/haproxy status
    if [ $? -ne 0 ]; then
        echo "haproxy is not running so starting it"
        /etc/init.d/haproxy start
    else

    fi

function test {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "error with $1" >&2
    fi
    return $status
}

echo "$(date): executing haproxy reload script"

$?

/etc/init.d/haproxy start
/etc/init.d/haproxy reload
