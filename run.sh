#!/bin/bash

docker run --rm \
    --env APP_UID=`id -u` \
    --env APP_GID=`id -g` \
    --env APP_CRON='* * * * *' \
    mtvaught/cron-base:latest &

