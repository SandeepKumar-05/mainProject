import RPi.GPIO as GPIO
import time

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

# Motor pins
IN1, IN2 = 17, 27
IN3, IN4 = 22, 23

GPIO.setup([IN1, IN2, IN3, IN4], GPIO.OUT)

# ================= FUNCTIONS =================

def climb_up():
    GPIO.output(IN1, 1)
    GPIO.output(IN2, 0)
    GPIO.output(IN3, 1)
    GPIO.output(IN4, 0)

def climb_down():
    GPIO.output(IN1, 0)
    GPIO.output(IN2, 1)
    GPIO.output(IN3, 0)
    GPIO.output(IN4, 1)

def stop():
    GPIO.output(IN1, 0)
    GPIO.output(IN2, 0)
    GPIO.output(IN3, 0)
    GPIO.output(IN4, 0)

# ================= MAIN =================

try:
    while True:
        cmd = input("Enter (w=up, s=down, x=stop, q=quit): ").lower()

        if cmd == 'w':
            print("Climbing UP")
            climb_up()

        elif cmd == 's':
            print("Climbing DOWN")
            climb_down()

        elif cmd == 'x':
            print("STOP")
            stop()

        elif cmd == 'q':
            break

        else:
            print("Invalid command")

except KeyboardInterrupt:
    pass

finally:
    GPIO.cleanup()