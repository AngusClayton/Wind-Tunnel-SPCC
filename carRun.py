#module that does a windtunnel run and records data.
from time import time as epoch
from time import sleep
from motor import setDuty as setFanSpeed
#from windSpeed import actualSpeed
from readForce import getForce
data = [["Time"],["Requested Speed"],["Actual Speed"],["Force"],["Drag(N)"]]
area = 0
#--- map values for speed:


def cTime():
    return round(epoch() - startTime,2)



def log(reqSpeed):
    #print("TIME:",cTime(),"rSpeed:",reqSpeed,"FORCE:",getForce())
    windSpeed = reqSpeed*100/35#actualSpeed()
    tempForce = getForce()
    data[0].append(cTime())
    data[1].append(reqSpeed)
    data[2].append(windSpeed) #actual speed
    data[3].append(tempForce)

    
    



startTime = epoch()
def run(rampTime,speedMax,holdTime):
    global data
    data = [["Time"],["Requested Speed"],["Actual Speed"],["Force"],["Drag(N)"]]
    print("*/ Running tunnel...")

    speed = 0
    for t in range(0,rampTime*10,1):
        speed += speedMax/rampTime/10
        setFanSpeed(speed)
        log(speed)
        
        sleep(0.1)
    print("*/ Holding speed @",speedMax,"%")
    for t in range(0,holdTime*10,1):
        log(speed)
        sleep(0.1)
    print("*/ Run Complete")
    setFanSpeed(0)
    return data

if False: #standalone test code.
    print(run(5,100,5))
    

