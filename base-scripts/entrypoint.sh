#!/bin/bash

# Define script variables
#USER_RUN_WRAPPER_SCRIPT="/base-scripts/run.sh" # Defined in Dockerfile
CRON_RUN_SCRIPT="/base-scripts/crontab-run.sh" # Generated script to set the ENV and run
											   # the wrapper
APP_USER_HOME="/home/$APP_USER"
APP_STARTUP_SCRIPT="startup.sh"

# Delete any existing users and create one with correct UID+GID
# Silence the output - errors only mean there wasn't a user or group to remove
deluser --remove-home $APP_USER
delgroup $APP_GROUP

echo ""

# Determine if there is an existing group with the required GID
group_search=`getent group $APP_GID`
regex='^[^:]\{1,\}'
if [ `echo $group_search | grep -c $regex` == 1 ]; then
	# An existing group was found. Reuse it.
    export APP_GROUP=`echo $group_search | grep -o $regex`
else
	# No existing group. Create one.
    addgroup -g $APP_GID $APP_GROUP
fi

# Create the user with the specified ID and previously (created/found) group
adduser -u $APP_UID -G $APP_GROUP -D $APP_USER

MY_RC="$?" # Did it work?

if [ $MY_RC -ne 0 ]; then
    echo "Failed to create user"
	echo "RC: $MY_RC"
	echo "APP_UID: $APP_UID"
	echo "APP_GID: $APP_GID"
	echo "APP_USER: $APP_USER"
	echo "APP_GROUP: $APP_GROUP"
	echo "group_search": "$group_search"
	echo "regex: $regex"
    exit 1
fi

# Set the timezone for the user
echo "export TZ=$TZ" >> /etc/profile

# Start building the script that cron will execute
echo "#!/bin/bash" > $CRON_RUN_SCRIPT

# Set ENV variables
echo "export APP_USER=$APP_USER" >> $CRON_RUN_SCRIPT
echo "export APP_GROUP=$APP_GROUP" >> $CRON_RUN_SCRIPT
echo "export APP_UMASK=$APP_UMASK" >> $CRON_RUN_SCRIPT

# Set USER ENV variables
regex='^USER_ENV_[^=]*' # todo: define this in a variable?
if [ `printenv | grep -c $regex` != 0 ]; then
	ENV_ARRAY=(`printenv | grep -o $regex`)

	for ENV in ${ENV_ARRAY[@]}
	do
		echo "export $ENV=`printenv $ENV`" >> $CRON_RUN_SCRIPT
	done
fi

# Add the script as the last command
echo "$APP_RUN_WRAPPER_SCRIPT" >> $CRON_RUN_SCRIPT

# Make it executable
chmod 755 $CRON_RUN_SCRIPT

# Copy the contents of the staging dir to the user's home directory
if [ -d $APP_STAGING_DIR ]; then
	cp -R $APP_STAGING_DIR/* $APP_USER_HOME/.
fi

# Execute (if it exists) the startup hook script (from the user's HOME dir)
if [ -f "$APP_USER_HOME/$APP_STARTUP_SCRIPT" ]; then
	$APP_USER_HOME/$APP_STARTUP_SCRIPT
	echo "Returned from startup hook"
	if [ $? -ne 0 ]; then
	    echo "Custom startup script failed, exiting"
	    exit 1
	fi
fi

chown -R $APP_USER $APP_USER_HOME

# Remove all other crontabs
rm /etc/crontabs/*

if [ ! -z ${DEBUG+x} ]; then
    echo "Adding generated script to crontab:"
    echo "======================"
    cat $CRON_RUN_SCRIPT
    echo "======================"
fi

# Add in the program's crontab (overwrite it)
echo "$APP_CRON /usr/bin/flock -n /tmp/my-cron.lockfile $CRON_RUN_SCRIPT" > /etc/crontabs/$APP_USER

if [ 'true' == "$APP_RUN_ON_STARTUP" ]; then
	su -c "$CRON_RUN_SCRIPT" - $APP_USER
fi

# Yield back
exec "$@"
