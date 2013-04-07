#!/bin/bash
# updateScreenConf.sh
# Should be executed at boot time to update the configuration of the screens
# This allows to use xrandr which is to slow to be executed every time
#
# Requires: xrandr
#
# Author: Nathan Barraille <nathan.barraille@gmail.com>
# Date: 01/2011

################################# PARAMS ##############################
configFile=./screen_conf

################################## RUN ################################

# gets screens info
screensInfo=(`xrandr | grep " connected " | cut -d ' ' -f 3`)

# gets number of screens
numberScreens=${#screensInfo[*]}

i=0
while [ $i -lt $numberScreens ]; do
    screensWidth[$i]=`echo ${screensInfo[$i]} | cut -d 'x' -f 1`
    screensLeft[$i]=`echo ${screensInfo[$i]} | cut -d '+' -f 2`
    let i++
done

# orders the screens (left first)
if [ $numberScreens -eq 2 ] && [ ${screensLeft[0]} -gt ${screensLeft[1]} ]; then
    tempWidth=${screensWidth[0]}
    tempLeft=${screensLeft[0]}
    screensWidth[0]=${screensWidth[1]}
    screensLeft[0]=${screensLeft[1]}
    screensWidth[1]=$tempWidth
    screensLeft[1]=$tempLeft
fi

# writes the screen config in the config file
i=0
rm $configFile
while [ $i -lt $numberScreens ]; do
    echo ${screensLeft[$i]} " " ${screensWidth[$i]} >> $configFile
    let i++
done
