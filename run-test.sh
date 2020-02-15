#!/bin/bash

docker run  \
    --env APP_UID=`id -u` \
    --env APP_GID=`id -g` \
    --env APP_CRON='* * * * *' \
    --env APP_RUN_ON_STARTUP='true' \
    --env DEBUG="1" \
    --env USER_ENV_ONE='var1' \
    --env USER_ENV_TWO='var2' \
    --env USER_ENV_THREE='var3' \
    cron-base-test:latest &
