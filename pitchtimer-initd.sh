#!/bin/bash
#   make available by 
#ln -s /home/pi/pitchtimer/pitchtimer-initd.sh /etc/init.d/pitchtimer
case "$1" in
  "start")
    echo "Starting pitchtimer"
    cd /home/pi/pitchtimer && ./startpitchtimer.sh
  ;;
  "stop")
    echo "Stopping pitchtimer"
    cd /home/pi/pitchtimer && ./stoppitchtimer.sh
  ;;
  "restart")
    echo "Restarting and rebuilding pitchtimer"
    cd /home/pi/pitchtimer && ./stoppitchtimer.sh && ./startpitchtimer.sh recompile
  ;;
  *) ;;
esac
