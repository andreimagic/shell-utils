#!/bin/bash

################ DEPENDENCIES CHECK ##################
commands=(curl sqlite3 parallel)
missingCmd=()
for cmd in "${commands[@]}"; do
    if ! which $cmd 2> /dev/null 1> /dev/null; then
        missingCmd+=("$cmd")
    fi
done
if [ -n "$missingCmd" ]; then
    echo -e $red"# Missing dependencies! (${missingCmd[@]})"$bold"\nThe script will not run properly."$fontreset
    exit 1
fi

function singleton() {
    [ -f $0.pid ] && pid="$(cat $0.pid)"
    # echo Old PID: $pid
    # echo New PID: $$
    if [ -n "$pid" ] && kill -0 $pid 2> /dev/null 1> /dev/null; then
        echo -e "${red}Another instance is running (PID: $pid)${fontreset}"
        return 1
    else
        # write PID file
        echo $$ > $0.pid
        return 0
    fi
}

function finish() {
    echo "Removing lock file..."
    [ -f $0.pid ] && rm $0.pid
}
trap finish SIGINT
######################################################

ARG_1=$1
ARG_2=$2
ARG_3=$3
ARG_4=$4

export subject=$(basename "$0")
export DB_FILE="$(readlink -f $0 | sed 's/.sh/.db3/')"
echo "Using DB file: $DB_FILE"

function check_internet() {
  ping -c 1 www.google.com > /dev/null
}
export -f check_internet

# this is called from inside script to convert seconds into display time
function displaytime() {
    local T=$1
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    [[ $D > 0 ]] && printf '%d days ' $D
    [[ $H > 0 ]] && printf '%d hours ' $H
    [[ $M > 0 ]] && printf '%d minutes ' $M
    [[ $D > 0 || $H > 0 || $M > 0 ]] && printf 'and '
    printf '%d seconds\n' $S
}
export -f displaytime

function curlCheck() {
	DATE=`date`
	echo -e "\n$DATE"
	
	URL=$1
	if [ -z "$URL" ]; then URL=$line; fi
	# URL=$line
	# echo $URL

	grepID=`sqlite3 $DB_FILE "select grep from WebLinks where link = '$URL' limit 1;"`
	echo -e "Testing URL: $URL"
	if curl -s -m 5 -k $URL | grep -i "$grepID" > /dev/null; then
		status=online
		priority=0
	else
		if ! check_internet; then
			echo "No internet connection!"
			exit 1
		fi
		echo -e "retrying..."
		if curl -s -m 10 -k $URL | grep -i "$grepID" > /dev/null; then
			status=online
			priority=0
		else
			status=offline
			priority=1
		fi
	fi
	# check last status from DB
	DBstatus=`sqlite3 $DB_FILE "select status from WebStatus where link = '$URL' order by time_stamp desc limit 1;"`
	echo "Current status: $status (vs. DB status: $DBstatus)"
	if [[ "$status" != "$DBstatus" ]]; then
		# Status Update
		echo "Updating status in DB . . . $status"
		sqlite3 $DB_FILE "insert into WebStatus (time_stamp,link,status) values (datetime('now'),'$URL','$status');"
		# Downtime Update
		if [[ "$DBstatus" == "offline" ]]; then
			echo "Recording downtime!!!"
			time_stampOff=`sqlite3 $DB_FILE "select time_stamp from WebStatus where link = '$URL' and status = 'offline' order by time_stamp desc limit 1;"`
			time_stampOn=`sqlite3 $DB_FILE "select time_stamp from WebStatus where link = '$URL' and status = 'online' order by time_stamp desc limit 1;"`
			downtime=`sqlite3 $DB_FILE "SELECT (SELECT strftime('%s', time_stamp) from WebStatus where link = '$URL' and status = 'online' order by time_stamp desc limit 1) - (SELECT strftime('%s', time_stamp) from WebStatus where link = '$URL' and status = 'offline' order by time_stamp desc limit 1);"`
			timeDisplay=`displaytime $downtime`
			echo -e "From: $time_stampOff ¦ Until: $time_stampOn -> $timeDisplay"
			sqlite3 $DB_FILE "insert into WebDowntime (time_stamp,link,downtime,time_stampStart) values (datetime('now'),'$URL','$downtime','$time_stampOff');"
			message=`echo -e "$DATE\n$URL changed status to $status\nDowntime recorded: $timeDisplay\nFrom: $time_stampOff ¦ Until: $time_stampOn"`
		else
			message=`echo -e "$DATE\n$URL changed status to $status\n$timeDisplay"`
		fi
			title=`echo "$URL is $status"`
			# notify.sh --pushover -s "$subject" -m "$message" -p "$priority"
	fi
}
export -f curlCheck #export this function to make it available across child-shells

function loopCurl() {
	if ! check_internet; then
		echo "No internet connection!"
		exit 1
	fi
	activeLinks=`sqlite3 $DB_FILE "select link from WebLinks where status = 'active' order by time_stamp desc;"`
	# time parallel curlCheck ::: "${activeLinks[@]}" # nice to have feature but fails with SQLite3 because of file access
	for link in ${activeLinks[@]}; do
		time curlCheck $link
	done
}






function create-db() {
	if [ ! -f "$DB_FILE" ]; then
		echo "Creating database . . ."
		sqlite3 $DB_FILE "CREATE TABLE WebLinks (time_stamp int, link char, grep char, status char);
		CREATE TABLE WebStatus (time_stamp int, link char, status char);
		CREATE TABLE WebDowntime (time_stamp int, link char, downtime int, time_stampStart int);"
	else
		echo "DB ok."
	fi
}

function insert-link() {
	db_link=`sqlite3 $DB_FILE "select time_stamp,link,grep,status from WebLinks where link = '$ARG_2';"`
	if [[ "$db_link" != "" ]]; then
		echo "# This link is all ready registered!"
		echo "$db_link"
	else
		if [[ "$ARG_2" != "" ]]; then
			echo "Registering new Link: $ARG_2"
			read -p "Grep for (optional): " new_grepID
			read -p "Status (active/inactive): " new_status
			if [[ "$new_status" = "active" || "$new_status" = "inactive" ]]; then
				sqlite3 $DB_FILE "insert into weblinks (time_stamp,link,grep,status) values (datetime('now'),'$ARG_2','$new_grepID','$new_status');"
				echo "# Link registered!"
				sqlite3 $DB_FILE "select time_stamp,link,grep,status from WebLinks where link = '$ARG_2';"
			else
				echo 'ERROR# Status must be "active" or "inactive"'
			fi
		else
			echo "ERROR# Command must be followed by a link!"
		fi
	fi
}

function delete-link() {
	db_link=`sqlite3 $DB_FILE "select time_stamp,link,status from WebLinks where link = '$ARG_2';"`
	if [[ "$db_link" = "" ]]; then
		echo "# Link not found in DB!"
	else
		echo "# Link found!"
		echo "$db_link"
		read -p "Delete ? (yes|NO) " confirmation
		if [[ "$confirmation" = "yes" || "$confirmation" = "y" ]]; then
			sqlite3 $DB_FILE "delete from weblinks where link = '$ARG_2';"
			echo "Deleted!"
		else
			echo "...aborted"
		fi
	fi
}

function update-link() {
	db_link=`sqlite3 $DB_FILE "select time_stamp,link,grep,status from WebLinks where link = '$ARG_2';"`
	if [[ "$db_link" = "" ]]; then
		echo -e "# Link not found in DB!\nAvailable links:"
		sqlite3 $DB_FILE "select time_stamp,link from WebLinks;"
	else
		echo "# Link found!"
		echo "$db_link"
		read -p "Grep for (optional): " new_grepID
		read -p "Status (active/inactive): " new_status
		#if [[ "$ARG_4" = "active" || "$ARG_4" = "inactive" ]]; then
		if [[ "$new_status" = "active" || "$new_status" = "inactive" ]]; then
			sqlite3 $DB_FILE "update weblinks set time_stamp = datetime('now'), grep = '$new_grepID', status = '$new_status' where link = '$ARG_2';"
			#sqlite3 $DB_FILE "update weblinks set status = '$new_status' where link = '$ARG_2';"
			echo "# Update registered!"
			sqlite3 $DB_FILE "select time_stamp,link,grep,status from WebLinks where link = '$ARG_2';"
		else
			echo 'ERROR# Status must be "active" or "inactive"'
		fi
	fi
}

function history() {
	db_link=`sqlite3 $DB_FILE "select * from WebLinks where link = '$ARG_2';"`
	if [[ "$db_link" = "" ]]; then
		echo -e "# Link not found in DB!\nAvailable links:"
		sqlite3 $DB_FILE "select time_stamp,link from WebLinks;"
	else
		sqlite3 $DB_FILE "select time_stampStart,link,time(downtime, 'unixepoch') from WebDowntime where link = '$ARG_2';"
	fi
}

function historySec() {
	db_link=`sqlite3 $DB_FILE "select * from WebLinks where link = '$ARG_2';"`
	if [[ "$db_link" = "" ]]; then
		echo -e "# Link not found in DB!\nAvailable links:"
		sqlite3 $DB_FILE "select time_stamp,link from WebLinks;"
	else
		sqlite3 $DB_FILE "select time_stampStart,link,downtime from WebDowntime where link = '$ARG_2';"
	fi
}

function webLinks() {
	sqlite3 $DB_FILE "select * from WebLinks;"
}

function webStatus() {
	if [[ "$ARG_2" = "" ]]; then
		sqlite3 $DB_FILE "select * from WebStatus;"
	else
		db_link=`sqlite3 $DB_FILE "select * from WebLinks where link = '$ARG_2';"`
		if [[ "$db_link" = "" ]]; then
			echo -e "# Link not found in DB!\nAvailable links:"
			sqlite3 $DB_FILE "select time_stamp,link from WebLinks;"
		else
			sqlite3 $DB_FILE "select * from WebStatus where link = '$ARG_2';"
		fi
	fi
}

function webDowntime() {
	if [[ "$ARG_2" = "" ]]; then
		sqlite3 $DB_FILE "select * from WebDowntime;"
	else
		db_link=`sqlite3 $DB_FILE "select * from WebLinks where link = '$ARG_2';"`
		if [[ "$db_link" = "" ]]; then
			echo -e "# Link not found in DB!\nAvailable links:"
			sqlite3 $DB_FILE "select time_stamp,link from WebLinks;"
		else
			sqlite3 $DB_FILE "select * from WebDowntime where link = '$ARG_2';"
		fi
	fi
}





function test() {
	URL=$ARG_2
	sqlite3 $DB_FILE "SELECT strftime('%s', time_stamp) from WebStatus where link = '$URL' and status = 'online' order by time_stamp desc limit 1;"
	sqlite3 $DB_FILE "SELECT time_stamp from WebStatus where link = '$URL' and status = 'online' order by time_stamp desc limit 1;"
	sqlite3 $DB_FILE "SELECT strftime('%s', time_stamp) from WebStatus where link = '$URL' and status = 'offline' order by time_stamp desc limit 1;"
	sqlite3 $DB_FILE "SELECT time_stamp from WebStatus where link = '$URL' and status = 'offline' order by time_stamp desc limit 1;"
	sqlite3 $DB_FILE "SELECT (SELECT strftime('%s', time_stamp) from WebStatus where link = '$URL' and status = 'online' order by time_stamp desc limit 1) - (SELECT strftime('%s', time_stamp) from WebStatus where link = '$URL' and status = 'offline' order by time_stamp desc limit 1);"
}






# this starts the job...
singleton || exit 1
if (( $# < 1 )); then
	grep function $0
else
	echo -e ""
	$1
	echo -e ""
fi
finish