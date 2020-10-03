#!/bin/bash 
##
#
# INSTALLATION SCRIPT for "Avalanche node health status check & telegram alert script"
#
##

SCRIPT_NAME="check_avalanchego_status.sh"
SCRIPT_LOG="check_avalanchego_status.log"
SCRIPT_PATH=`pwd`


# show usage
help() {
        echo -e "\nThis script must be run with ( -t TELEGRAM_TOKEN -c TELEGRAM_CHAT_ID ) parameter"
        echo -e "Usage: $0 -t WRITE_TELEGRAM_TOKEN_HERE -c WRITE_TELEGRAM_CHAT_ID_HERE  "
        echo -e "Sample: $0 -t 130999999:AAEx-kIC9E1237Lb57777Z8123ongZ3_c-g -c 109999999168 \n"
        }

# take options
while getopts "t:c:" opt; do
        case $opt in
                t)
                        TOKEN=${OPTARG}
                        ;;
                c)
                        CHAT_ID+=("$OPTARG")
                        ;;
                ?|h)
                        help
                        ;;
                :)
                        echo "Option -$OPTARG needs an argument."
                        exit 1
                        ;;
                \?)
                        echo "Invalid option -$OPTARG"
                        exit 1
                        ;;
esac
done

# install jq
sudo apt-get install jq -y


# chek if TOKEN set
if [ -z "${TOKEN}" ]; then
    help
    exit 1
fi

if [ -z "${CHAT_ID}" ]; then
    help
    exit 1
fi

# add TOKEN value to script
sed -i "/^TOKEN=/c\TOKEN=$TOKEN" check_avalanchego_status.sh
sed -i "/^CHAT_ID=/c\CHAT_ID=$CHAT_ID" check_avalanchego_status.sh


echo ""
echo " >>> : Starting..."
echo ""
echo " >>>>>> : Running $0 $@" 
echo ""
echo " >>>>>> : Updated $SCRIPT_NAME with Telegram Token = $TOKEN"
TOKEN_LINE=`cat $SCRIPT_NAME | grep TOKEN=`
echo " >>>>>> : $TOKEN_LINE"
echo " >>>>>> : Updated $SCRIPT_NAME with Telegram chat id = $CHAT_ID"
CHAT_ID_LINE=`cat $SCRIPT_NAME | grep CHAT_ID=`
echo " >>>>>> : $CHAT_ID_LINE"


# add crontab entry

echo ""
croncmd="$SCRIPT_PATH/$SCRIPT_NAME > $SCRIPT_PATH/$SCRIPT_LOG 2>&1"
cronjob="* * * * * $croncmd"
echo  " >>>>>> : Adding crontab :  $cronjob "
( crontab -l 2>/dev/null | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
echo  " >>>>>> : Listing crontab : "
cronjob_list=`crontab -l`
echo  " >>>>>> : $cronjob_list "

echo ""
echo " >>> : Ending..."
echo ""



