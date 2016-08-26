#!/bin/bash

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
