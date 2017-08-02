#!/bin/sh

if [ -z $AVRDUDE_BIN ]; then
    AVRDUDE_BIN=`which avrdude`
fi

if [ ${__DEBUG+1} ]; then
    AVRDUDE_BIN="echo $AVRDUDE_BIN"
fi

if [ $AVRDUDE_CFG ]; then
    AVRDUDE_CFG="-C $AVRDUDE_CFG"
    
elif [ ${ARDUINO_MODE+1} ]; then
    
    AVRDUDE_CFG="-C /etc/avrdude.arduino.conf"
fi

if [ $AVRDUDE_PORT ]; then
    AVRDUDE_PORT="-P $AVRDUDE_PORT"
fi

if [ $AVRDUDE_DEVICE ]; then
    AVRDUDE_DEVICE="-p $AVRDUDE_DEVICE"
fi

if [ $AVRDUDE_PROGRAMMER ]; then
    AVRDUDE_PROGRAMMER="-c $AVRDUDE_PROGRAMMER"
fi

if [ $AVRDUDE_OPTS ]; then
    AVRDUDE_OPTS=${AVRDUDE_OPTS-}
elif [ ${AVRDUDE_VERBOSE+1} ]; then
    AVRDUDE_OPTS="-v"
fi



$AVRDUDE_BIN $AVRDUDE_OPTS $AVRDUDE_CFG $AVRDUDE_PORT $AVRDUDE_PROGRAMMER $AVRDUDE_DEVICE "$@"

exit 0

