# How to Monitor Your AVAX Node via telegram

Avalanchego telegram bash script



## Preparing the environment

### Updates
```bash
# Fetch the list of available updates, upgrade current
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
sudo apt-get autoremove -y
sudo apt-get autoclean -y


# Install unattended-upgrades
# sudo apt-get install unattended-upgrades apt-listchanges -y -qq
# Enable unattended upgrades

sudo apt-get install mailutils wget curl jq net-tools -y
sudo apt-get install cron-apt
sudo reboot
```
