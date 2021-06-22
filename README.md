# Wind Tunnel

#### Password:

password is `W1nd`

Wind tunnel software for SPCC

Uses a raspberry pi running processing communicating with an Arduino [over USB serial].

The raspberry pi handles GUI and control; calculating the coefficient of friction and plotting data [to screen and recording to file]

The Arduino sets the windspeed based on received value from raspberry pi (m/s); the Arduino sends back force sensor data (Newtons).

Arduino used for testing is a Nano.

The user can set the surface area with keyboard; (just type, backspace reset to zero.)

![uiv2](docsImg/uiv2.png)



# To do [16/6/2021]

- delete file/create a new file for each run.

  - Perhaps on clear button creates new file.

  

# Calibration of force sensor

The force sensor reads an analogue value on `A0`0->1023

It is connected to 5V, GND and A0

## Rough calibration

**Note; this extremely rough; just for testing IDE guessed the weight of my phone was 200g.**

**NEED TO TO PROPER CALIBRATION; i.e. look up sensor details**

No Load: Reads 60

'2N' of load: Read **370**

***assuming linear sensor readout***

`FORCE = READOUT*0.0055 - 0.33`



## Number input
Users will need to input the surface area of the car in order to get drag coefficient:
On screen keyboard?
https://pimylifeup.com/raspberry-pi-on-screen-keyboard/
