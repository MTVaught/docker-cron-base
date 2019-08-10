#!/bin/bash

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

if [ -d /root/staging ]; then
	cp -R /root/staging/* /home/$MY_USER/.
fi

if [ -f "/home/$MY_USER/startup.sh" ]; then
	/home/$MY_USER/startup.sh
	echo "Returned from startup hook"
	if [ $? -ne 0 ]; then
	    echo "Custom startup script failed, exiting"
	    exit 1
	fi
fi

chown -R $MY_USER /home/$MY_USER

echo "$APP_CRON export MY_USER=$MY_USER && $MY_SCRIPT" >> /etc/crontabs/$MY_USER

exec "$@"

