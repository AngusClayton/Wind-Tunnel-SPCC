int incomingByte = 0;
String data = "";
// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  pinMode(9,OUTPUT);
}

void setSpeed(int x) {
  Serial.println(x);
  //set D9 pwm output
  int y = map(x, 0, 23, 0, 255); //map(value, fromLow, fromHigh, toLow, toHigh)
  analogWrite(9,y);
  
}

// the loop routine runs over and over again forever:
void loop() {
  // read the input on analog pin 0:
  int sensorValue = analogRead(A0);
  float force = sensorValue * 0.0055 - 0.33;
  // print out the value you read:
  Serial.println(force);
  
  delay(1);       

  if (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();
    //Serial.print("B");
    //Serial.println(incomingByte);
    if (incomingByte != 10) {
      data += String(incomingByte - 48);
    }
    else {
      setSpeed(data.toInt());
      data = "";
    }
  }
}
