#!/bin/bash

docker run  \
    --env APP_UID=`id -u` \
    --env APP_GID=`id -g` \
    --env APP_CRON='* * * * *' \
    --env RUN_ON_STARTUP='true' \
    cron-base-test:latest &
