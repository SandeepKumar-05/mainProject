from gpiozero import OutputDevice
from time import sleep

C1 = OutputDevice(5)
C2 = OutputDevice(6)

print("Cutting Motor ON")
C1.on()
C2.off()
sleep(5)

print("Reverse")
C1.off()
C2.on()
sleep(5)

print("Stop")
C1.off()
C2.off()

