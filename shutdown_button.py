#!/usr/bin/env python
import RPi.GPIO as GPIO
import subprocess

GPIO.setmode(GPIO.BCM)    # Set GPIO numbering
GPIO.setup(3, GPIO.IN)    # GPIO 3 (PIN 5) = second row, third col
GPIO.wait_for_edge(3, GPIO.FALLING)  # appel bloquant

subprocess.call(['pkill', '-SIGTERM', 'jack_capture'], shell=False)
subprocess.call(['shutdown', '-h', 'now'], shell=False)
