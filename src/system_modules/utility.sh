#
# Utility Functions Module
#
# Author: Leg3nd @ https://leg3nd.me
#

# Cleanup Function
trap 'cleanup' 2
function cleanup(){
  echo -e "\n\e[01;34m[>]\e[00m Cleaning up..."
  
  # Remove Files
  rm /tmp/injectme.txt > /dev/null 2>&1
  rm /tmp/deauth* > /dev/null 2>&1
  rm /tmp/msfrc > /dev/null 2>&1
  rm /tmp/x86.powershell.alnum > /dev/null 2>&1
  rm /tmp/x64.powershell.alnum > /dev/null 2>&1
  rm -rf ${java_www} > /dev/null 2>&1
  rm -rf ${javaapplet_www} > /dev/null 2>&1
  rm -rf ${fakeupdate_www} > /dev/null 2>&1
  rm -rf ${clickjack_www} > /dev/null 2>&1
  rm /tmp/jasagerpwn_modules.tmp > /dev/null 2>&1
  
  # Kill Processes and Services
  xterm -geometry 75x10+464+446 -bg black -fg green -T "[JasagerPwn] v${version}" -e "kill -9 ${pid_mdk3} > /dev/null 2>&1" > /dev/null 2>&1
  xterm -geometry 75x10+464+446 -bg black -fg green -T "[JasagerPwn] v${version}" -e "killall -9 aireplay-ng > /dev/null 2>&1 ; kill -9 ${pid_deauth} > /dev/null 2>&1" > /dev/null 2>&1
  service apache2 stop > /dev/null 2>&1
  
  # Clear our IPtables
  iptables -F ; iptables -X  ; iptables -F -t nat ; iptables -X -t nat
  
  if [ ${debug} == "1" ]; then
    echo -e "\e[01;34m[>]\e[00m Exiting Gracefully.." | tee -a ${debug_output}
  else
    echo -e "\e[01;34m[>]\e[00m Exiting Gracefully.."  
  fi
  
  exit 1
}

# Gather debug information for troubleshooting
function debug(){
  # Get some infromation about the pineapple configuration
  echo -e "\n--------PINEAPPLE SYSTEM INFORMATION--------\n" | tee ${debug_output}
  sshpass -p ${pineapple_password} ssh -o StrictHostKeyChecking=no root@${pineapple_ip} 'iwconfig ; echo -e "\n\n" ; ifconfig -a ; echo -e "\n\n" ; ls /pineapple/components/infusions/ ; echo -e "\n\n" ; iptables -S ; echo -e "\n\n" ; iptables -S -t nat ; echo -e "\n\n"' | tee -a ${debug_output}

  # Get some infromation about the attacker system configuration
  echo -e "\n--------ATTACKER SYSTEM INFORMATION--------\n" ; echo -e "\n\n" | tee -a ${debug_output}
  ifconfig -a | tee -a ${debug_output} ; echo -e "\n\n" | tee -a ${debug_output}
  iwconfig | tee -a ${debug_output} ;  echo -e "\n\n" | tee -a ${debug_output}
  lsb_release -a | tee -a ${debug_output} ; echo -e "\n\n" | tee -a ${debug_output}
  ping -c 3 ${pineapple_ip} | tee -a ${debug_output} ; echo -e "\n\n" | tee -a ${debug_output}
  which msfconsole | tee -a ${debug_output} ; echo -e "\n\n" | tee -a ${debug_output}
  which mdk3 | tee -a ${debug_output} ; echo -e "\n\n" | tee -a ${debug_output}
  ls /opt | tee -a ${debug_output} ; echo -e "\n\n" | tee -a ${debug_output}
  cat /etc/default/keyboard | tee -a ${debug_output}
  
  # Get JasagerPwn configuration & information
  cat "$(basename $0)" | tee -a ${debug_output} ; echo -e "\n\n" | tee -a ${debug_output}
  svn info | tee -a ${debug_output}
  for x in $(find . -type f -iname '*.sh'); do md5sum ${x} | tee -a ${debug_output} ; done
  echo -e "\n\n"
  cat /etc/default/keyboard ; echo -e "\n\n" | tee -a ${debug_output}
  
}

# Update Code via SVN
function update(){
  svn cleanup
  svn up
  exit 0
}

# Print help
function help(){
 
 echo "
 JasagerPwn[Reborn] Pineapple Attack Vector Script
             - Version ${version} -
      
 (C)opyright 2013 Leg3nd @ https://leg3nd.me

  Usage: bash jasagerPwn 

  Options:
   -h         :  Help Screen and Switches. More Information In top of script.
   -d         :  Debug mode. This will gather system information, pause consoles, and log output.
   -u         :  Update JasagerPwn.
   -i         :  Pineapple Interface [EG: wlan0]
   -m         :  Mac Payload (.pkg) [For Fake Update]
   -w         :  Windows Payload (.exe) [ For Fake Update / Java Injection]
"
   exit 1
}

# Run command on remote pineapple
function pineapple_command(){
  echo -e "\n\e[01;34m[>]\e[00m Running Command on Pineapple: ${command}"
  
  if [ ${debug} == "1" ]; then
    xterm -hold -geometry 75x8+100+0 -T "Pineapple Command" -e "sshpass -p ${pineapple_password} ssh -o StrictHostKeyChecking=no root@${pineapple_ip} '${command}'"
    sshpass -p ${pineapple_password} ssh -o StrictHostKeyChecking=no root@${pineapple_ip} '${command}' | tee -a ${debug_output}
  else
    xterm -geometry 75x8+100+0 -T "Pineapple Command" -e "sshpass -p ${pineapple_password} ssh -o StrictHostKeyChecking=no root@${pineapple_ip} '${command}'"
  fi
  
}
