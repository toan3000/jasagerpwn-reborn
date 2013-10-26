#
# Leg3nd's DeAuthentication Script Attack Module
#
# Author: Leg3nd @ https://leg3nd.me
#
################ Module Configuration ##
# Module Title
title="[DeAuth] Aireplay Script"
# Create a description for menu
description="Automated Aireplay-ng AP DeAuthentication"
# Letter keys/commands to select item in menu
bindings='A|a'
#########################################

# Variables

# Start Function
function start_aireplay(){
  echo -e "\e[01;34m[>]\e[00m Running Aireplay-ng AP DeAuthentication Attack..."
  xterm -geometry 75x12+464+265 -bg black -fg green -T "[JasagerPwn] v${version} - Leg3nd's Deauth" -e "bash src/deauth.sh ${deauth_interface} ${deauth_whitelist}" &
  pid_deauth=`echo $!`
}

# Stop Function
function stop_aireplay() {
  echo -e "\e[01;34m[>]\e[00m Stopping Aireplay-ng AP DeAuthentication Attack..."
  xterm -geometry 75x10+464+446 -bg black -fg green -T "[JasagerPwn] v${version} - Killing DeAuth" -e "kill -9 ${pid_deauth} 1> /dev/null 2> /dev/null ; killall -9 aireplay-ng"
}