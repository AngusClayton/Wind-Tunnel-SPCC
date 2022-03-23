#=== this module reports windspeed.
import smbus
import time
from math import sqrt
bus = smbus.SMBus(1)
address = 0x28

tunnelCrossSectionArea = 0.283 #30 cm pipe.



def actualSpeed():
    try:
        raw = bus.read_byte_data(address, 3) #raw data from sensor 
    except:
        raw = -1
    
    pascal = (raw - 30) * 500 #example
    if pascal > 0:
        V = sqrt(pascal/1.225)
        return pascal
    else:
        return -1

while True:
	print(actualSpeed())
