**Disclaimer: This script is intended for LEGAL purposes ONLY. By downloading the following material you agree that the intended use of the previously mentioned is for LEGAL and NON-MALICIOUS purposes ONLY. This means while gaining client side exploits, you have the correct documentation and permissions to do so in accordance with all US and International laws and regulations.  Nor I nor any associates at Hak5 condone misuse of this code or its features.**
<br><br>
<b>Responsibility Disclosure: Hak5 has no affiliation with this code base. This code is not reviewed or verified by Hak5; therefore they do not take any responsibility for any of this code and its functionality. If you are paranoid (good!) - then look over the code yourself to be safe.</b>

<b>Donate</b><br>
Paypal: <a href='https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=N26RBKZXPSZCA'>https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&amp;hosted_button_id=N26RBKZXPSZCA</a>
<br>
Bitcoin: 1PbopGpA8XBJ6YQggAeEgM1jbkbn39RDTF<br>
<br>
<h2>Description</h2>
This script is intended to increase attack vector consistency and stability by automating the process. For penetration testers, the most important thing is having a stable and well prepared attack vector - because you only get one chance.<br>
<br>
This script provides exactly that, a way to prepare and automate advanced and complex attack vectors in the lab, and then use them in the field.<br>
<br>
<br>
<br>
<h2>Compatibility / Troubleshooting</h2>
<b>Script Requirements:</b> Pineapple <a href='MK4.md'>3.0.0</a> <a href='MK5.md'>1.0.0</a> - Debian based Linux.<br>
<br>
<b>Tested Configuration:</b> Pineapple MK5 1.0.0, Crunchbang Linux | Kali Linux<br>
<blockquote>USB Battery - Pineapple (Router: wlan0 | ICS: wlan1) -> Alfa (DeAuth)<br>
Attacker IPs: (2 man red-team) - 172.16.42.2 172.16.42.3  <br></blockquote>

<h3>Setting up the Script:</h3>
Open up jasagerPwn in your favorite text editor. Look over all the variables in this file and read my comments; they should clearly explain what is what.Adjust the variables based on your pineapple setup. If anything is unclear, feel free to ask me and I can clarify.<br>
<br>
After you setup the script, connect to a stable internet connection and run the script - this will prompt you to install dependencies. This will take a few minutes, after that is completed you can connect to the pineapples network (either via wireless or ethernet) and relaunch the script.<br>
<br>
Thats it. You should be able to use the attack modules.<br>
<br>
<h3>Dependencies Installation:</h3>
Dependencies will attempt to install automatically if they are not detected on your system, f this fails for you - please look at the src/system_modules/dependencies.sh and just install it yourself. I've tested installation processes on Debian, Crunchbang, and Kali Linux.<br>
<br>
Infusion dependencies are also required for attack modules. Please refer to the list of attack modules below and their corresponding "Requirements".<br>
<br>
<h3>Known Issues:</h3>
CodeInject Speed - CodeInject is known to have performance issues even with a large swap partition. It will work, however sometimes the proxy can cause it to be so sluggish that it seems unusable. I'll be working on a different proxy methodology in the future that will hopefully be more efficient.<br>
<br>
SSLStrip MK5 - SSLStrip on my MK5 does not work by default currently. There are python module import errors that need to be resolved in the infusion.<br>
If you can get the infusion working (mine does), then this attack module will work for you. Otherwise just wait for a fix from Whistlemaster.<br>
<br>
<br>
<h2>Included Attack Vector Modules</h2>
<ul><li>browserPwn - Redirect LAN to Metasloits auxillary module browser_autopwn. This will be detected by AV.<br>
<blockquote>- Victim Support: Mac OSX, Windows, Linux.<br>
- Requirements: Metasploit, DNSSpoof Infusion<br></blockquote></li></ul>

<ul><li>browserPwn iFrame - Inject an invisible iFrame that loads Metasloits auxillary module browser_autopwn. This will be detected by AV.<br>
<blockquote>- Victim Support: Mac OSX, Windows, Linux.<br>
- Requirements: Metasploit, Strip-N-Inject Infusion<br></blockquote></li></ul>

<ul><li>Fake Update - Redirect LAN to a realistic fake update page with a <a href='custom.md'>custom</a> payload download.<br>
<blockquote>- Victim Support: Mac OSX, Windows.<br>
- Requirements: Metasploit, DNSSpoof Infusion <br></blockquote></li></ul>

<ul><li>Click Jacking - Hijack the entire DOM with an injected <code>&lt;div&gt;</code>. No matter where you click, it downloads a payload.<br>
<blockquote>- Victim Support: Mac OSX, Windows.<br>
- Requirements: Metasploit, Strip-N-Inject Infusion <br></blockquote></li></ul>

<ul><li>Java Applet Injection - Transparently inejcts an OS agnostic java applet into the victims browsing session.<br>
<blockquote>- Victim Support: Mac OSX, Windows, Linux.<br>
- Requirements: Metasploit, Strip-N-Inject Infusion <br></blockquote></li></ul>

<ul><li>Java Applet Redirect - Redirects users to a Java page with an OS agnostic java applet payload.<br>
<blockquote>- Victim Support: Mac OSX, Windows, Linux.<br>
- Requirements: Metasploit, DNSSpoof Infusion <br></blockquote></li></ul>

<ul><li>SSLStrip - Remove SSL from the victims connections and sniff credentials.<br>
<blockquote>- Victim Support: Mac OSX, Windows, Linux.<br>
- Requirements: SSLStrip Infusion <br></blockquote></li></ul>

<ul><li>Aireplay-ng - DoS APs and try to make them join yours via custom aireplay-ng script.<br>
<blockquote>- This script will run aireplay-ng against the AP broadcast, note that this works best if you are closer to the AP than the client</blockquote></li></ul>

<ul><li>MDK3 - Deauths nearby clients from their APs and try to make them join yours via MDK3.<br>
<blockquote>- This script will run MDK3 to deauthenticate clients from an AP directly note that this works best if you are close to the clients. As a result, this will have slightly better average range effectiveness.</blockquote></li></ul>

<h2>Included Payloads (w/ Source & Documentation)</h2>
I have included 2 of my most successful and efficient payloads for your use. One for Mac OSX, and one for Windows - both will completely bypass signature based anti-virus and most behavioral HIPS as well.<br>
<br>
<br>
<b>Apple_MacOSX_Update.pkg</b>
<br>
Description: This is 4 lines of BASH stuck in an apple postinstall script. No signature AV can ever detect this because it uses system commands and contains no binaries in the package.<br>
<br>
This will spawn 2 root shells to the following addresses:<br>
172.16.42.2 6446<br>
172.16.42.3 6446<br>
<br>
Persistence:<br>
It will also add a persistent backdoor that will spawn these 2 every 3 minutes (sudo crontab -<br>
<br>
Metasploit Listener:<br>
<pre><code>set PAYLOAD generic/shell_reverse_tcp<br>
set LHOST 0.0.0.0<br>
set LPORT 6446<br>
set ExitOnSession false<br>
set AutoRunScript ""<br>
exploit -j<br>
</code></pre>

<b>shellcode-tcp.exe</b>
<br>
Description: This is a windows meterpreter shell that was encoded into base 64, embedded into a python script that executes shellcode on the system and then compiled into an executable. It is not detect at the time of this writing. If the signature becomes detected, just make a new one.<br>
<br>
This will spawn 2 meterpreter shells to the following addresses:<br>
172.16.42.2 587<br>
172.16.42.3 587<br>
<br>
Persistence:<br>
It will also add a persistent backdoor to Windows that will these 2 shells every 3 minutes (schtasks /query /tn winupdate)<br>
<br>
Metasploit Listener:<br>
<pre><code>set PAYLOAD windows/meterpreter/reverse_tcp<br>
set LHOST 0.0.0.0<br>
set LPORT 587<br>
set ExitOnSession false<br>
set EXITFUNC thread<br>
set AutoRunScript ""<br>
exploit -j<br>
</code></pre>

<h2>Included Resources</h2>
I have included a few resources that I find useful on pentests with the pineapple.<br>
<br>
<ul><li>Metasploit Scripts: These are resource scripts that can be executed from msfconsole or in meterpreter. Creates a nice way to automate post-exploitation at your fingertips. In order to run them use "resource resources/metaspoit_scripts/file_collector.rc".</li></ul>

<ul><li>file_collector.rc: Automatically search for documents on the system and download them.<br>
enum_app_data.rc: Enumerate passwords and other data from browsers, putty, etc.</li></ul>

<ul><li>keylog_recorder.rc: Start a keylogger that will poll and automatically collect keystokes. You can use this then CTRL+Z to background the session.</li></ul>

<ul><li>mimikatz.rc: Dump cleartext passwords from memory. Hashses are great, but why deal with cracking when they are sitting in memory in clear text?</li></ul>

<ul><li>payload_inject.rc: Inject a meterpreter session into explorer.exe. This is like "duplicate" but you can send it to your red-team and not ever drop a binary on the system.</li></ul>

<ul><li>listeners.rc: This is useful for the other members of the red-team not running JasagerPwn. They can just "msfconsole -r listeners.rc" and be ready to receive shells</li></ul>

<ul><li>web_clone.sh: This is a simple wget command that I love to use to clone websites for phishing. It will put everything into a single index.html file.</li></ul>

Note: If you're preforming a MITM attack then you need to download all the resources that are hot-linked in index.html and then modify them to local, relative paths. This can be tedious but is what I have used to do every template in JasagerPwn<br>
<br>
<ul><li>airdrop-ng: This was an airdrop-ng attack module that I made before MDK3. I think MDK3 works better so I took it out and plopped it here.</li></ul>

<h2>Developing Attack Modules</h2>
This script was created in a modular architecture, allowing for relatively simple expansion of attack vectors. Use the "attack_module_example.sh" located in the resources directory for an example reference.<br>
<br>
There are just a few requirements when developing the modules:<br>
If you're making a local de-authentication module - use "deauth" or "dos" in the description string.<br>
You must have a "start_myname" and "stop_myname" function in that format (myname is arbitrary).<br>
<br>
You must have a unique "title", "description", and "bindings" variables.<br>
I recommend editing the src/system_modules/utility.sh - cleanup() function to cleanup after your module.<br>
<br><br>
<b>Module Submission:</b>
If you develop an attack module that you would like to have added into JasagerPwn, that is great! Just let me know and send me the code. If its a good idea; I'll code review it and add it into the script.<br>
<br>
<h2>Questions / Problems</h2>
<ul><li>Forum Post: <a href='https://forums.hak5.org/index.php?/topic/30588-script-jasagerpwn-20-reborn/'>https://forums.hak5.org/index.php?/topic/30588-script-jasagerpwn-20-reborn/</a>
</li><li>Questions: Feel free to ask here or in IRC (irc.hak5.org #pineapple).</li></ul>

<h2>Download / Update</h2>
<b>Download via Subversion (sudo apt-get install subversion):</b>
svn checkout <a href='http://jasagerpwn-reborn.googlecode.com/svn/trunk/'>http://jasagerpwn-reborn.googlecode.com/svn/trunk/</a> jasagerPwn<br>
<br><br>
<b>Update Script to Latest Revision:</b>
./jasagerPwn -u<br>
