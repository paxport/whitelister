#!/usr/bin/env bash
echo "$(date) loop-forever.sh arguments follow: <sleepsecs> <script> <args>"
echo "$1"
echo "$2"
echo "${@:3}"

echo " $(date) will execute the following command every $1 seconds: $2 ${@:3}"

while true
do
    "$2" "${@:3}"
	sleep $1
done
