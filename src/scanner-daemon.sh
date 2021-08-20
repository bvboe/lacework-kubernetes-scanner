#!/bin/sh
cd "$(dirname "$0")"
echo LW-Scanner version
lw-scanner version

echo Lacework CLI version
lacework version

echo `date` Scanning running images in the background
docker images --format '{{.Repository}}:{{.Tag}}' | grep -v "<none>" | xargs -n 1 ./parse-event.sh &

echo `date` Starting daemon
docker events --filter 'event=pull' --format '{{.ID}}' | xargs -n 1 ./parse-event.sh
