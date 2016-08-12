#!/bin/bash
#/home/pi/load_timer.sh

firefox http://ram-sc.roaming.utwente.nl:3003 >/dev/null 2>&1 &
unclutter -display :0 -noevents -grab >/dev/null 2>&1 &
sleep 15 && xte "key F11" -x:0