#!/bin/bash
# dock_left.sh
# Dock the active window to the left side of the screen
# (or right side of the previous screen, if left docked and dual screen)
#
# Requires: wmctrl, xprop, xwininfo
#
# Author: Nathan Barraille <nathan.barraille@gmail.com>
# Date: 01/2011

################################# PARAMS ##############################
#configFile=/home/nbarraille/Scripts/aeroSnap/screen_conf
configFile=screen_conf
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

# gets current screen
currentScreen=-1
i=1
while [[ $currentScreen -eq -1 ]]; do
    if [[ $numberScreens -eq $i ]] || [[ $windowMiddle -lt ${screensLeft[$i]} ]]; then
        currentScreen=$(($i - 1))
    fi
    let i++
done

halfScreen=$((${screensWidth[$currentScreen]} / 2))

# reajusts window detection to be tolerant with the window decoration width
#minBoundary=$((${screensLeft[$currentScreen]} - $maxWinDecWidth))
#maxBoundary=$((${screensLeft[$currentScreen]} + $maxWinDecWidth))
#if [[ $windowLeft -gt $minBoundary ]] && [[ $windowLeft -lt $maxBoundary ]]; then
#    echo "DERP"
#    windowLeft=${screensWidth[$currentScreen]}
#fi

# detects if the window is already docked left
dockedLeft=-1
i=0
while [[ $i -lt $numberScreens ]] && [[ $dockedLeft -eq -1 ]]; do
  if [[ $windowLeft -eq $((${screensLeft[$i]} + 1)) ]] && [[ $windowWidth -eq $halfScreen ]]; then
        halfScreen=$((${screensWidth[$(($currentScreen - 1))]} / 2))
        dockedLeft=$i
    fi
    let i++
done


# performs the move
if [[ $dockedLeft -eq -1 ]]; then
    # Dock the window on the left of the current screen
    wmctrl -r :ACTIVE: -b remove,maximized_horz
    wmctrl -r :ACTIVE: -e 0,${screensLeft[$currentScreen]},0,$halfScreen,-1
    wmctrl -r :ACTIVE: -b add,maximized_vert
elif [[ $dockedLeft -ne 0 ]]; then
    # Dock the window on the right of the previous screen
    wmctrl -r :ACTIVE: -b remove,maximized_horz
    wmctrl -r :ACTIVE: -e 0,$((${screensLeft[$currentScreen]} - $halfScreen)),0,$halfScreen,-1
    wmctrl -r :ACTIVE: -b add,maximized_vert
fi
