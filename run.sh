#!/bin/bash

docker run --rm -it \
    --env APP_UID=`id -u` \
    --env APP_GID=`id -g` \
    --env APP_CRON='* * * * *' \
    --env RUN_ON_STARTUP='true' \
    --env USER_ENV_ONE='qwer' \
    --env USER_ENV_TWO='asdf' \
    --env DEBUG="1" \
    mtvaught/cron-base:latest
