#!/usr/bin/env bash
echo "loop-forever Arguments: <sleepsecs> <script> <args>"
echo "$1"
echo "$2"
echo "${@:3}"

while true
do
    "$2" "${@:3}"
	sleep $1
done
