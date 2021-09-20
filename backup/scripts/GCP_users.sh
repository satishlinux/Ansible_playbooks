#!/bin/sh

#set -x
####################################################################
# Purpose       : Script to create gcp user with password string
# Author        : Moolchand
# Version       : 1.0
# Created       : 6th Mar 2021
# Last Modified : 6th Mar 2021
# Changes       : Initial script
#####################################################################

LOGFILE='/tmp/gcp_user.log'
PATH=/bin:/usr/bin:/sbin:/usr/sbin
GRP=gcpgrp
day=`(date +%Y%m%d)`
export PATH
IFS='|'

### User Details of GCP User in Name : Email ID : a_<Short User Name> 
### Next user details in with '|' in same format
UserList='Aadhi Srilatha:aadhi.srilatha.ext@nokia.com:a_asrila|Brian Blum:brian.blum.ext@nokia.com:a_bblum|Mayank Kumar:mayank.2.kumar.ext@nokia.com:a_mayank|Nagendra Durga Prasad:nagendra.prasad.ext@nokia.com:a_nprasa|Rogith Annamalai:rogith.annamalai.ext@nokia.com:a_rannam|Rutu Patel:rutu.patel.ext@nokia.com:a_rutpat|Sandip Pitale:joseph.kurian.ext@nokia.com:a_pitale|Santhosh Krishnan:santhosh.krishnan.ext@nokia.com:a_sakris|Shreya Krishnamoorthy:shreya.krishnamoorthy.ext@nokia.com:a_shkris|Shubham Chauhan:shubham.chauhan.ext@nokia.com:a_s3chau|Suresh Gopalan Devaki:suresh.gd.ext@nokia.com:a_sgd|Uday Ankolekar:uday.ankolekar.ext@nokia.com:a_uankol|Dyuti Chatterjee:dyuti.chatterjee.ext@nokia.com:a_dychat|Bharathaselvan Karunanidhi:bharathaselvam.karunanidhi.ext@nokia.com:a_bkarun|Javed Iqbal:javed.iqbal.ext@nokia.com:a_javiqb|PraveenKumar NR:praveen.kumar_n_r.ext@nokia.com:a_kumarn|Rithishkumar P:rithishkumar.p.ext@nokia.com:a_ritp|Sharath Bhokhammgari:sharath.bhokhammgari.ext@nokia.com:a_sbhokh|Piyush Bansal:piyush.bansal.ext@nokia.com:a_pbansa|Shane Chambers:shane.chambers.ext@nokia.com:a_schamb|Eric Paul:eric.paul.ext@nokia.com:a_erpaul|Eric Malloy:eric.malloy.ext@nokia.com:a_emallo|Greg Boehnlein:greg.boehnlein.ext@nokia.com:a_gboehn|Konrad Schieban:konrad.schieban.ext@nokia.com:a_kschie|Dylan Gale:dylan.gale.ext@nokia.com:a_dgale|Evan List:evan.list.ext@nokia.com:a_elist|Travis Mount:travis.mount.ext@nokia.com:a_tmount'

##UserList='Eric Paul:eric.paul.ext@nokia.com:erpaul|Eric Malloy:eric.malloy.ext@nokia.com:malloy'

create_user(){
#
# Define basedir for new user and create it if it doesn't exist.
#
if [ -d /var/user ]; then
  BaseDir="/var/user"
 sudo chmod 755 $BaseDir
else
  if [ -d /var/home ]; then
    BaseDir="/var/home"
        sudo chmod 755 $BaseDir
  else
          sudo mkdir -p /var/user
          sudo chmod 755 /var/user
      echo "ERROR: Failed to make basedir /var/user." >> $LOGFILE
      exit 2
  fi
fi

#
# Create group if it doesn't exist
#
if grep "$GRP" /etc/group; then
  echo "Group $GRP exists."  >> $LOGFILE
else
  case `uname` in
   Linux|SunOS)
    sudo groupadd $GRP
    ;;
  *)
    echo "ERROR: OS not supported."  >> $LOGFILE
    exit 2
  esac
fi

#
# Create user if it doesn't exist
#
for a in $UserList
do
	USER=`echo $a | awk -F: '{print $3}'`
	USERNAME=`echo $a | awk -F: '{print $1}'`
	USEREMAIL=`echo $a | awk -F: '{print $2}'`
	UserComment="User Account for $USERNAME from Google/TCS Team with email $USEREMAIL."
	if grep "$USER:" /etc/passwd; then
	echo "User $USER exists." >> $LOGFILE
	case `uname` in
	Linux)
			sudo usermod -g $GRP -c "$UserComment" $USER
			sudo cp /etc/shadow /etc/shadow_"$day"
			sudo sed -i "/$USER/d" /etc/shadow
			echo "$USER:\$6\$0CxLXxiqKlbmJgdC$0ToQMSNWiq1Ghd/NzDz5ikqxPAdCjCTJA00cbWtTS2Pq4bVe4HJZf8fyjDAgpZg.YJGVtUUE7oQOWFp6NAS8j.:18692:0:90:7::99999:" | sudo tee -a /etc/shadow
			sudo chmod 400 /etc/shadow
		;;
	SunOS)
			sudo usermod -g $GRP -c "$UserComment" -e "" -f 0 $USER
			sudo cp /etc/shadow /etc/shadow_"$day"
			sudo sed "/$USER/d" /etc/shadow > /var/tmp/shadow_gcp && sudo mv /var/tmp/shadow_gcp /etc/shadow
			echo "$USER:jYMrLrKGhKQkg:18692:0:90:7::99999:" | sudo tee -a /etc/shadow
			sudo chmod 400 /etc/shadow
		;;
	*)
		echo "ERROR: OS not supported." >> $LOGFILE
		exit 2
	esac
	else
	case `uname` in
	Linux)
			sudo useradd -g $GRP -c "$UserComment" -d $BaseDir/$USER -m -e "" -f -1 $USER
			sudo cp /etc/shadow /etc/shadow_"$day"
			sudo sed -i "/$USER/d" /etc/shadow
			echo "$USER:\$6\$0CxLXxiqKlbmJgdC$0ToQMSNWiq1Ghd/NzDz5ikqxPAdCjCTJA00cbWtTS2Pq4bVe4HJZf8fyjDAgpZg.YJGVtUUE7oQOWFp6NAS8j.:18692:0:90:7::99999:" | sudo tee -a /etc/shadow
			sudo chmod 400 /etc/shadow
		;;
	SunOS)
			sudo useradd -g $GRP -c "$UserComment" -d $BaseDir/$USER  -m -e "" -f 0 $USER
			sudo cp /etc/shadow /etc/shadow_"$day"
			sudo sed "/$USER/d" /etc/shadow > /var/tmp/shadow_gcp && sudo mv /var/tmp/shadow_gcp /etc/shadow
			echo "$USER:jYMrLrKGhKQkg:18692:0:90:7::99999:" | sudo tee -a /etc/shadow
			sudo chmod 400 /etc/shadow
		;;
	*)
		echo "ERROR: OS not supported." >> $LOGFILE
		exit 2
	esac
	fi
	
	#
	# Validating Home Directory
	#
	
	HomeDir=`grep $USER /etc/passwd|awk  -F":" '{print $6}'`
	if [ -z "$HomeDir" ]; then
	echo "ERROR: No home directory found in /etc/passwd for $USER." >> $LOGFILE
	exit 2
	fi
	
	if [ ! -d "$HomeDir" ]; then
	echo "ERROR: Home directory \"$HomeDir\" for user \"$USER\" does not exist." >> $LOGFILE
	exit 2
	fi
	
	echo "########### USER Details ####################" >> $LOGFILE
	id -a $USER  >> $LOGFILE
	sudo grep $USER /etc/passwd >> $LOGFILE
	sudo grep $USER /etc/shadow >> $LOGFILE
	ls -ld $HomeDir  >> $LOGFILE
	echo "###############################" >> $LOGFILE
done
}

configure_sudoers(){
sudofile=""
if [ -f /etc/sudoers ]; then
sudofile='/etc/sudoers'
   elif [ -f /etc/opt/alct/sudoers ]; then
      sudofile='/etc/opt/alct/sudoers'
     elif [ -f /usr/local/etc/sudoers ]; then
            sudofile='/usr/local/etc/sudoers'
       elif [ -f /opt/csw/etc/sudoers ]; then
              sudofile='/opt/csw/etc/sudoers'
                  elif [ -f /opt/sfw/etc/sudoers ]; then
                 sudofile='/opt/sfw/etc/sudoers'
fi


if [ "$sudofile" = "" ]; then
  echo "Unable to locate SUDOERS file." >> $LOGFILE
  exit 1
fi

if sudo grep "$USER" $sudofile; then
  echo "User $USER exists in sudoers. Removing the entry..." >> $LOGFILE
   case `uname` in
  Linux)
        sudo sed -i "/$USER/d" $sudofile
    ;;
  SunOS)
    sudo cp $sudofile "$sudofile"_"$day"
    sudo sed "/$USER/d" $sudofile > /var/tmp/sudoers_gcp && sudo mv /var/tmp/sudoers_gcp $sudofile
    ;;
  *)
    echo "ERROR: OS not supported." >> $LOGFILE
    exit 2
  esac
 fi

if sudo grep "$GRP" $sudofile; then
  echo "Group $GRP already exists in SUDOERS." >> $LOGFILE
else
   case `uname` in
  Linux)
        echo "" |sudo tee -a $sudofile
		echo "### Google/TCS Users access for readonly commands ###" | sudo tee -a $sudofile
		echo "%$GRP ALL=(ALL) /usr/bin/less, /usr/bin/ls, /usr/bin/cat, /usr/bin/tail, /usr/sbin/lvdisplay, /usr/sbin/vgdisplay, /usr/sbin/pvdisplay, /usr/sbin/multipath -ll, /usr/sbin/powermt display dev=all, /usr/sbin/pcs status, /usr/sbin/clustat, /opt/VRTSvcs/bin/hastatus -sum, /usr/bin/tar -czvf *" | sudo tee -a $sudofile
		
    ;;
  SunOS)
		echo "" |sudo tee -a $sudofile
		echo "### Google/TCS Users access for readonly commands ###" | sudo tee -a $sudofile
		echo "%$GRP ALL=(ALL) /usr/bin/less, /usr/bin/ls, /usr/bin/cat, /usr/bin/tail, /usr/sbin/ldm list, /usr/bin/powermt display dev=all, /usr/sbin/ndd -get, /usr/sbin/cfgadm -al -o show_FCP_dev, /usr/sbin/devfsadm -c disk, /usr/sbin/lustatus, /usr/sbin/vxdisk -e list, /opt/VRTSvcs/bin/hastatus -sum, /usr/sbin/tar cvf *, /tools/support/bin/gtar czvf *" | sudo tee -a $sudofile
    ;;
  *)
    echo "ERROR: OS not supported." >> $LOGFILE
    exit 2
  esac
  
  echo "########## SUDO Entry ###############"
  sudo grep $GRP $sudofile >> $LOGFILE
  
fi
}

validation(){
cat $LOGFILE
}

create_user
configure_sudoers
validation

