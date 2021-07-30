#!/bin/sh
echo `date` Scanning running images in the background
docker ps --format "{{.Image}}" | xargs -L1 ./parse-event.sh &

echo `date` echo Starting daemon
docker events --filter 'event=start' --format '{{.From}}' | xargs -L1 ./parse-event.sh
