#!/bin/sh
echo `date` Scanning running images in the background
docker images --format '{{.Repository}}:{{.Tag}}' | xargs -L1 ./parse-event.sh &

echo `date` echo Starting daemon
docker events --filter 'event=pull' --format '{{.ID}}' | xargs -L1 ./parse-event.sh
