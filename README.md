# How to Monitor Your AVAX Node via telegram

Avalanchego telegram bash script

This telegram alert script checks avalanchego health status;

- If NODE is not healthy then it will send and ALERT message
- IF unhealty NODE is healty again then it will send ALERT RESOLVED message


## 1-) Download files from github

```bash

# install  jq 
sudo apt-get install  jq -y

# Git clone:

git clone https://github.com/burcusan/telegram-monitor-scripts.git
cd telegram-monitor-scripts


```



## 2-) Installation


```bash

# Usage:

./install_avax_monitor.sh -t <TELEGRAM TOKEN> -c <TELEGRAM CHAT ID>


# Example:

./install_avax_monitor.sh -t 1303111199:AAEx-kIC9E7333333TVeoZ8UzSongZ3_c-g -c 1051111168

```




## 3-) Check script & log 


```bash




./check_avalanchego_status.sh  > check_avalanchego_status.log
cat check_avalanchego_status.log

# Example Output :

 >>>> : Fri Oct  2 15:20:30 +03 2020
 >>>> : HTTP_CODE= 200
 >>>> : CURL_STATUS= 0
 >>>> : FILE= /tmp/tmp_check_Avalanchego
 >>>> : Avalanchego node is running!
 >>>> : Fri Oct  2 15:20:30 +03 2020 - [INFO] Avalanchego node is healthy ! -  health.getLiveness result.healthy=true hostname=oracle-1
 >>>> : true

```


```bash
./check_avalanchego_status.sh test
 >>>> : Fri Oct  2 16:25:53 +03 2020 - [TEST] [TEST] Avalanchego node TEST message !!!..
 >>> sendig Fri Oct  2 16:25:53 +03 2020 - [TEST] [TEST] Avalanchego node TEST message !!!..
{"ok":true,"result":....................................."date":100045154,"text":"Fri Oct  2 16:25:53  03 2020 - [TEST] [TEST] Avalanchego node TEST message !!!.."}}

```


## 4-) Check crontab -  Script will check avalanchego heath status every minutes and if NODE is not healthy it will alert via telegram and if NODE is healthy again it will send a recovery message 


```bash

# list crontab
crontab -l

#sample output
* * * * * /home/vagrant/telegram-monitor-scripts/check_avalanchego_status.sh > /home/vagrant/telegram-monitor-scripts/check_avalanchego_status.log 2>&1
```

