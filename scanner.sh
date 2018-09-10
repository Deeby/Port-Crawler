#!/usr/bin/env bash

###Edit these variables
IP_RANGE='192.168.1.0/24 192.168.2.0/24'
SCREENSHOT='true'
ELASTICSEARCH='http://localhost:9200'


###Optional variables to edit (leave default if unsure)
EXTRA_MASSCAN_FLAGS=''
ELASTICSEARCH_INDEX="portcrawler-$(date '+%Y-%m-%d_%H:%M')"
WEB_SERVER='false'
WEB_SERVER_USER='www-data'
SCREENSHOT_DIR='/opt/Port-Crawler/screenshots'
PORTFILE="/opt/Port-Crawler/portfile.txt"
MASSCAN='/usr/bin/masscan'
JSONPYES='/usr/local/bin/jsonpyes'
CHROME='/usr/bin/chromium-browser'
BLANK_MASTER="./blank-master.png"



###Do not edit below unless you know what you are doing

DATE="$(date '+%Y-%m-%d_%H:%M')"
FILE_EXT=".json"

COMPLETE_FILE="$DATE$FILE_EXT"


function driver {
	"$MASSCAN" "$IP_RANGE" -p "$(cat $PORTFILE)" --banners -oJ "$COMPLETE_FILE" "$EXTRA_MASSCAN_FLAGS"


	sed '1d; $d' "$COMPLETE_FILE" > "$DATE"
	sed 's/.$//' "$DATE" > "$COMPLETE_FILE"

	rm "$DATE"

	"$JSONPYES" --data "$COMPLETE_FILE" --bulk "$ELASTICSEARCH" --import --index "$ELASTICSEARCH_INDEX" --type scan  --check --thread 8
}


function screenshot {
	SCAN_FILE="$COMPLETE_FILE"
	
	declare -a PORT_ARRAY
	declare -a IP_ARRAY
	declare -a HOST_ARRAY

	IP_ADDRESSES="$(cat $SCAN_FILE | jq '.ip' | tr -d \")"

	PORTS="$(cat -s $SCAN_FILE | jq '.ports | map(.port)' | tr -d \[ | tr -d \] | sed 'N;/^\n$/D;P;D;' | sed /^$/d)"

	while read -r SINGLE_PORT
	do 
		PORT_ARRAY+=("$SINGLE_PORT")
	done <<< "$PORTS"


	while read -r SINGLE_IP
	do
		IP_ARRAY+=("$SINGLE_IP")
	done <<< "$IP_ADDRESSES"

	
	COUNT='0'
	if [[ ! -d "$SCREENSHOT_DIR" ]]
	then
		mkdir "$SCREENSHOT_DIR"
	fi


	for IP in "${IP_ARRAY[@]}"
	do
		IP_ADDR="$(printf "%s" "$IP")"
        	PORT="$(printf "%s" "${PORT_ARRAY["$COUNT"]}")"
		HOST_PORT="$IP_ADDR:$PORT"
		HOST_ARRAY+=("$HOST_PORT")
		COUNT=$((COUNT+1))
		if [[ "$PORT" == '443' ]]
		then
			URL="https://$HOST_PORT"
		else
			URL="http://$HOST_PORT"
		fi
		SCREENSHOT_FILE="$SCREENSHOT_DIR"/"$IP_ADDR"_"$PORT".png
		if [ ! -f "$SCREENSHOT_FILE" ]
		then
			if [[ "$PORT" == '443' ]] || [[ "$PORT" == '80' ]] || [[ "$PORT" == '8080' ]]
			then
				timeout 15 "$CHROME" --headless --no-sandbox --disable-gpu --screenshot="$SCREENSHOT_FILE" --ignore-certificate-errors "$URL"
				[ "$( compare -metric rmse "$SCREENSHOT_FILE" "$BLANK_MASTER" null: 2>&1 )" = "0 (0)" ] && rm "$SCREENSHOT_FILE"
			fi
		fi
	done
}



driver

if [[ "$SCREENSHOT" == 'true' ]]
then
	screenshot
	cp ./gallery.html "$SCREENSHOT_DIR"
	if [[ "$WEB_SERVER" == 'true' ]]
	then
		chown -R "$WEB_SERVER_USER" "$SCREENSHOT_DIR"
	fi
fi

rm "$COMPLETE_FILE"
