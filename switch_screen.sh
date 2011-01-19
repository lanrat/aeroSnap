#!/bin/bash
# swap_monitor.sh
# Moves the active window to the other screen of a dual-screen Xinerama 
setup.
#
# Requires: wmctrl, xprop, xwininfo
#
# Author: Raphael Wimmer
# raphman@gmx.de

# get monitorWidth
monitorLine=$(xwininfo -root | grep "Width")
monitorWidth=$((${monitorLine:8}/2 ))
echo $monitorWidth

# get active window id
activeWinLine=$(xprop -root | grep "_NET_ACTIVE_WINDOW(WINDOW)")
activeWinId="${activeWinLine:40}"

# get window position
xPosLine=$(xwininfo -id $activeWinId | grep "Absolute upper-left X")
xPos=${xPosLine:25} 

# get window width
xWidthLine=$(xwininfo -id $activeWinId | grep "Width")
xWidth=${xWidthLine:8}

# calculate new window position
if (( ${xPos} + ${xWidth}/2 > ${monitorWidth} ))
then xPos=$(( ${xPos} - ${monitorWidth}))
else xPos=$(( ${xPos} + ${monitorWidth}))
fi

# make sure window stays on screen completely
(( ${xPos} < 0 )) && xPos=0 
(( ${xPos} + ${xWidth} > 2 * ${monitorWidth} )) && 
xPos=$((2*${monitorWidth} - ${xWidth}))

echo ${xPos}

# if maximized store info and de-maximize
winState=$(xprop -id ${activeWinId} | grep "_NET_WM_STATE(ATOM)" ) 

if [[ `echo ${winState} | grep "_NET_WM_STATE_MAXIMIZED_HORZ"` != "" ]]
then 
maxH=1
wmctrl -i -r ${activeWinId} -b remove,maximized_horz 
fi

if [[ `echo ${winState} | grep "_NET_WM_STATE_MAXIMIZED_VERT"` != "" ]]
then
maxV=1
wmctrl -i -r ${activeWinId} -b remove,maximized_vert
fi

# move window (finally)
wmctrl -i -r ${activeWinId} -e 0,${xPos},-1,-1,-1

# restore maximization
((${maxV})) && wmctrl -i -r ${activeWinId} -b add,maximized_vert
((${maxH})) && wmctrl -i -r ${activeWinId} -b add,maximized_horz

# raise window (seems to be necessary sometimes)
wmctrl -i -a ${activeWinId}

# and bye
exit 0
