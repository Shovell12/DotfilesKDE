#!/bin/bash

HEADSET_WAS_OFF=true

while true; do
    BATTERY=$(headsetcontrol -b 2>/dev/null | grep "Level:" | grep -o '\-\?[0-9]*%' | tr -d '%')
    
    if [ -n "$BATTERY" ] && [ "$BATTERY" -gt 0 ] 2>/dev/null; then
        if $HEADSET_WAS_OFF; then
            sleep 2
            headsetcontrol -l 0
            HEADSET_WAS_OFF=false
        fi
    else
        HEADSET_WAS_OFF=true
    fi
    sleep 5
done
