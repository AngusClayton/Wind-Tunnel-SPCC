#reading force data:
import Adafruit_GPIO.SPI as SPI
import Adafruit_MCP3008

# Hardware SPI configuration:
SPI_PORT   = 0
SPI_DEVICE = 0
mcp = Adafruit_MCP3008.MCP3008(spi=SPI.SpiDev(SPI_PORT, SPI_DEVICE))

#50g in bottle is 195
#125 is 0g in bottle
#therefore 70 = 50g


print("*/ force module initialized.")

def getForce():
    raw = mcp.read_adc(0)
    raw -= 84
    raw *= 0.714 #50/70 see calibration comments above.
    if raw > 0:
        return raw*0.0098 #grams to newtons.
    else:
        return 0

while False:
    print(int(getForce()))