#!/bin/sh

#function_split
. /etc/init.d/functions
function checkURL()
{
	checkUrl=$*
	echo "check url start ..."
	judge=($(curl -I -s --connect-timeout 2 ${checkUrl}|head -1|tr " " "\n"))
	if [[ "${judge[1]}" == '200' && "${judge[2]}" == 'OK' ]]
		then
			antion "${checkUrl}" /bin/true
	else
		    antion "${checkUrl}" /bin/false
			echo -n "retrying again ..."; sleep 3;
		if [[ "${judge[1]}" == '200' && "${judge[2]}" == 'OK' ]]
		    then
				antion "${checkUrl}" /bin/true
	    else
		    antion "${checkUrl}" /bin/false
			echo -n "retrying again ..."; sleep 3;
		fi
	fi
	sleep 1;
}