#!/bin/bash

MY_SCRIPT=/base-scripts/run.sh

deluser --remove-home $MY_USER
delgroup $MY_GROUP

group_search=`getent group $APP_GID`

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

MY_RC="$?"

if [ $MY_RC -ne 0 ]; then
    echo "Failed to create user"
	echo "RC: $MY_RC"
	echo "APP_UID: $APP_UID"
	echo "APP_GID: $APP_GID"
	echo "my_group: $my_group"
	echo "MY_USER: $MY_USER"
	echo "MY_GROUP: $MY_GROUP"
	echo "group_search": "$group_search"
	echo "regex: $regex"
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

# Remove all other crontabs
rm /etc/crontabs/*

MY_CMD="export MY_USER=$MY_USER && $MY_SCRIPT"
# Add in the program's crontab
echo "$APP_CRON $MY_CMD" >> /etc/crontabs/$MY_USER

echo "#!/bin/bash" >> /home/$MY_USER/cron-test.sh
echo "$MY_CMD" >> /home/$MY_USER/cron-test.sh
chmod 755 /home/$MY_USER/cron-test.sh

echo "export TZ=$TZ" >> /etc/profile

if [ 'true' == "$RUN_ON_STARTUP" ]; then
	echo $MY_CMD
	su -c "bash -c \"$MY_CMD\"" - $MY_USER
fi

exec "$@"

