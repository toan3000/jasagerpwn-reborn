#
# Example Attack Module
#
# Note: Write your variables as if you were relative to the root "jasagerpwn" script

################ Module Configuration ##
# Module Title
title="Example"
# Create a description for menu
description="Example Attack Module"
# Letter keys/commands to select item in menu
bindings="E|e"
#########################################

# Variables
var1="foobarr"

# Utility Functions
function echo_foo(){
 echo "Foo.."
}

# Start Function - You are going to want to setup your attack vector in this function
# For example: Start metasploit, setup an apache server / website, run commands on 
# the pineapple, etc.
function start_example(){
  echo -e "\e[01;34m[>]\e[00m Starting Example Attack Module..."
  
  # Run the function
  echo_foo
  
  # Open a fancy little window for mointoring, etc.
  xterm -geometry 93x56+796+77 -fg green -bg black -T "[JasagerPwn] v${version} - Example" -e "echo \"$var1 bar\" ; sleep 10" &
  exmaple_pid=$(echo $!) # hold the PID so we can kill it
  
  # Run a command on the pineapple - the quotation escaping can be tricky.
  command="echo \"This is a command on the pineapple...\"" # set the command
  pineapple_command # call the function
}

# Stop Function - Kill all your processes, reset the pineapple to provide normal internet access.
# Note: the "pineapple_wan_iptables" variable is there to reset internet and general cleanup,
# this helps ensure stability for long periods while switching attack vectors.
function stop_example(){
  echo -e "\e[01;34m[>]\e[00m Stopping Example Attack Module..."
  # set our command to stop the attack
  command="/pineapple/components/infusions/codeinject/stop.sh"
  pineapple_command # call the function
  kill -9 $example_pid # kill our fancy window
}
