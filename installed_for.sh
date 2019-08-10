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
      if [[ $Y -gt 1 ]]; then
          printf '%d years ' $Y
      elif [[ $Y -eq 1 ]]; then
          printf '%d year ' $Y
      fi
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
		INSTALL_EPOCH=$(date --date  "${INSTALL_DATE}" +%s) #should find alternative to date

		;;
	rhel|fedora )
		INSTALL_DATE=$(rpm -q basesystem --qf '%{installtime:date}\n' )
        INSTALL_EPOCH=$(date --date  "${INSTALL_DATE}" +%s) #should find alternative to date
		;;
	debian|ubuntu)
		INSTALL_DATE=$(ls -lact --full-time /var/log/installer |awk 'END {print $6,$7,$8}')
		#INSTALL_DATE=$(stat -c "%w" /var/log/installer) stat not working on mint
		#INSTALL_EPOCH=$(stat -c "%W" /var/log/installer)
		INSTALL_EPOCH=$(date --date  "${INSTALL_DATE}" +%s) #should find alternative to date
        ;;
	* )
		#INSTALL_DATE=$(ls -lact --full-time /etc |awk 'END {print $6,$7,$8}')
		distro_id=$(grep "^ID=" < /etc/os-release | cut -d '=' -f2 | sed -e 's/^"//' -e 's/"$//' | cut -d ' ' -f1)

        INSTALL_DATE=$(stat -c "%w" /etc)
		INSTALL_EPOCH=$(stat -c "%W" /etc)
		;;
esac

INSTALL_YEAR=$(awk 'END {print $4}' <<< "$INSTALL_DATE")

# BASH >=4.2
printf -v INSTALL_YEAR '%(%Y)T\n' $INSTALL_EPOCH

printf -v CURRENT_EPOCH '%(%s)T\n' -1
printf -v CURRENT_YEAR '%(%Y)T\n' -1

ELAPSED_EPOCH=$((CURRENT_EPOCH-INSTALL_EPOCH))

displaytime $ELAPSED_EPOCH $INSTALL_YEAR $CURRENT_YEAR