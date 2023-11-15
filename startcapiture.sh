#!/bin/bash

# Add a fake X session
echo "DISPLAY=:0" > "$HOME/bin/setsession"
dbus-launch >> "$HOME/bin/setsession"
chmod +x "$HOME/bin/setsession"
. "$HOME/bin/setsession"

export DISPLAY
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Set GPIO 18 as output
raspi-gpio set 18 op
raspi-gpio set 18 dh
sleep 2
raspi-gpio set 18 dl

# Start JACK server
sleep 5
echo "Starting Jack ..."
jackd -dalsa -dhw:X18XR18 -r44100 -p2048 -n3 &

# Light up LED on pin 18 when JACK is available
echo "Waiting for Jack ..."
jack_wait -w
echo "Jack is running :)"
raspi-gpio set 18 dh

# Start recording
echo "Start recording..."
FILE=$HOME/$(date +%F_%H-%M-%S).flac
screen -dm bash -c "jack_capture --disable-console -fn $FILE-1.flac -f flac -p system:capture_* --channels 8 "
screen -dm bash -c "jack_capture --disable-console -fn $FILE-2.flac -f flac -p system:capture_9 -p system:capture_10 -p system:capture_11 -p system:capture_12 -p system:capture_13 -p system:capture_14 -p system:capture_15 -p system:capture_16"

echo "Recording started, main loop"

while [ : ]
do
    # Check if jack_capture is running
    if (( $(pgrep -af jack_capture | wc -l) >= 1 )); then
        # Let's blink
        # echo "blink"
        if (( $(pgrep -af blink.sh | wc -l) == 0 )); then
            # blink not running, start it
            $HOME/capiture-ng/blink.sh &
        fi
    else
        # Stop blinking
        pkill -SIGTERM blink.sh
        # Led ON
        raspi-gpio set 18 dh
    fi
    sleep 1
done
