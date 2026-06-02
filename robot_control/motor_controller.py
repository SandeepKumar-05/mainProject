"""
motor_controller.py
────────────────────────────────────────────────
Motor control using RPi.GPIO directly.
Matches the confirmed-working test.py and arm_test.py exactly.

GPIO Pin Layout (BCM):
  Drive Motor A  : IN1=17, IN2=27
  Drive Motor B  : IN3=22, IN4=23
  Harvest Motor  : HARVEST_IN1=5, HARVEST_IN2=6 (from arm_test.py)
  Servo          : SERVO=18 (PWM 50Hz)
────────────────────────────────────────────────
"""

import RPi.GPIO as GPIO
import time
import threading
import logging

log = logging.getLogger("MotorController")

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)

# ── Drive Motor Pins ──────────────────
IN1, IN2 = 17, 27   # Motor A
IN3, IN4 = 22, 23   # Motor B

# ── Harvesting Motor Pins (Exact match to arm_test.py) ────────────
# Note: In arm_test.py, these were called IN3/IN4 but mapped to 5/6.
# We'll call them HARVEST_IN1/IN2 to avoid conflict with Drive IN3/IN4.
HARVEST_IN1 = 5
HARVEST_IN2 = 6

# ── Servo Pin ────────────────────────────────────────
SERVO_PIN = 18

# Setup all pins
GPIO.setup([IN1, IN2, IN3, IN4, HARVEST_IN1, HARVEST_IN2, SERVO_PIN], GPIO.OUT)

# Servo PWM at 50Hz
_servo_pwm = GPIO.PWM(SERVO_PIN, 50)
_servo_pwm.start(0)

# ── Helpers ────────────────────────────────────────────
def _servo_angle(angle: float):
    """Move servo to given angle (0-180°)."""
    duty = 2 + (angle / 18)
    _servo_pwm.ChangeDutyCycle(duty)
    time.sleep(0.5)
    _servo_pwm.ChangeDutyCycle(0)

# ══════════════════════════════════════════════════════
#  Drive Motor Functions
# ══════════════════════════════════════════════════════

def forward():
    log.info("[MOTOR] FORWARD")
    GPIO.output(IN1, True);  GPIO.output(IN2, False)
    GPIO.output(IN3, True);  GPIO.output(IN4, False)

def backward():
    log.info("[MOTOR] BACKWARD")
    GPIO.output(IN1, False); GPIO.output(IN2, True)
    GPIO.output(IN3, False); GPIO.output(IN4, True)

def turn_left():
    log.info("[MOTOR] LEFT")
    GPIO.output(IN1, False); GPIO.output(IN2, True)
    GPIO.output(IN3, True);  GPIO.output(IN4, False)

def turn_right():
    log.info("[MOTOR] RIGHT")
    GPIO.output(IN1, True);  GPIO.output(IN2, False)
    GPIO.output(IN3, False); GPIO.output(IN4, True)

def stop():
    log.info("[MOTOR] STOP")
    GPIO.output(IN1, False); GPIO.output(IN2, False)
    GPIO.output(IN3, False); GPIO.output(IN4, False)

# ══════════════════════════════════════════════════════
#  Harvesting Motor Functions (from arm_test.py)
# ══════════════════════════════════════════════════════

def harvesting_on():
    """Rotate harvesting motor (GPIO 5 -> High, 6 -> Low)."""
    log.info("[HARVEST] MOTOR ON")
    GPIO.output(HARVEST_IN1, True)
    GPIO.output(HARVEST_IN2, False)

def harvesting_off():
    """Stop harvesting motor (GPIO 5 -> Low, 6 -> Low)."""
    log.info("[HARVEST] MOTOR OFF")
    GPIO.output(HARVEST_IN1, False)
    GPIO.output(HARVEST_IN2, False)

def harvesting_reverse():
    """Reverse harvesting motor (GPIO 5 -> Low, 6 -> High)."""
    log.info("[HARVEST] MOTOR REVERSE")
    GPIO.output(HARVEST_IN1, False)
    GPIO.output(HARVEST_IN2, True)

# ══════════════════════════════════════════════════════
#  Servo / Arm Functions
# ══════════════════════════════════════════════════════

def arm_deploy():
    log.info("[SERVO] DEPLOY")
    _servo_angle(180)

def arm_reset():
    log.info("[SERVO] RESET")
    _servo_angle(0)
    harvesting_off()

def arm_left():
    _servo_angle(0)

def arm_center():
    _servo_angle(90)

def arm_right():
    _servo_angle(180)

# ══════════════════════════════════════════════════════
#  Emergency Stop
# ══════════════════════════════════════════════════════

def emergency_stop():
    log.warning("[MOTOR] ⚠️ EMERGENCY STOP")
    stop()
    harvesting_off()
    _servo_pwm.ChangeDutyCycle(0)

# ══════════════════════════════════════════════════════
#  Cleanup
# ══════════════════════════════════════════════════════

def cleanup():
    stop()
    harvesting_off()
    _servo_pwm.stop()
    GPIO.cleanup()
    log.info("[MOTOR] GPIO cleaned up")
