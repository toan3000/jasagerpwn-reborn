----------------------------------------------------------------------------
 _____                                                    
/\___ \                                                   
\/__/\ \     __      ____     __       __      __   _ __  
   _\ \ \  /'__`\   /',__\  /'__`\   /'_ `\  /'__`\/\`'__\
  /\ \_\ \/\ \L\.\_/\__, `\/\ \L\.\_/\ \L\ \/\  __/\ \ \/ 
  \ \____/\ \__/.\_\/\____/\ \__/.\_\ \____ \ \____\\ \_\ 
   \/___/  \/__/\/_/\/___/  \/__/\/_/\/___L\ \/____/ \/_/ 
                                       /\____/            
                                       \_/__/             
 ____                         
/\  _`\                       
\ \ \L\ \__  __  __    ___    
 \ \ ,__/\ \/\ \/\ \ /' _ `\  
  \ \ \/\ \ \_/ \_/ \/\ \/\ \ 
   \ \_\ \ \___x___/'\ \_\ \_\
    \/_/  \/__//__/   \/_/\/_/
                              
Version 2.0 - Reborn                              
----------------------------------------------------------------------------

Disclaimer: This script is intended for LEGAL purposes ONLY. By downloading the following material 
you agree that the intended use of the previously mentioned is for LEGAL and NON-MALICIOUS purposes ONLY. 
This means while gaining client side exploits, you have the correct documentation and permissions to do so 
in accordance with all US and International laws and regulations. Nor I nor any associates at Hak5 condone 
misuse of this script or its features.


-------------
Description
-------------
This script is intended to increase attack vector consistency and stability by
automating the process. For penetration testers, the most important thing is
having a stable and well prepared attack vector - because you only get one chance.

This script provides exactly that, a way to prepare and automate advanced and complex
attack vectors in the lab, and then use them in the field. 


--------------------------------
Compatibility / Troubleshooting
--------------------------------
- Configuration Requirements: Pineapple MK5 1.0.0, Debian based Linux.

- Tested Configuration: Pineapple MK5 1.0.0, Crunchbang Linux | Kali Linux
   USB Battery - Pineapple (Router: wlan0 | ICS: wlan1) -> Alfa (DeAuth)
   Attacker IPs: (2 man red-team) - 172.16.42.2 172.16.42.3  
   Picture: https://leg3nd.me/cloud/public.php?service=files&t=a5eec2fddfd7a5336d55237c33a391db
  
- Dependencies will attempt to install automatically if they are not detected on your system,
  if this fails for you - please look at the src/system_modules/dependencies.sh and just install
  it yourself.

- This script was developed in crunchbang linux (debian). That means it will very likley work
  with most debian based distributions such as Ubuntu, Debian, Linux Mint, and Kali Linux.

- Any "injection" based attack vector will require the "CodeInject" infusion that is available
  in the pineapple bar. This include: Java Applet Injector, Click Jacking, and BeEf Hook.

-----------------------
Attack Vector Modules:
-----------------------
   - browserPwn - Redirect LAN to Metasloits auxillary module browser_autopwn. This will be detected by AV.
	- Victim Support: Mac OSX, Windows, Linux.
	- Requirements: Metasploit, DNSSpoof Infusion.

   - Fake Update - Redirect LAN to a realistic fake update page with a [custom] payload download.
	- Victim Support: Mac OSX, Windows.
	- Requirements: Metasploit, DNSSpoof Infusion.

   - Click Jacking - Hijack the entire DOM with an injected <div>. No matter where you click, it downloads a payload.
	- Victim Support: Mac OSX, Windows.
	- Requirements: Metasploit, CodeInject Infusion.

   - Java Applet Injection - Transparently inejcts an OS agnostic java applet into the victims browsing session.
	- Victim Support: Mac OSX, Windows, Linux.
        - Requirements: Metasploit, CodeInject Infusion.

   - Java Applet Redirect - Redirects users to a Java page with an OS agnostic java applet payload.
	- Victim Support: Mac OSX, Windows, Linux.
        - Requirements: Metasploit, DNSSpoof Infusion.

   - SSLStrip - Remove SSL from the victims connections and sniff credentials.
	- Victim Support: Mac OSX, Windows, Linux.
        - Requirements: SSLStrip Infusion.

   - Aireplay-ng - DoS APs and try to make them join yours via custom aireplay-ng script.
	- This script will run aireplay-ng against the AP broadcast, note that
	  this works best if you are closer to the AP than the client.

   - MDK3 - Deauths nearby clients from their APs and try to make them join yours via MDK.3
	- This script will run MDK3 to deauthenticate clients from an AP directy,
	  note that this works best if you are close to the clients. As a result,
	  this will have slightly better average range effectivness.


-------------------
Included Payloads
-------------------
I have included 3 of my most successful and effecient payloads for your use. One for Mac OSX,
and one for Windows - both will completely bypass signature based anti-virus and most behavioral
HIPS as well.

Please reference the README in payloads/payloads_README.md for more information.

--------------------------
Developing Attack Modules 
--------------------------
- This script was created in a modular architecture, allowing for relativley simple expansion
  of attack vectors. If you are interested in creating your own module, 

- Use the "attack_module_example.sh located in the resources/ folder for an example reference.

- There are just a few requirements when developing the modules:
	1: If you're making a de-authentication module - use "deauth" or "dos" in the description string.
	2: You MUST have a "start_SOMETHING" and "stop_SOMETHING" function in that format (SOMETHING is arbitrary)
	3: You MUST have a UNIQUE "title", "description", and "bindings" variables.
	4: I recommend editing the src/system_modules/utility.sh - cleanup() function to cleanup after your module.

---------------------
Questions / Problems
---------------------
- Forum Post: https://forums.hak5.org/index.php?/forum/78-mark-v/
- Google Code: https://code.google.com/p/jasagerpwn-reborn/
- Bug Submission: https://code.google.com/p/jasagerpwn-reborn/issues/entry
