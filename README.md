Headless multitrack audio recording for your Raspberry Pi

## What is it ?

This project is based on [caPiture](https://github.com/danielappelt/caPiture) by Daniel Appelt.

capPiture-ng uses [jack_capture](https://github.com/kmatheussen/jack_capture) to headlessly multitrack record the input of the [Behringer XR18 Mixer](http://www.musictribe.com/Categories/Behringer/Mixers/Digital/XR18/p/P0BI8) (via USB cable). For now, it is hardcoded to work with the XR18. If you want to use it with another audio interface, please modify the `startcapiture` script accordingly (the `dhw:X18XR18` parameter of `jackd`).

There are some differences from the original caPiture project:
- the recording format is [FLAC](https://xiph.org/flac/), not WAV, to limit SD card I/O rates
- the code is factorized to be easier to follow
- this project makes use of [systemd](https://systemd.io/) to start background services (rec service and power off service)
- the global process is simplified:
    - as soon as the system is started, it will try to start recording
    - only one button is used, to stop recording and shutdown the RPi

As caPiture we use one LED to have a visual feedback of what's going on.

## What it does exactly ?

- power on => led OFF
- jack is ready => LED ON (steady)
- then, each second:
    - if jack_capture is correctly running (ie it's recording), LED is blinking
- when button is pressed, recording stops and RPi power off

## Tests

This have been used is real live conditions for **12 tracks** recording (during summer, outside) with a Raspberry Pi 4, and it worked without any glitches for 3 hours (then I stopped the recording as the concert was finished). The CPU is really low when recording 12 tracks.

## Installation

### Software

This installation process haven't been fully tested; it's possible that minor things are missing. Don't hesitate to send PR or fill bugs report if something goes wrong for you.

- Download the latest version of [Raspbian Lite](https://raspberrypi.org/downloads/raspbian) and install it to an SD card (bigger is better). For Linux users, the command is:
    ```bash
    sudo dd bs=4M if=nameoftheimage of=/dev/yoursdcard status=progress conv=fsync
    ```
On the Raspberry Pi:
- launch `raspi-config` and set the Rpi to autologin in console mode
- install required software
    ```bash
    sudo apt install --no-install-recommends jackd2 jack-capture dbus-x11 python
    ```
- clone git repository
    ```bash
    cd ~
    git clone https://github.com/brunetton/capiture-ng.git
    ```
- add systemd services files to /etc/systemd/system/ and enable services
    ```bash
    ln -s $PWD/capiture-ng/rec.service /etc/systemd/system/
    ln -s $PWD/capiture-ng/startcapiture.service /etc/systemd/system/
    systemd enable rec
    systemd enable startcapiture
    ```
- configure Pi user to be allowed to launch Jack in high priority mode: edit `/etc/security/limits.conf` and add:

      pi          -       rtprio        99
      pi          -       nice          -10
      pi          -       memlock       unlimited

https://openstagecontrol.ammd.net/download/

### Hardware

Once you've installed it on your Raspbian SD card, you can add a LED and a push button:
- Connect GPIO 18 (PIN 12) to the + leg of an LED with a 330 Ohm resistor in between, other leg to gnd
- Attach button to GPIO 3 (PIN 5), other leg to gnd

## Usage

- to set the number of channels to record you'll have to edit `startcapiture.sh` script, in "start recording" section, in command line arguments to  `jack_capture`. Example, for 12-tracks recording:
    `jack_capture --disable-console -fn $FILE-2.flac -f flac -p system:capture_9 -p system:capture_10 -p system:capture_11 -p system:capture_12`
- as FLAC is limited to 8 channels, we start 2 `jack_capture` processes. This results in 2 output files:
    - `2023-09-02_01-20-32.1.flac` that contains channels 1-8
    - `2023-09-02_01-20-32.2.flac` that contains channels 9-16

## TODO

- add options to `startcapiture` script, mainly option to set the number of channels to record
- remove the use of screen. Maybe using `simple` service type instead of `oneshot` ?
