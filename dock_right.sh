#!/bin/bash
# dock_right.sh
# Dock the active window to the right side of the screen
# (or left side of the next screen, if right docked and dual screen)
#
# Requires: wmctrl, xprop, xwininfo
#
# Author: Nathan Barraille <nathan.barraille@gmail.com>
# Date: 01/2011

################################# PARAMS ##############################
configFile=/home/nbarraille/Scripts/aeroSnap/screen_conf
maxWinDecWidth=10
################################## RUN ################################
# reads config file to get screens info
i=0
while read line; do
    screensLeft[$i]=`echo $line | cut -d ' ' -f 1`
    screensWidth[$i]=`echo $line | cut -d ' ' -f 2`
    let i++
done < $configFile
numberScreens=${#screensLeft[*]}

# gets window info
windowId=`xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)"| cut -d ' ' -f 5`
windowWidthLine=`xwininfo -id $windowId | grep "Width: "`
windowLeftLine=`xwininfo -id $windowId | grep "Absolute upper-left X:"`
windowLeft=$((${windowLeftLine:24}))
windowWidth=$((${windowWidthLine:8}))
windowMiddle=$(($windowLeft + $(($windowWidth / 2))))
windowRight=$(($windowLeft + $windowWidth))

# gets current screen
currentScreen=-1
i=1
while [ $currentScreen -eq -1 ]; do
    if [ $numberScreens -eq $i ] || [ $windowMiddle -lt ${screensLeft[$i]} ]; then
        currentScreen=$(($i - 1))
    fi
    let i++
done

halfScreen=$((${screensWidth[$currentScreen]} / 2))

# reajusts window detection to be tolerant with the window decoration width
minBoundary=$(($((${screensLeft[$currentScreen]} + ${screensWidth[$currentScreen]})) - $maxWinDecWidth))
maxBoundary=$(($((${screensLeft[$currentScreen]} + ${screensWidth[$currentScreen]})) + $maxWinDecWidth))
if [ $windowRight -gt $minBoundary ] && [ $windowRight -lt $maxBoundary ]; then
    windowRight=${screensWidth[$currentScreen]}
fi

# detects if the window is already docked right
dockedRight=-1
i=0
while [ $i -lt $numberScreens ] && [ $dockedRight -eq -1 ]; do
    if [ $windowRight -eq $((${screensLeft[$i]} + ${screensWidth[$i]})) ] && [ $windowWidth -eq $halfScreen ]; then
        halfScreen=$((${screensWidth[$(($currentScreen + 1))]} / 2))
        dockedRight=$i
    fi
    let i++
done

# performs the move
if [ $dockedRight -eq -1 ]; then
    # Dock the window on the right of the current screen
    wmctrl -r :ACTIVE: -b remove,maximized_horz
    wmctrl -r :ACTIVE: -e 0,$((${screensLeft[$currentScreen]} + $halfScreen)),0,$halfScreen,-1
    wmctrl -r :ACTIVE: -b add,maximized_vert
else
    # Dock the window on the left of the next screen
    wmctrl -r :ACTIVE: -b remove,maximized_horz
    wmctrl -r :ACTIVE: -e 0,$((${screensLeft[$currentScreen]} + ${screensWidth[$currentScreen]})),0,$halfScreen,-1
    wmctrl -r :ACTIVE: -b add,maximized_vert
fi

