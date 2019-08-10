#!/bin/bash

MY_USER=user

if [ `whoami` != "$MY_USER" ];
then
    echo "ERROR: crontab must be user-level"
    exit 1;
fi

PIDFILE=$HOME/base-script.pid
if [ -f $PIDFILE ]
then
  PID=$(cat $PIDFILE)
  ps -p $PID > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    echo "Process already running"
    exit 1
  else
    ## Process not found assume not running
    echo $$ > $PIDFILE
    if [ $? -ne 0 ]
    then
      echo "Could not create PID file"
      exit 1
    fi
  fi
else
  echo $$ > $PIDFILE
  if [ $? -ne 0 ]
  then
    echo "Could not create PID file"
    exit 1
  fi
fi

if [ -f "/home/$USER/run.sh" ]; then
	exec "/home/$USER/run.sh"
else
	echo "No script to execute, doing nothing"
fi

rm $PIDFILE
