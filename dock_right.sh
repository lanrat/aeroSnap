#!/bin/bash
# dock_left.sh
# Dock the active window to the left side of the screen
# (or right side of the previous screen, if left docked and dual screen)
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
###echo "numb screen: " $numberScreens

screenWidth=$(($fullWidth / $numberScreens))
halfScreen=$(($screenWidth / 2))
###echo "screen width: " $screenWidth
###echo "half screen: " $halfScreen


# gets the horizontal position of the current window
windowId=`xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)"| cut -d ' ' -f 5`
windowWidthLine=`xwininfo -id $windowId | grep "Width: "`
windowLeftLine=`xwininfo -id $windowId | grep "Absolute upper-left X:"`
windowLeft=$((${windowLeftLine:24}))
windowWidth=$((${windowWidthLine:8}))
windowRight=$(($windowLeft + $windowWidth))
minBoundary=$(($screenWidth - 10))
maxBoundary=$(($screenWidth + 10))
if [ $windowRight -gt $minBoundary ] && [ $windowRight -lt $maxBoundary ]
then
    windowRight=$screenWidth
fi

###echo "window left: " $windowLeft
###echo "window right " $windowRight
###echo "window width :" $windowWidth


if [ $numberScreens -gt 1 ] && [ $windowRight -eq $screenWidth ] && [ $windowWidth -eq $halfScreen ]
then
    # Dock the window on the left of the next screen
    ###echo "Docking window left next screen"
    wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
    wmctrl -r :ACTIVE: -e 0,$screenWidth,0,$halfScreen,100
    wmctrl -r :ACTIVE: -b add,maximized_vert
else
    # Dock the window on the right of the current screen
    ###ECHO "Docking window right current screen"
    centerWindow=$((($windowLeft + $windowRight)/2))
    ###echo $centerWindow
    if [ $centerWindow -gt $screenWidth ]
    then
        newLeft=$(($fullWidth - $halfScreen))
    else
        newLeft=$halfScreen
    fi
    wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
    wmctrl -r :ACTIVE: -e 0,$newLeft,0,$halfScreen,100
    wmctrl -r :ACTIVE: -b add,maximized_vert
fi
