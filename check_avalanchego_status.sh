#!/bin/bash
##
#
# Avalanche node health status check & telegram alert script
#
##

# Fail immediately if another instance is already running
export LC_ALL=C.UTF-8
script_name=$(basename -- "$0")

if pidof -x "$script_name" -o $$ >/dev/null;then
   echo "An another instance of this script is already running, please clear all the sessions of this script before starting a new session"
   exit 1
fi


# Custom variables

TOKEN=
CHAT_ID=
CPU_LOAD_CRITICAL=40.00
AVALANCHEGO_IP=127.0.0.1
# CHAT_ID2=$(curl -s https://api.telegram.org/bot$TOKEN/getUpdates  | jq .result[0].message.chat.id)
TELEGRAM_URL="https://api.telegram.org/bot$TOKEN/sendMessage"
FILE=/tmp/tmp_check_Avalanchego
SEND_ALERT_FLAG=true
FILE_CPU=/tmp/tmp_check_Avalanchego_CPU
SEND_ALERT_FLAG_CPU=true
HOSTNAME=`hostname`
DATE=`date | cut -d' ' -f4 | cut -d: -f2`


#Check alert count
function check_alert_count
{
        if [ ! -f "$FILE" ]; then
            echo "1" > $FILE
            COUNTER=$(cat $FILE)
        else
            echo $(( $(cat $FILE) + 1 ))> $FILE
            COUNTER=$(cat $FILE)
        fi

        case $COUNTER in
          1) SEND_ALERT_FLAG=true ;;
          5) SEND_ALERT_FLAG=true ;;
          15) SEND_ALERT_FLAG=true ;;
          30) SEND_ALERT_FLAG=true ;;
          60) SEND_ALERT_FLAG=true ;;
          120) SEND_ALERT_FLAG=true ;;
          360) SEND_ALERT_FLAG=true ;;
          720) SEND_ALERT_FLAG=true ;;
          1440) SEND_ALERT_FLAG=true ;;
          *)  SEND_ALERT_FLAG=false ;;
        esac
}


#Check alert count
function check_alert_count_cpu
{
        if [ ! -f "$FILE_CPU" ]; then
            echo "1" > $FILE_CPU
            COUNTER_CPU=$(cat $FILE_CPU)
        else
            echo $(( $(cat $FILE_CPU) + 1 ))> $FILE_CPU
            COUNTER_CPU=$(cat $FILE_CPU)
        fi

        case $COUNTER_CPU in
          1) SEND_ALERT_FLAG_CPU=true ;;
          5) SEND_ALERT_FLAG_CPU=true ;;
          15) SEND_ALERT_FLAG_CPU=true ;;
          30) SEND_ALERT_FLAG_CPU=true ;;
          60) SEND_ALERT_FLAG_CPU=true ;;
          120) SEND_ALERT_FLAG_CPU=true ;;
          360) SEND_ALERT_FLAG_CPU=true ;;
          720) SEND_ALERT_FLAG_CPU=true ;;
          1440) SEND_ALERT_FLAG_CPU=true ;;
          *)  SEND_ALERT_FLAG_CPU=false ;;
        esac
}



#Telegram API to send notificaiton.
function telegram_send
{
        if [ "$SEND_ALERT_FLAG" = true ] ; then
                echo " >>>>: sendig $MESSAGE"
                curl --silent --max-time 13 --retry 3 --retry-delay 3 --retry-max-time 13 -X POST $TELEGRAM_URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
        fi

}


#Telegram API to send notificaiton.
function telegram_send_cpu
{
        if [ "$SEND_ALERT_FLAG_CPU" = true ] ; then
                echo " >>>>: sendig $MESSAGE"
                curl --silent --max-time 13 --retry 3 --retry-delay 3 --retry-max-time 13 -X POST $TELEGRAM_URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
        fi
}



# Check test message
if [ "$1" == "test" ] ; then
        SEND_ALERT_FLAG_CPU=false
        MESSAGE="$(date) - [TEST] [TEST] Avalanchego node TEST message !!!.."
        echo " >>>> : $MESSAGE"
        telegram_send
        exit 0
fi

# NO PROBLEM Message  sent every hour
if [[ $DATE == "00" ]]
then
MESSAGE="$(date) - [SYSTEM] [OK] Avalanchego node WORKING !!!.."
        echo " >>>> : $MESSAGE"
        telegram_send
        exit 0
    fi


#Check Avalanchego health status with API call
HTTP_CODE=$(curl --write-out %{http_code} --silent --connect-timeout 5 --max-time 10 --output /dev/null -L -X POST --data '{
    "jsonrpc":"2.0",
    "id"     :1,
    "method" :"health.getLiveness"
}' -H 'content-type:application/json;' $AVALANCHEGO_IP:9650/ext/health)

CURL_STATUS=$?

echo " >>>> : $(date)"
echo " >>>> : TOKEN= $TOKEN"
echo " >>>> : CHAT_ID= $CHAT_ID"
echo " >>>> : HTTP_CODE= $HTTP_CODE"
echo " >>>> : CURL_STATUS= $CURL_STATUS"
echo " >>>> : FILE= $FILE"

# Check conditions
if [ "$CURL_STATUS" -eq 0 ]; then

        if [[ "$HTTP_CODE" -ne 200 ]] ; then
            check_alert_count
            MESSAGE="$(date) - [CRTICAL] [ALERT FIRING] Avalanchego node is not running !!! #count:$COUNTER - returnig http_code=$HTTP_CODE hostname=$HOSTNAME "
            echo " >>>> : $MESSAGE"
            telegram_send
        else
            echo " >>>> : Avalanchego node is running!"
            STATUS_HEALTHY=$(curl --silent  -X POST --data '{
                "jsonrpc":"2.0",
                "id"     :1,
                "method" :"health.getLiveness"
            }' -H 'content-type:application/json;' $AVALANCHEGO_IP:9650/ext/health | jq '.result.healthy')
            if [[ "$STATUS_HEALTHY" == "true" ]]; then
                MESSAGE="$(date) - [INFO] Avalanchego node is healthy ! -  health.getLiveness result.healthy=$STATUS_HEALTHY hostname=$HOSTNAME"
                echo " >>>> : $MESSAGE"
                echo " >>>> : $STATUS_HEALTHY"
                if [ -f "$FILE" ]; then
                    echo "$FILE exists."
                    MESSAGE="$(date) - [INFO] [ALERT RESOLVED] Avalanchego node is healthy again !!! -  health.getLiveness result.healthy=$STATUS_HEALTHY hostname=$HOSTNAME"
                    rm $FILE
                    SEND_ALERT_FLAG=true
                    telegram_send
                fi
            else
                check_alert_count
                MESSAGE="$(date) - [CRTICAL] [ALERT FIRING] Avalanchego node is not healthy !!! #count:$COUNTER -  health.getLiveness result.healthy=$STATUS_HEALTHY hostname=$HOSTNAME"
                echo " >>>> : $MESSAGE"
                telegram_send
            fi
        fi

else
        check_alert_count
        MESSAGE="$(date) - [CRTICAL] [ALERT FIRING] Avalanchego node is not running #count:$COUNTER - hostname=$(hostname)"
        echo " >>>> : $MESSAGE"
        telegram_send

fi


# check cpu usage

# CPU_LOAD=`sar -P ALL 1 5 | grep "Average.*all" | awk -F" " '{printf "%.2f\n", 100 -$NF}'`
CPU_LOAD=`sar -P ALL 1 5 | grep "Average.*all" | awk -F" " '{printf "%.2f\n", 100 -$NF}'`

echo " >>>> : CPU_LOAD=$CPU_LOAD"
echo " >>>> : CPU_LOAD_CRITICAL=$CPU_LOAD_CRITICAL"


#if [[ $CPU_LOAD -gt $CPU_LOAD_CRITICAL ]];
#then

if (( $(echo "$CPU_LOAD $CPU_LOAD_CRITICAL" | awk '{print ($1 > $2)}') )); then
	PROC=`ps -eo pcpu,pid -o comm= | sort -k1 -n -r | head -1`
        echo " >>>> : callling check_alert_count_cpu "
        echo " >>>> : SEND_ALERT_FLAG_CPU : $SEND_ALERT_FLAG_CPU"
        check_alert_count_cpu
        MESSAGE="$(date) - [CRTICAL] [ALERT FIRING] Avalanchego node high CPU usage problem !!! #count:$COUNTER_CPU - Please check your processess $PROC - Linux SAR Total CPU Usage : $CPU_LOAD % - hostname=$HOSTNAME"
        echo " >>>> : MESSAGE : $MESSAGE"
        echo " >>>> : SEND_ALERT_FLAG_CPU : $SEND_ALERT_FLAG_CPU"
        telegram_send_cpu
else
        if [ -f "$FILE_CPU" ]; then
	        echo "$FILE_CPU exists."
                MESSAGE="$(date) - [INFO] [ALERT RESOLVED] Avalanchego node normal CPU usage again !!! - Linux SAR Total CPU Usage : $CPU_LOAD % - hostname=$HOSTNAME"
                rm $FILE_CPU
                SEND_ALERT_FLAG_CPU=true
        	echo " >>>> : $MESSAGE"
                telegram_send_cpu
       fi
fi
