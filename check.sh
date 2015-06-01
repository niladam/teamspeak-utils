#!/bin/bash
#
# simple bash script that checks
# if your teamspeak server is running.
# initial release 21 May 2015
# Tache Madalin (https://github.com/niladam/teamspeak-utils)
#
# You can set this script to run every few minutes like this one
#
# */5 * * * * /root/check.sh
# 
# The script will run every 5 minutes and start the server if 
# it appears to be down.
#
#### folder location of your teamspeak NO TRAILING SLASHES!
TSFOLDER="/home/ts/server"
#### PID file name of your teamspeak defaults to ts3server.pid -- change if different.
PIDFILE="ts3server.pid"
#### name of your server executable -- change this if it's not the default setting
TNAME="ts3server_linux_amd64"
#### Want logs ? 1 - YES / 0 - NO the log file will be located in the teamspeak
#### folder location in a file called tscheck.log (ex: /home/ts/server/tscheck.log)
LOGGING="1"
#### Please make sure you check the log filesize once in a while as the file
#### could get pretty big
#### username running your teamspeak server
USER="ts"
#### start script name -- change this if it's not the default setting
SNAME="ts3server_startscript.sh"
#### let's set the PID to 0.
PID=0
#
############# Editing below this line can get you nowhere..unless you know your way :)
#

if [ $LOGGING -eq 1 ]; then
	LOGFILE="$TSFOLDER/tscheck.log"
else
	LOGFILE="/dev/null"
fi

if [ "$LOGFILE" != "/dev/null" ]; then
	if [ ! -f "$LOGFILE" ]; then
		touch "$LOGFILE";
		chown $USER.$USER "$LOGFILE"
	fi
fi

if [ -e "$TSFOLDER/$PIDFILE" ]; then
        PID=`cat $TSFOLDER/$PIDFILE`
        echo "$(date) Found pid.... $PID, checking it" >> $LOGFILE
else
        echo "$(date) Teamspeak server is not running, starting it.." >> $LOGFILE
        su - ${USER} -c "${TSFOLDER}/${SNAME} start"
        exit 0;
fi

# checking PID existence
if [ ${PID} -gt 0 ]; then
        if ( kill -0 ${PID} 2> /dev/null ); then
                echo "$(date) Teamspeak server is running, exiting.." >> $LOGFILE
                exit 0;
        else
                echo "$(date) Teamspeak server probably crashed, because the PID ${PID} is not running.." >> $LOGFILE
                echo "$(date) Starting teamspeak server" >> $LOGFILE
                su - ${USER} -c "${TSFOLDER}/${SNAME} start"
                exit 0;
        fi
else
        echo "$(date) Apparently this something went wrong.." >> $LOGFILE
        echo "$(date) Did you set your paths correctly ?" >> $LOGFILE
        exit 3
fi
