#!/bin/bash

cd /home/pi/pitchtimer
if [ "$1" = "recompile" ]; then
  git pull
  npm run compile
fi
node app.js 1>../pitchtimer.log 2>../pitchtimer.err &

PID="$!"

echo $PID > ../pitchtimer.pid
