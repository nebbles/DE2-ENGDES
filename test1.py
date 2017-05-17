'''
Test program 1 for first ultrasound rig.
17 May 2017
Benedict Greenberg & Shivam Bhatnagar

AIMS
- Find timing resolution of RPI and sensors
- Find reliability of the received signal from range sensors

'''

import time
import datetime
import RPi.GPIO as GPIO

print('Test 1 for ultrasonic range finder HC-SR04')

# BCM values

TRIG1 = 4
ECHO1 = 17
TRIG2 = 23
ECHO2 = 24

# Set GPIO pins

GPIO.setmode(GPIO.BCM)  # Broadcom pin-numbering scheme
GPIO.setup(TRIG1, GPIO.OUT)  # set as I/O output
GPIO.setup(TRIG2, GPIO.OUT)  # set as I/O output
GPIO.setup(ECHO1, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(ECHO2, GPIO.IN, pull_up_down=GPIO.PUD_UP)

fall = False
rise = False

def fall_callback(channel):
    global fall
    print('Falling edge detected')
    fall = True
def rise_callback(channel):
    global rise
    print('Rising edge detected')
    rise = True

try:
    raw_input('Set-up complete. Press any button to continue.')
    GPIO.add_event_detect(ECHO1, GPIO.RISING, callback=rise_callback)
    GPIO.add_event_detect(ECHO2, GPIO.FALLING, callback=fall_callback)
    while True:
        print('Sending trigger')
        GPIO.output(TRIG1, GPIO.HIGH)  # Trigger goes high
        GPIO.output(TRIG2, GPIO.HIGH)  # Trigger goes high
        #time.sleep(20 / 1000000.0)  # delay by 20 micro-sec
        GPIO.output(TRIG1, GPIO.LOW)  # trigger goes low
        GPIO.output(TRIG2, GPIO.LOW)  # trigger goes low

        #GPIO.wait_for_edge(ECHO2, GPIO.RISING)  # while echo value low
        #start_time = datetime.datetime.now()  # set the start time to current

        #GPIO.wait_for_edge(ECHO2, GPIO.FALLING)  # while echo value high
        #end_time = datetime.datetime.now()  # set the end time to current
	while not fall and not rise:
            pass
        print('ECHO received')

        #dt = end_time - start_time  # calculate time difference
        #print(dt)  # print time difference

        # delay and then wait for user prompt to repeat
        raw_input('Press any key to repeat')
except KeyboardInterrupt:
    GPIO.cleanup()
finally:
    GPIO.cleanup()
