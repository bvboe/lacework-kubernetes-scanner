#!/bin/sh
cd "$(dirname "$0")"

echo `date` Scanning running images in the background
docker images --format '{{.Repository}}:{{.Tag}}' | xargs -n 1 ./parse-event.sh &

echo `date` echo Starting daemon
docker events --filter 'event=pull' --format '{{.ID}}' | xargs -n 1 ./parse-event.sh
