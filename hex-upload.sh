#! /bin/ash
echo

################################################################################
The zlib/libpng License

Copyright (c) 2014 oldtopman

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the use
of this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

    1. The origin of this software must not be misrepresented; you must not
       claim that you wrote the original software. If you use this software in a
       product, an acknowledgment in the product documentation would be
       appreciated but is not required.

    2. Altered source versions must be plainly marked as such,
       and must not be misrepresented as being the original software.

    3. This notice may not be removed or altered from any source distribution.
################################################################################

VERSION_STRING="upload-hex 0.3 by oldtopman"

####
##
##Script for burning .hex files to the onboard chip.
##
####

##
#Catch invalid/special input, display help.
##

##Help/invalid
if [ "x$1" = "x" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -gt 1 ]
  then
    echo "$VERSION_STRING"
    echo ""
    echo "Usage:"
    echo "upload-hex [OPTION] [FILE]"
    echo ""
    echo "-h, --help"
    echo "    Display this help message."
    echo ""
    echo "-v --version"
    echo " Display the version of the currently running software."
    echo ""
    echo "FILE is a .hex file prepared for upload to the onboard Leonardo"
    echo "This can be sourced from the IDE's temporary build directory."
    echo ""
    exit 0
fi

##Version
if [ "$1" = "-v" ] || [ "$1" = "--version" ]
  then
    echo "$VERSION_STRING"
    echo
    exit 0;
fi

##
#Set Variables
##
set -e
FILENAME="$(basename $1)"

if [ "$1" = $(basename $1) ]
  then
    FILENAME_WITHPATH="$(pwd)/$1"
  else
    FILENAME_WITHPATH="$1"
fi

##
#Create temporary working directory. (Delete old one if necessary.)
##
[ -d /tmp/upload-hex-tmp ] && rm -rf /tmp/upload-hex-tmp && echo "Old directory found, deleting."
mkdir -p /tmp/upload-hex-tmp
cd /tmp/upload-hex-tmp

##
#Move hex file into the directory.
##
if [ -f "$FILENAME_WITHPATH" ]
  then
    cp "$FILENAME_WITHPATH" .
  else
    echo "Exiting, file not found at $FILENAME_WITHPATH"
    echo
    rm -r /tmp/upload-hex-tmp
    exit 1
fi

##
#Process file.
##
echo "Merging sketch with bootloader."
/usr/bin/merge-sketch-with-bootloader.lua "$FILENAME"
echo "Closing the bridge."
/usr/bin/kill-bridge
echo "Burning the sketch."
/usr/bin/run-avrdude $FILENAME

##
#Clean up.
##
echo "Cleaning up temporary directories."
rm -r /tmp/upload-hex-tmp
echo "Script complete, upload successful!"
echo
