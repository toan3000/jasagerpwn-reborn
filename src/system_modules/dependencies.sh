#
# Dependencies Module
#
# Author: Leg3nd @ https://leg3nd.me
#

# Need the cleanup module
source src/system_modules/utility.sh

function ask_install(){
  while true; do 
    echo -e "\e[01;32m[+]\e[00m NOTICE: Some dependencies were not found installed and are REQUIRED for certain functions."
    echo -e "\e[01;32m[+]\e[00m You should use a stable internet connection for this!!"
    echo -n -e "\n\e[01;32m[?]\e[00m Do you want to install them now? (y/n): "
    read -e install_choice

    if [ "${install_choice}" == "y" ] || [ "${install_choice}" == "Y" ]; then
      echo -e "\e[01;31m[!]\e[00m Installing dependencies...."
      apt-get update  > /dev/null 2>&1
      echo -e "\e[01;31m[!]\e[00m Installing dependencies...."
      install_deps
      break
    elif [ "${install_choice}" == "n" ] ||  [ "${install_choice}" == "n" ]; then
      echo -e "\e[01;31m[!]\e[00m Continuing on..."
      break
    else
      echo -e "\e[01;31m[!]\e[00m ERROR: Please choose y or n."
    fi
  done

}

function check_deps(){

  apache2check=`dpkg -l | grep apache2 | awk '{print $2}' | head -n 1`
  apache2phpcheck=`dpkg -l | grep "libapache2-mod-php5" | awk '{print $2}' | head -n 1`
  sshpasscheck=`dpkg -l | grep sshpass | awk '{print $2}' | head -n 1`
  gitcheck=`dpkg -l | grep git | awk '{print $2}' | head -n 1`
  svncheck=`dpkg -l | grep subversion | awk '{print $2}' | head -n 1`
  terminatorcheck=`dpkg -l | grep terminator | awk '{print $2}' | head -n 1`
  
  if [ ${debug} == "1" ]; then

    # Debug mode
    if [ ! ${apache2check} ] || [ ! ${apache2phpcheck} ] || [ ! ${sshpasscheck} ] || [ ! ${gitcheck} ] || [ ! "${terminatorcheck}" ] || [ ! "${svncheck}" ] ||  [ ! -e "$(which mdk3)" ] || [ ! -e "/opt/beef" ] || [ ! -e "$(which msfconsole)" ]; then
      ask_install
    else
      echo -e "\e[01;34m[-]\e[00m All dependencies were found. Full functionality will be available." | tee -a ${debug_output}
    fi
  
  else
  
    # Normal, non-debug mode.
    if [ ! ${apache2check} ] || [ ! ${apache2phpcheck} ] || [ ! ${sshpasscheck} ] || [ ! ${gitcheck} ] || [ ! "${terminatorcheck}" ] || [ ! "${svncheck}" ] ||  [ ! -e "$(which mdk3)" ] || [ ! -e "/opt/beef" ] || [ ! -e "$(which msfconsole)" ]; then
      ask_install
    else
      echo -e "\e[01;34m[-]\e[00m All dependencies were found. Full functionality will be available."
    fi
  
  fi

}

function install_deps(){

  # Apache 2 Check
  if [ ! ${apache2check} ]; then
    echo -e "\e[01;31m[!]\e[00m No apache2 server was detected... Installing.."
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "sudo apt-get -y install apache2 && update-rc.d -f apache2 remove"
  elif [ ! ${apache2phpcheck} ]; then
    echo -e "\e[01;31m[!]\e[00m No apache2 PHP5 module was detected... Installing.."
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "sudo apt-get -y install libapache2-mod-php5 && a2enmod php5"
  fi

  # SSHPass Remote Command Execution Check
  if [ ! ${sshpasscheck} ]; then
    echo -e "\e[01;31m[!]\e[00m No SSHPASS was detected... Installing.."
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "sudo apt-get -y install sshpass"
  fi

  # Terminator Check
  if [ ! ${terminatorcheck} ]; then
    echo -e "\e[01;31m[!]\e[00m No Terminator console was detected... Installing.."
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "sudo apt-get -y install terminator"
  fi
  
  # GIT check
  if [ ! ${gitcheck} ]; then
    echo -e "\e[01;31m[!]\e[00m No Git was detected... Installing.."
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "sudo apt-get -y install git"
  fi

  # Subversion Check
  if [ ! "${svncheck}" ]; then
    echo -e "\e[01;31m[!]\e[00m No Subversion was detected... Installing.."
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "sudo apt-get -y install subversion"
  fi

  # MDK3	 Deauthentication Check
  if [ ! -e "$(which mdk3)" ]; then
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "apt-get -y install build-essential gcc linux-headers-`uname -r`"
    xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "wget -O /tmp/mdk.tar.gz http://homepages.tu-darmstadt.de/~p_larbig/wlan/mdk3-v6.tar.bz2 && cd /tmp ; tar xvf mdk.tar.gz && cd mdk3-v6 && make && make install"
  fi

  # Aireplay-ng DeAuthentication Check
  if [ ! -e "$(which aireplay-ng)" ]; then
    echo -e "\e[01;31m[!]\e[00m No Aircrack-ng suite was detected... Installing.."
    xterm -geometry 75x10+464+446 -bg black -fg green -T "[JasagerPwn] v$version -  Dependencies Installation" -e "svn co http://svn.aircrack-ng.org/trunk/ aircrack-ng && cd aircrack-ng && make && make install && airodump-ng-oui-update" 
  fi
  
  # BeEf Browser Exploitation Framework Check
  if [ ! -e "/opt/beef" ] && [ ! -e "/opt/beef/beef" ]; then
    # Detect Kali linux
    if [ -e "/usr/share/beef-xss" ]; then
      ln -s /usr/share/beef-xss /opt/beef
    else
      echo -e "\e[01;31m[!]\e[00m BeEf Exploitation Framework was not detected... Installing.."
      xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "apt-get update && apt-get -y install curl ruby build-essential ruby1.9.3 libsqlite3-ruby libsqlite3-dev libssl-dev"
      xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "curl https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable && rvm autolibs enable && rvm reinstall all --force && gem install bundler"
      xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "cd /opt && git clone git://github.com/beefproject/beef.git"
      xterm -geometry 75x10+464+446 -bg black -fg green -T "JasagerPwn v${version} -  Dependencies Installation" -e "cd /opt/beef && bundle install"
    fi
  fi
  
  # Metasploit Check
  if [ ! -e "$(which msfconsole)" ]; then echo && echo -e "\e[01;31m[!]\e[00m ERROR: Metasploit was not found.. please install it." ; cleanup; fi
}
