#
# Main System Module - All the magic is up in here
#
# Author: Leg3nd @ https://leg3nd.me
#
########## Hard Coded / Dynamic Variables #
version="2.0"
rev="27" # dev branch revision
badchoice="0"
attack_running="0"
deauth_running="0"
attacking="0"
our_ip=$(ifconfig ${pineapple_interface} | grep "inet addr" | awk -F\: '{print $2}' | awk '{print $1}')
###########################################


############ Module Imports #
# Source our utility functions
source src/system_modules/utility.sh
# Source our dependency checking module
source src/system_modules/dependencies.sh
# Get our attacks from the attack_modules directory

# Parse command line options
while getopts "i:p:m:uhd" OPTIONS; do
  case ${OPTIONS} in
    w     ) export windows_payload=${OPTARG};;
    m     ) export mac_payload=${OPTARG};;
    i     ) export pineapple_interface=${OPTARG};;
    u     ) update;;
    d     ) debug;;
    h     ) help;;
    *     ) echo "[-] Unknown option.";;
  esac
done

function main(){  
  # Get debug information if enabled
  if [ ${debug} == "1" ]; then debug ; fi

  # Check our dependencies
  check_deps
  
  echo -e "\e[01;34m[>]\e[00m Loading attack modules.."
  if [ -e "/tmp/jasagerpwn_modules.tmp" ]; then rm /tmp/jasagerpwn_modules.tmp ; fi
  rm src/attack_modules/*~ > /dev/null 2>&1 # Cleanup Kate temp files
  for x in $(ls -1 src/attack_modules | grep \.sh); do
    x_name=$(echo ${x} | awk -F\. '{print $1}')
    
    if [ ${debug} == "1" ]; then
      echo -e "\e[01;34m[-]\e[00m Loading attack module: " ${x_name} | tee -a ${debug_output}
    else
      echo -e "\e[01;34m[-]\e[00m Loading attack module: " ${x_name}
    fi
    
    # Load the attack module functions
    source "src/attack_modules/${x}"
    # Store our attack modules in a file for later
    echo -e "module:${x},name:${x_name},description:${description},bindings:${bindings},title:${title},"${x_name}"_status:0" >> /tmp/jasagerpwn_modules.tmp
  done

  ###################################

  ############ System Checks #
  echo -e "\e[01;34m[>]\e[00m Checking environment..."
  if [ "${UID}" != "0" ]; then
    echo -e "\e[01;31m[!]\e[00m Error: You are not root.."
    cleanup
  fi

  # Check our interface
  interface=$(ifconfig | grep ${pineapple_interface} | awk '{print $1}' | head -n 1)
  if [ "$interface" != "${pineapple_interface}" ]; then
    echo -e "\e[01;31m[!]\e[00m Error: The pineapple interface: ${pineapple_interface} was not found.."
  fi
  ###################################

  
  # Main Menu Loop
  while true; do
    echo -e "\n\n"
    
    # Banner and non-dynamic menu
    cat src/banner.txt 2> /dev/null
    echo -e "\n\e[01;32m[*] Choose from the menu to toggle attacks [*]\e[00m\n"
    
    if [ "${badchoice}" == "1" ] && [ "${choice1}" != "" ] && [ "${attack_running}" == "1" ] && [ "${deauth_running}" == "1" ]; then
      echo -e "\n\e[01;31m[!]\e[00m Error: Please Choose From The Menu..\n"
    fi
    
    if [ "${attack_running}" == "1" ]; then
      echo -e "\e[01;31m[!]\e[00m Error: You're already running an attack module: ${current_attack}"
      echo -e "\n"
      attack_running="0"
    fi
    
    if [ "${deauth_running}" == "1" ]; then
      echo -e "\e[01;31m[!]\e[00m Error: You're already running a deauth module: ${current_deauth}"
      echo -e "\n"
      deauth_running="0" 
    fi

    # Dynamically populate our menu based on attack modules
    y=1
    while IFS1= read -r entry1
    do
      
      title=$(echo ${entry1} | awk -F"title:" '{print $2}' | awk -F\, '{print $1}')
      name=$(echo ${entry1} | awk -F"name:" '{print $2}' | awk -F\, '{print $1}')
      status=$(echo ${entry1} | awk -F"${name}"_status:"" '{print $2}' | awk -F\, '{print $1}')
      bindings=$(echo ${entry1} | awk -F"bindings:" '{print $2}' | awk -F\, '{print $1}')
      description=$(echo ${entry1} | awk -F"description:" '{print $2}' | awk -F\, '{print $1}')

      if [ $(echo ${status} | grep "1") ]; then
	echo -e "\e[01;31m[RUNNING]\e[00m [$y][${bindings}] ${title}: ${description}"      
      else
	echo -e "\e[01;32m[-]\e[00m [$y][${bindings}] ${title}: ${description}"
      fi
      
      ((y++))   

    done < "/tmp/jasagerpwn_modules.tmp"
      
    echo -e "\e[01;32m[-]\e[00m [CTRL+C] = Exit"
    echo -n -e "\n\e[01;32m[?]\e[00m Choice:  "    
    read -e choice1
    
    # Dynamically check the user choice based on attack modules
    y=1 ; badchoice="0"
    while IFS= read -r entry
    do
    
      # Get our bindings from the file for the case statement
      bindings=$(echo ${entry} | awk -F"bindings:" '{print $2}' | awk -F\, '{print $1}')
      shopt -s extglob
      case_extglob="+(${bindings}|${y})"
      
      case ${choice1} in
	${case_extglob})
	
	  # Enumerate module information
	  module=$(echo ${entry} | awk -F"module:" '{print $2}' | awk -F\, '{print $1}')
	  name=$(echo ${entry} | awk -F"name:" '{print $2}' | awk -F\, '{print $1}')
	  status=$(echo ${entry} | awk -F"${name}"_status:"" '{print $2}' | awk -F\, '{print $1}')
	  start_function="$(cat src/attack_modules/${module} | grep "start_" | awk -F\( '{print $1}' | awk '{print $2}')"
	  stop_function="$(cat src/attack_modules/${module} | grep "stop_" | awk -F\( '{print $1}' | awk '{print $2}')"
	  
	  # Toggle the status in the modules file
	  if [ $(echo ${status} | grep "0") ] || [ "$(echo ${entry} | egrep -i '(deauth|dos)' | grep "status:0")" ]; then
	  
	      # Make sure we dont accidently run multiple deauth modules
	      if [ "$(cat /tmp/jasagerpwn_modules.tmp | egrep -i '(deauth|dos)' | grep -i "status:1")" ] && [ "$(echo ${entry} | egrep -i '(deauth|dos)')" ]; then
		deauth_running="1"
		current_deauth="$(cat /tmp/jasagerpwn_modules.tmp |  egrep -i '(deauth|dos)' | grep "status:1" | awk -F"name:" '{print $2}' | awk -F\, '{print $1}')"
		break
	      else
		if [ "$(echo ${entry} | egrep -i '(deauth|dos)' | grep "status:0")" ]; then
		  # Start the module if none are found running
		  eval ${start_function}
		  sed -i "s/"${name}"_status:0/"${name}"_status:1/" /tmp/jasagerpwn_modules.tmp 
		  badchoice="0"
		  attacking="1"
		  break
		fi
	      fi
	      
	      # Make sure we dont accidently run multiple attack modules
	      if [ "$(cat /tmp/jasagerpwn_modules.tmp | egrep -v -i '(deauth|dos)' | grep -i "status:1")" ]; then
		attack_running="1"
		current_attack="$(cat /tmp/jasagerpwn_modules.tmp |  egrep -i -v '(deauth|dos)' | grep "status:1" | awk -F"name:" '{print $2}' | awk -F\, '{print $1}')"
		break
	      else
		if [ "$(echo ${entry} | egrep -v -i '(deauth|dos)' | grep "status:0")" ]; then
		  # Start the module if none are found running
		  eval ${start_function}
		  sed -i "s/"${name}"_status:0/"${name}"_status:1/" /tmp/jasagerpwn_modules.tmp 
		  badchoice="0"
		  attacking="1"
		  break
		fi
	      fi
	      	    
	  # Allow stopping of the deauth modules
	  elif [ $(echo ${status} | grep "1") ] && [ "$(echo ${entry} | egrep -i '(deauth|dos)')" ]; then
 	    # Stop the deauth module
	    eval ${stop_function}
	    sed -i "s/"${name}"_status:1/"${name}"_status:0/" /tmp/jasagerpwn_modules.tmp
	    badchoice="0"
	    attacking="0"
	  
	  # Allow stopping for the rest of the modules
	  elif [ $(echo ${status} | grep "1") ] && [ "$(echo ${entry} | egrep -v -i '(deauth|dos)')" ]; then
	    # Stop the module
	    eval ${stop_function}
	    sed -i "s/"${name}"_status:1/"${name}"_status:0/" /tmp/jasagerpwn_modules.tmp
	    badchoice="0"
	    attacking="0"
	    
	  fi
	  
	;;

	*) badchoice="1"
      esac
	  
    done < "/tmp/jasagerpwn_modules.tmp"
    
  done
  
  cleanup
  
}

