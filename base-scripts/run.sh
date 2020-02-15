#!/bin/bash

if [ `whoami` == "root" ];
then
    echo "ERROR: crontab shall not be run as root"
    exit 1;
fi


if [ `whoami` != "$APP_USER" ];
then
    echo "Detected user as `whoami`"
    echo "ERROR: crontab must be run as \$APP_USER=$APP_USER"
    exit 1;
fi

echo "Setting umask to $APP_UMASK"
umask $APP_UMASK

# Using flock to prevent duplicate operations
/home/$USER/run.sh

echo "cronjob finished"
