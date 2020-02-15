# docker-cron-base
Basic configuration for crontab scripting with custom UID/GID

# ENV variables

These are required by the base container to run:
    APP_UID
    APP_GID
    APP_CRON
    TZ

These are optional:
    APP_RUN_ON_STARTUP

Any ENV matching this pattern will be set in the USER's ENV when the cronjob runs
    USER_ENV_*

# Staging files:
Any files located in 
    /root/staging/*

Will be copied into the $HOME directory on container start

# Startup and App hooks:

This file will be executed at startup (as root)
    /home/staging/startup.sh

This file will be executed by the cronjob (as user)
    /home/staging/run.sh