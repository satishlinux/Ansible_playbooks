#!/bin/sh

#set -x
####################################################################
# Purpose       : Script to create service account on Linux
# Author        : Suresh
# Version       : 1.1
# Created       : 21st May 2020
# Last Modified : 21st May 2020
# Changes       : Initial script
#####################################################################

LOGFILE='/tmp/svc_user.log'

create_user(){

UserComment="Account for Application Discovery 'yuriy.pavlov@nokia.com' "

PATH=/bin:/usr/bin:/sbin:/usr/sbin
GRP=stratint_svc_fi
USER=stratint_svc_fi
day=`(date +%Y%m%d)`
export PATH

#
# Define basedir for new user and create it if it doesn't exist.
#
if [ -d /var/user ]; then
  BaseDir="/var/user"
  chmod 755 $BaseDir
else
  if [ -d /var/home ]; then
    BaseDir="/var/home"
	chmod 755 $BaseDir
  else
    if mkdir /var/user; then
      BaseDir="/var/user"
	  chmod 755 $BaseDir
    else
      echo "ERROR: Failed to make basedir /var/user." >> $LOGFILE
      exit 2
    fi
  fi
fi

#
# Create group if it doesn't exist
#
if grep "$GRP" /etc/group; then
  echo "Group $GRP exists."  >> $LOGFILE
else
  case `uname` in
   Linux)
    groupadd $GRP
    ;;
  *)
    echo "ERROR: OS not supported."  >> $LOGFILE
    exit 2
  esac
fi

#
# Create user if it doesn't exist
#
if grep "$USER:" /etc/passwd; then
  echo "User $USER exists." >> $LOGFILE
   case `uname` in
  Linux)
	usermod -g $GRP -c "$UserComment" $USER
    chage -I -1 -m 0 -M 99999 -E -1 $USER
	cp /etc/shadow /etc/shadow_"$day"
	sed -i "/$USER/d" /etc/shadow
	echo "$USER:\$6\$FAIjsrEf\$u6YnRcy8lU4zTgh2pdneLTwjHGblSfn.sR0RMfUzCueVDK/5yozkuesstvbbUkpfPIDLet4/bvgx2c0XCWzDq.:18327:0:99999:10:::" >> /etc/shadow
	chmod 400 /etc/shadow
    ;;
  *)
    echo "ERROR: OS not supported." >> $LOGFILE
    exit 2
  esac 
else
  case `uname` in
  Linux)
    useradd -g $GRP -c "$UserComment" -d $BaseDir/$USER -m -e "" -f -1 $USER
	chage -I -1 -m 0 -M 99999 -E -1 $USER
	cp /etc/shadow /etc/shadow_"$day"
	sed -i "/$USER/d" /etc/shadow
	echo "$USER:\$6\$FAIjsrEf\$u6YnRcy8lU4zTgh2pdneLTwjHGblSfn.sR0RMfUzCueVDK/5yozkuesstvbbUkpfPIDLet4/bvgx2c0XCWzDq.:18327:0:99999:10:::" >> /etc/shadow
	chmod 400 /etc/shadow
    ;;
  *)
    echo "ERROR: OS not supported." >> $LOGFILE
    exit 2
  esac
fi
}


validation(){
id -a $USER  >> $LOGFILE
grep $USER /etc/passwd >> $LOGFILE
grep $USER /etc/shadow >> $LOGFILE
ls -ld $HomeDir  >> $LOGFILE
}

create_user
validation
