#!/bin/bash

# Function to check if leap year exists in order to print exact year number
function is_leap {
	if !(($1 % 4)) && ( (($1 % 100)) || !(($1 % 400)) ); then
		echo 1
	else
		echo 0
	fi
}

# Function to convert seconds to human readable format, inspired by https://unix.stackexchange.com/a/27014
function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))

  # check for leap years in between install year and current year
  local Y=0
  if [[ $D -gt 0 ]]; then
	 for (( i = $2; i < $3; i++ )); do
	  	Y=$((Y+1))
	  	if [[ $(is_leap $i) -eq 1 ]]; then
	  		D=$((D-366))
	  	else
	  		D=$((D-365))
	  	fi
	  done
	(( $Y > 0 )) && printf '%d years ' $Y
  fi
  
  (( $D >= 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

# What distribution flavor is active?
distro_flavor=$(grep "ID_LIKE=" < /etc/os-release | cut -d '=' -f2 | sed -e 's/^"//' -e 's/"$//' | cut -d ' ' -f1)

case "${distro_flavor}" in
	arch ) 
		INSTALL_DATE=$(awk 'NR==1{gsub(/\[|\]/,"");print $1,$2}' /var/log/pacman.log)
		;;
	rhel|fedora )
		INSTALL_DATE=$(rpm -q basesystem --qf '%{installtime:date}\n' )
		;;
	debian )
		INSTALL_DATE=$(ls -lact --full-time /var/log/installer |awk 'END {print $6,$7,$8}')	
		;;
	* )
		INSTALL_DATE=$(ls -lact --full-time /etc |awk 'END {print $6,$7,$8}')	
		;;
esac

INSTALL_YEAR=$(date --date "$INSTALL_DATE" +%Y)

INSTALL_EPOCH=$(date --date  "${INSTALL_DATE}" +%s)

CURRENT_EPOCH=$(date +%s)

CURRENT_YEAR=$(date +%Y)

ELAPSED_EPOCH=$((CURRENT_EPOCH-INSTALL_EPOCH))

displaytime $ELAPSED_EPOCH $INSTALL_YEAR $CURRENT_YEAR
