\#!/bin/bash

# check for upx
if [ ! "$(which upx)" ]; then echo "You need to apt-get install upx..." ; exit 0 ; fi


in="dist/shellcodeexec.exe"
out="dist/shellcodeexec-upx.exe"

rm ${out} 2> /dev/null

upx -9 -o ${out} ${in}

exit 0
