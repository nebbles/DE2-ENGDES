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
start_time = 0
end_time = 0

def fall_callback(channel):
    global fall, end_time
    end_time = time.time()  # set the end time to current
    fall = True
def rise_callback(channel):
    global rise, start_time
    start_time = time.time()  # set the end time to current
    rise = True

try:
    print(GPIO.input(ECHO1))
    print(GPIO.input(ECHO2))
    raw_input('Set-up complete. Press any button to continue.')

    GPIO.add_event_detect(ECHO1, GPIO.RISING, callback=rise_callback)
    GPIO.add_event_detect(ECHO2, GPIO.FALLING, callback=fall_callback)

    while True:
        print('Sending trigger')
        GPIO.output(TRIG1, GPIO.HIGH)  # Trigger goes high
        GPIO.output(TRIG2, GPIO.HIGH)  # Trigger goes high
        # time.sleep(20 / 1000000.0)  # delay by 20 micro-sec
        GPIO.output(TRIG1, GPIO.LOW)  # trigger goes low
        GPIO.output(TRIG2, GPIO.LOW)  # trigger goes low

        while (fall is False) and (rise is False):
            pass
        print('ECHO received')
        dt = end_time - start_time  # calculate time difference
        dt = dt * 10.0**6  # convert into microseconds
        print(dt)  # print time difference

        # delay and then wait for user prompt to repeat
        raw_input('Press any key to repeat')
        print('')
        rise = False
        fall = False
        start_time = time.time()
        end_time = time.time()
except KeyboardInterrupt:
    GPIO.cleanup()
finally:
    GPIO.cleanup()
