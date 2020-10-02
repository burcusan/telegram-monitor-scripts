# How to Monitor Your AVAX Node via telegram

Avalanchego telegram bash script


## 1-) Download files from github

```bash


# Git clone:

git clone https://^Cthub.com/burcusan/scripts.git
cd scripts


```



## 2-) Installation


```bash

# Usage:

./install_avax_monitor.sh -t <TELEGRAM TOKEN>


# Example:

./install_avax_monitor.sh -t 1303123599:AAEx-kIC9E1237Lb5TVeoZ8123ongZ3_c-g


```




## 3-) Check script & log 


```bash

./check_avalanchego_status.sh > check_avalanchego_status.log

tail -f check_avalanchego_status.log

# Example Output :

 >>>> : Fri Oct  2 15:20:30 +03 2020
 >>>> : HTTP_CODE= 200
 >>>> : CURL_STATUS= 0
 >>>> : FILE= /tmp/tmp_check_Avalanchego
 >>>> : Avalanchego node is running!
 >>>> : Fri Oct  2 15:20:30 +03 2020 - [INFO] Avalanchego node is healthy ! -  health.getLiveness result.healthy=true hostname=oracle-1
 >>>> : true


``

