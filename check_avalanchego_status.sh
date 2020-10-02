#!/bin/bash
##
#
# Avalanche node health status check & telegram alert script
#
##

# Fail immediately if another instance is already running

script_name=$(basename -- "$0")

if pidof -x "$script_name" -o $$ >/dev/null;then
   echo "An another instance of this script is already running, please clear all the sessions of this script before starting a new session"
   exit 1
fi

# Custom variables

TOKEN=1303123599:AAEx-kIC9E1237Lb5TVeoZ8123ongZ3_c-g
CHAT_ID=$(curl --silent https://api.telegram.org/bot$TOKEN/getUpdates | jq .message.chat.id)
TELEGRAM_URL="https://api.telegram.org/bot$TOKEN/sendMessage"
FILE=/tmp/tmp_check_Avalanchego
SEND_ALERT_FLAG=true

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
          *)  SEND_ALERT_FLAG=false ;;
        esac
}


#Telegram API to send notificaiton.
function telegram_send
{
        if [ "$SEND_ALERT_FLAG" = true ] ; then
                echo " >>> sendig $MESSAGE"
                curl --silent --max-time 13 --retry 3 --retry-delay 3 --retry-max-time 13 -X POST $TELEGRAM_URL -d chat_id=$CHAT_ID -d text="$MESSAGE"
        fi
}


#Check Avalanchego health status with API call
HTTP_CODE=$(curl --write-out %{http_code} --silent --connect-timeout 5 --max-time 10 --output /dev/null -L -X POST --data '{
    "jsonrpc":"2.0",
    "id"     :1,
    "method" :"health.getLiveness"
}' -H 'content-type:application/json;' 127.0.0.1:9650/ext/health)

CURL_STATUS=$?

echo " >>>> : $(date)"
echo " >>>> : HTTP_CODE= $HTTP_CODE"
echo " >>>> : CURL_STATUS= $CURL_STATUS"
echo " >>>> : FILE= $FILE"

# Check conditions
if [ "$CURL_STATUS" -eq 0 ]; then

        if [[ "$HTTP_CODE" -ne 200 ]] ; then
            check_alert_count
            MESSAGE="$(date) - [CRTICAL] [ALERT FIRING] Avalanchego node is not running !!! #count:$COUNTER - returnig http_code=$HTTP_CODE hostname=$(hostname) "
            echo " >>>> : $MESSAGE"
            telegram_send
        else
            echo " >>>> : Avalanchego node is running!"
            STATUS_HEALTHY=$(curl --silent  -X POST --data '{
                "jsonrpc":"2.0",
                "id"     :1,
                "method" :"health.getLiveness"
            }' -H 'content-type:application/json;' 127.0.0.1:9650/ext/health | jq '.result.healthy')
            if [[ "$STATUS_HEALTHY" == "true" ]]; then
                MESSAGE="$(date) - [INFO] Avalanchego node is healthy ! -  health.getLiveness result.healthy=$STATUS_HEALTHY hostname=$(hostname)"
                echo " >>>> : $MESSAGE"
                echo " >>>> : $STATUS_HEALTHY"
                if [ -f "$FILE" ]; then
                    echo "$FILE exists."
                    MESSAGE="$(date) - [INFO] [ALERT RESOLVED] Avalanchego node is healthy again !!! -  health.getLiveness result.healthy=$STATUS_HEALTHY hostname=$(hostname)"
                    rm $FILE
                    SEND_ALERT_FLAG=true
                    telegram_send
                fi
            else
                check_alert_count
                MESSAGE="$(date) - [CRTICAL] [ALERT FIRING] Avalanchego node is not healthy !!! #count:$COUNTER -  health.getLiveness result.healthy=$STATUS_HEALTHY hostname=$(hostname)"
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
