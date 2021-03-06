#!/bin/bash

docker run --rm \
    --env APP_UID=`id -u` \
    --env APP_GID=`id -g` \
    --env APP_CRON='* * * * *' \
    --env RUN_ON_STARTUP='true' \
    mtvaught/cron-base:latest &
