#!/bin/bash

MY_USER=user
MY_GROUP=mygoup
MY_SCRIPT=/base-scripts/run.sh

group_search=`getent group $APP_GID`

deluser --remove-home $MY_USER
delgroup $MY_GROUP

regex='^[^:]\{1,\}'
#echo $group_search | grep -c $regex
#echo $group_search | grep -o $regex

if [ `echo $group_search | grep -c $regex` == 1 ]; then
    my_group=`echo $group_search | grep -o $regex`
else
    my_group=$MY_GROUP
    addgroup -g $APP_GID $my_group
fi

adduser -u $APP_UID -G $my_group -D $MY_USER

if [ $? -ne 0 ]; then
    echo "Failed to create user"
    exit 1
fi

if [ -f "/home/$USER/startup.sh" ]; then
	exec "/home/$USER/startup.sh"
	if [ $? -ne 0 ]; then
	    echo "Custom startup script failed, exiting"
	    exit 1
	fi
fi

chown -R $MY_USER /home/$MY_USER

echo "$APP_CRON $MY_SCRIPT" >> /etc/crontabs/$MY_USER

exec "$@"

