import RPi.GPIO as GPIO
import time

IN3 = 5   # GPIO5 → IN3
IN4 = 6   # GPIO6 → IN4

GPIO.setmode(GPIO.BCM)

GPIO.setup(IN3, GPIO.OUT)
GPIO.setup(IN4, GPIO.OUT)

try:
    print("Motor ON")

    # Rotate motor
    GPIO.output(IN3, True)
    GPIO.output(IN4, False)

    time.sleep(10)   # run for 10 seconds

    print("Motor OFF")

    # Stop motor
    GPIO.output(IN3, False)
    GPIO.output(IN4, False)

    time.sleep(5)

except KeyboardInterrupt:
    print("Stopped")

finally:
    GPIO.cleanup()