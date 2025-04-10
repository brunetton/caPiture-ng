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

while true; do
    # Start JACK server
    echo "Starting Jack ..."
    jackd --realtime -dalsa -dhw:X18XR18 -r44100 -p2048 -n3 &

    sleep 1

    echo "Waiting for jack (every seconds, max 6 seconds) ..."
    if jack_wait -w -t 6 2&> /dev/null; then
        # TODO: check that jack_wait is actually waiting when jack is starting correctly
        echo "Jack is running :)"
        break
    else
        pkill jackd > /dev/null # just in case, but shouldn't exists
    fi
done

# Light up LED on pin 18 when JACK is available
raspi-gpio set 18 dh

# Start recording
echo "Start recording..."
FILE=$HOME/$(date +%F_%H-%M-%S)
screen -dm bash -c "jack_capture --disable-console -fn $FILE.1.flac -f flac -p system:capture_* --channels 8 "
screen -dm bash -c "jack_capture --disable-console -fn $FILE.2.flac -f flac -p system:capture_9 -p system:capture_10 -p system:capture_11 -p system:capture_12 -p system:capture_13 -p system:capture_14 -p system:capture_15 -p system:capture_16"

echo "Recording started, main loop"

while true
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
