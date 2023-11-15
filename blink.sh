#!/bin/bash

while [ : ]
do
    #sudo echo "0" > /sys/class/gpio/gpio18/value
    raspi-gpio set 18 dl
    sleep 0.5
    #sudo echo "1" > /sys/class/gpio/gpio18/value
    raspi-gpio set 18 dh
    sleep 0.5
done
