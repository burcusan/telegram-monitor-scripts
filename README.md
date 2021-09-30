# !!! IMPORTANT UPDATE for avalanchego V1.6.1 !!!

With avalanchego V1.6.1 relase "Health API" is changed.
The monitoring script is updated to work with avalanchego V1.6.1 and upward releases.  

All "telegram-monitor-scripts" users have to reinstall the script or make necessary changes manually.

1-) Automatic Change with reinstall : 

https://medium.com/@burcusan/how-to-get-real-time-alerts-from-your-avalanchego-validator-node-f65f288c3e69

2-) Manual Change : 

# goto home directory
cd

# goto telegram-monitor-scripts directory
cd telegram-monitor-scripts

# make necessary change
sed -i 's/health.getLiveness/health.health/g'  check_avalanchego_status.sh



# How to Monitor Your AVAX Node via telegram

Avalanchego telegram bash script

This telegram alert script checks avalanchego health status;

- If NODE is not healthy then it will send and ALERT message
- IF unhealty NODE is healty again then it will send ALERT RESOLVED message

This telegram alert script checks sar avg total cpu usages;

- If NODE CPU usage is greater than %40 then it will send and ALERT message
- Else if NODE CPU usage is normal again then it will send ALERT RESOLVED message



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

./install_avax_monitor.sh -t <YOUR TELEGRAM TOKEN> -c <YOUR TELEGRAM CHAT ID> -p <CPU THRESHOLD> 



# Example:

./install_avax_monitor.sh -t 13031231111111AAEx-kIC9E1237L111111111123ongZ3_c-g -c 10522222228 -p 50.00


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

