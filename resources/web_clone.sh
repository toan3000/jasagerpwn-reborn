#!/bin/bash
#
# Basic website cloning into a single index.html file - great for phishing.
#
# Note: If you are doing a MITM, you need to download all the resources that are being
# hotlinked from index.html (images,javascript, etc.) - since they cannot get to those servers.
#
# Author: Leg3nd @ https://leg3nd.me
#

if [ ! "$1" ]; then echo "[ERROR] Specify a URL as the first arg.." ; exit 0 ; fi

wget --no-check-certificate -O index.html -c -k -U "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)"  "$1"

exit 0
