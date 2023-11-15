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
- mount the SD card, we'll add some scripts to the `rootfs` partition (not the `bootfs` one)
- go to /home/pi/ of SD card (replace `[mount_point]` by partition mount point, typically something like `/media/bruno/rootfs/`)
    ```bash
    cd [mount_point]/home/pi
    ```
- clone git repository
    ```bash
    git clone https://github.com/brunetton/capiture-ng.git
    ```
- add systemd services files to /etc/systemd/system/ and enable services
    ```bash
    ln -s $PWD/capiture-ng/rec.service /etc/systemd/system/
    ln -s $PWD/capiture-ng/startcapiture.service /etc/systemd/system/
    systemd enable rec
    systemd enable startcapiture
    ```

### Hardware

Once you've installed it on your Raspbian SD card, you'll have to add a LED and a push button:
- Connect GPIO 18 (PIN 12) to the + leg of an LED with a 330 Ohm resistor in between, other leg to gnd
- Attach button to GPIO 3 (PIN 5), other leg to gnd

## TODO

- add options to `startcapiture` script, mainly option to set the number of channels to record
- remove the use of screen. Maybe using `simple` service type instead of `oneshot` ?
