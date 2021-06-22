/* Angus Clayton
 * 22/6/2021
 * Arduino Windtunnel Code
 */

/* when recieving windspeed from arduino; need to read incoming byte 
 * and add it to data string as each 'digit' is one btye. Arduino
 * will update windspeed to 'data' on newline; and then clear data string.
 * Also outputs actual wind speed.
 */

int incomingByte = 0;
String data = "";

void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  // initialize PWM output for motor. (ATM just controlling an LED for testing.)
  pinMode(9,OUTPUT);
}

// =============== SET WIND SPEED =============================
// note: just maps 0-25m/s to PWM output on pin 9.

void setSpeed(int x) { //function to set wind speed; 
  //Serial.println(x);
  //set D9 pwm output //LEGACY NO MAP NEEDED NOW.
  //int y = map(x, 0, 25, 0, 255); //map(value, fromLow, fromHigh, toLow, toHigh)
  analogWrite(9,x);
  
}

// ======= MAIN LOOP ========

void loop() {
  // read the input on analog pin 0 [Force Reading]
  int sensorValue = analogRead(A0);
  float force = sensorValue * 0.0055 - 0.33; //Convert into newtons *NOTE FORMULA NOT AT ALL ACCURATE*
  float windSpeed = analogRead(A1)*0.01; //convert analog value between 0 and 10. so only takes up 3 characters when printing.
  // print out the force (RPI will just read serial value; as this is only output arduino gives.)
  Serial.print("S");
  Serial.print(force);
  Serial.print("B");
  Serial.print(windSpeed);
  Serial.print("E");
  
         
  //==== READ INCOMING WIND SPEED DATA  
  while (Serial.available() > 0) { 
    // read the incoming byte:
    incomingByte = Serial.read();

    //=debug
    //Serial.print("B");
    //Serial.println(incomingByte);

    
    if (incomingByte != 10) {//see if incoming byte is NOT new line
      data += String(incomingByte - 48);//convert byte into integer; and add to data
    }
    else {//if newline
      setSpeed(data.toInt()); //set speed to data [which has windspeed]
      data = ""; //clear data
    }
  }

  delay(1); //add stability i guess
}
