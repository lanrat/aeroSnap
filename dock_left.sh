#!/bin/bash
# dock_left.sh
# Dock the active window to the right side of the screen
# (or left side of the next screen, if right docked and dual screen)
#
# Requires: wmctrl, xprop, xwininfo
#
# Author: Nathan Barraille
# nathan.barraille@gmail.com

# gets full width
fullLine=$(xwininfo -root | grep "Width")
fullWidth=$((${fullLine:8}))
###echo $fullWidth

# gets number of screens
if [ $fullWidth -gt 1920 ]
then
    numberScreens=2
else
    numberScreens=1
fi
###echo $numberScreens

screenWidth=$(($fullWidth / $numberScreens))
halfScreen=$(($screenWidth / 2))
###echo $screenWidth
###echo $halfScreen


# gets the horizontal position of the current window
windowId=`xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)"| cut -d ' ' -f 5`
windowWidthLine=`xwininfo -id $windowId | grep "Width: "`
windowLeftLine=`xwininfo -id $windowId | grep "Absolute upper-left X:"`
windowLeft=$((${windowLeftLine:24}))
windowWidth=$((${windowWidthLine:8}))
windowRight=$(($windowLeft + $windowWidth))
minBoundary=$(($screenWidth - 10))
maxBoundary=$(($screenWidth + 10))
if [ $windowLeft -gt $minBoundary ] && [ $windowLeft -lt $maxBoundary ]
then
    windowLeft=$screenWidth
fi


###echo $windowLeft
###echo $windowRight



if [ $numberScreens -gt 1 ] && [ $windowLeft -eq $screenWidth ] && [ $windowWidth -eq $halfScreen ]
then
    # Dock the window on the right of the previous screen
    wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
    wmctrl -r :ACTIVE: -e 0,$halfScreen,0,$halfScreen,100
    wmctrl -r :ACTIVE: -b add,maximized_vert
else
    echo "is in else"
    # Dock the window on the left of the current screen
    centerWindow=$((($windowLeft + $windowRight)/2))
    if [ $centerWindow -gt $screenWidth ]
    then
        newLeft=$screenWidth
    else
        newLeft=0
    fi
    wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
    wmctrl -r :ACTIVE: -e 0,$newLeft,0,$halfScreen,100
    wmctrl -r :ACTIVE: -b add,maximized_vert
fi

