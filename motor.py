import pigpio
from time import sleep as delay
pi = pigpio.pi()       # pi1 accesses the local Pi's GPIO
motorPin = 4
motorMax = 2350 #us pulse to turn 100% on.
motorMin = 1175 #us pulse to start to spin.
motorStop = 1100 #us pulse to turn off.
# pigs s 27 1000 mils 2000 s 27 2000 mils 2000 s 27 1000 mils 2000

# ==== ARM SERVO
print("*/ ARMING SERVO...")
pi.set_servo_pulsewidth(motorPin, 1000)
delay(2)
pi.set_servo_pulsewidth(motorPin, 2000)
delay(2)
pi.set_servo_pulsewidth(motorPin, 2000)
pi.set_servo_pulsewidth(motorPin, 1000)
delay(2)
print("*/ SERVO ARMED...")
# === SER

def setDuty(duty):
    if 0 < duty <= 100:
        #map the duty to a pulse value:
        pulse = duty/100 * (motorMax-motorMin) + motorMin
        pi.set_servo_pulsewidth(motorPin, pulse)
        return 1
    elif duty == 0:
        pi.set_servo_pulsewidth(motorPin, motorStop)
    else:
        return 0