/* Angus Clayton
 * 15/6/2021
 * Raspberry Pi Windtunnel Code
 */
 
//In this version, windSpeed it the windspeed we are requesting 
//have not added actual wind speed yet.
import processing.serial.*;
boolean debugMode = false; //disables all com-port interaction; and replaces arduino-interface functions with placeholders.
Serial myPort; 

//colors
color white = color(255,255,255);
color black = color(0,0,0);
color red = color(255,0,0);
color blue = color(0,128,255);
color green = color(0,200,100);
color gray = color(128,128,128);
//constants
float yForceDilation = 100;
float yWindDilation = 20;
float yDragCoefficientDilation = 100;
float xWindDilation = 10;


//drag constants
float surfaceArea = 0.01; //surface area of car m^2
float p = 1.225; //kg/m^3 density of air
//customisation of wind controll
float windAcceleration = 0.02; // m/s/10ms [sorry for horrific units]
float maxWindSpeed = 18; // m/s

//file writer 
PrintWriter output;
//surface area input:
String surfText ="0.01";

//operation mode [used for different functions to plot different things (see void draw())]
String opMode = "NONE";


//over rectangle function used to dettect if mouse over buttons
boolean overRect(int x, int y, int width, int height)  {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

//======== get/set data from tunnel arduino
void setWindSpeed(float speed) //placeholder function ATM
{
  //=== placeholder:
  /*
  print("Setting Wind Speed to ");
  print(speed);
  print("\n");
  */
  //real:
  if (!debugMode)
  {
    String speedString = str((speed/maxWindSpeed)*255);
    //write number
    for (int i = 0; i<speedString.length(); i++)
    {
      Byte outputByte = byte(speedString.charAt(i));
      myPort.write(outputByte); 
    }
    //write newline byte
    myPort.write(10);
  }
  else{
  print("PWM:"); 
  print(str((speed/maxWindSpeed)*255)); 
  print("\n");
  windActual = speed;
}
}

//===== Function that records data to file.
// the list string is used so different modes have differing amount of y plots.
void recordData(String x,String list[]) 
{
  String line = x;
  for (int i=0;i<list.length;i++)
  {
    line += ","+list[i];
    
  }
  output.println(line);
  print("\n");
}

/// ======== get force reading from arduino
float forceGlobal = 0;
float windActual = 0;
float getForceReading(float x,float t)  
{
  if (debugMode) {
  forceGlobal=  2*sin(t)+2; //just some preset stuff rn whilst arduino not done.
  }
  else {
    String bytearray[] = {};
    int loops = 0; //stop if more than 10 letters; stops hanging / errors
    if (myPort.available() > 0) 
    {
      char latestChar = char(myPort.read());
      //wait until start character send "S"
      while (latestChar != 83) {latestChar = char(myPort.read());}
      //wait until other character:
      while (latestChar == 83) {latestChar = char(myPort.read());}
      //loop until end character ("E") or until 10 letters.
      while (latestChar != 69 && loops < 10)
      {
        bytearray = append(bytearray,str(latestChar));
        //print(str(latestChar));
        latestChar = char(myPort.read());
        loops++;
      }
    
    }
    //join array and print force
    String byteArrayJoin = join(bytearray,"");
    
    if (1<byteArrayJoin.length() && byteArrayJoin.length() <10) //stop wrong reading from getting through.
    {
      
      String NewArray[] = split(byteArrayJoin,"B");
      /*
       Raw input looks like `S4.05B34.8E` with the number between s and B being the force
       And the number between B and E being the wind speed (ACTUAL)
      */
      forceGlobal = float(NewArray[0]);
      /* Set actual wind speed
      Arduino reports value between 0 and 10, representing its analog input 0-1024. 
      Assuming 100% is 30ms/ we times the input value by 3. */
      windActual = float(NewArray[1])*3; 
      print("array:");
      print(join(NewArray,", "));
      print("\n");
      /*
      print(
      print("FORCE:");
      print(byteArrayJoin);
      print("\n");
      */
    }
    

    
  }
  return forceGlobal;
}
void keyPressed() { //used to enter car area.
//this funciton changes the surface area value
  if (true)//can add mouse over condition if needed; didn't add due to touchscreen.
  {
    if (key == 8){surfText = "";}//backspace
    if (key >47 && key<59){surfText+=str(key - 48);}
    if (key==46){surfText += ".";}
    /* //debug
    print(surfText);
    print(";");
    print(surfaceArea);print("*\n");
    */
    surfaceArea = float(surfText);
  }
}
// calculate drag coefficient
float dragCoefficient(float windSpeed, float force)
{
  float cd = (2*force)/(p*windSpeed*windSpeed*surfaceArea);
  if (cd > 0) {return cd;}
  else {return 9.99;}

}

//===== show readout:
int readoutYShift = 0; //shifts readout screen by y.
int readoutXShift = 0;
void readout(float windSpeed, float time, float force) 
{
  /*
  print(windSpeed);
  print(",");
  print(time);
  print(",");
  print(force);
  print("\n");
  */
  
  // clear screen area
  stroke(black);
  fill(white);
  rect(500+readoutXShift,420+readoutYShift,290,50);
  // windspeed
  fill(blue);
  textSize(16);
  String WindSpeedText = "Windspeed: " + nf(windSpeed,2,2) + "m/s";
  text(WindSpeedText,520+readoutXShift,440+readoutYShift);
  //drag force
  fill(red);
  String DragText = "Drag: " + nf(force,1,2) + "N";
  text(DragText,520+readoutXShift,460+readoutYShift);
  
  //calculate drag coefficient
  float cd = dragCoefficient(windSpeed,force);
  //display drag coefficient
  fill(green);
  String coefText = "Coef: " + nf(cd,1,2);
  text(coefText,650+readoutXShift,460+readoutYShift);
  
}

//======== mouse clicked function; handels any buttons
void mouseClicked()
{
  //=== wind testing mode...
    if (overRect(10,420,80,50)) {
    print("Starting Wind Testing; Time vs (Windspeed,Force)\n");
    opMode = "TIME";
    //insert headers into file
    String headers[] = {"Force","Windspeed","Coefficient"};
    recordData("Time",headers); 
    }
    
    if (overRect(100,420,80,50))
    {
      print("Started Testing; Windspeed vs (Force, Drag Coefficient)\n");
      opMode = "SPEED";
      
      //insert headers into file
      String headers[] = {"WindSpeed","Force","Coefficient"};
      recordData("Time",headers);
      
    }
   //=== clear graph
    //350,420,80,50
    if (overRect(350,420,80,50))
    {
      opMode = "NONE";
      readout(0,0,0); //set everything to zero
      //====== Main Graph Screen
      fill(white);
      rect(10,15,780,400);
      time = 0;
      windSpeed=0;
      //=== set windspeed
      setWindSpeed(0);
      //redraw ticks
      drawYAxisTick();
      
      
    }
}
//============ y axis ticks
void drawYAxisTick()
{

  for (int i=1;i<4;i++) {
    stroke(gray);
    
    line(10,i*100+15,790,i*100+15);
    //force text)
    fill(red);
    text(str(4-i),775,i*100+10);
    //drag text
    fill(green);
    text(str(4-i),755,i*100+10);
    //wind text:
    //4 = 30, 0 = 0
    fill(blue);
    text(str((4-i)*5),725,i*100+10);
    

}
}



//==== setup
void setup() {
  print("STARTING\n");
  size(800, 480); //Raspberry pi Touchscreen resolution
  //====== arduino setup
  if (!debugMode)
  {
  String portName = Serial.list()[1]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  print(portName);
  }
  //====== Main Graph Screen
  fill(white);
  rect(10,15,780,400);
  //====== Buttons
  //time versus wind speed and force.
  rect(10,420,80,50);
  fill(black);
  textSize(16);
  text("x:TIME",20,455);
  
  //wind speed vs force vs drag.
  fill(white);
  rect(100,420,80,50);
  fill(black);
  textSize(16);
  text("x:WIND",110,455);
  
  //Clear Graph button
  fill(white);
  rect(350,420,80,50);
  fill(black);
  textSize(16);
  text("CLEAR",360,455);
  

  
  //create writer for file output:
  output = createWriter("windData.csv"); 
  
  //do y axis ticks
  drawYAxisTick();
  
  
}
// varibles initialised for main draw.
float time = 0; 
float windSpeed = 0;

int yAxisPosition = 415; 
int xAxisPosition = 10;

float lastWindSpeed = -1;
void draw() { 
  //surface area text box: #!! NEEDS TO BE EDITABLE !!!
  fill(white);
  rect(190,420,150,50);
  textSize(16);
  fill(red);
  text("A:",200,455);
  fill(black);
  text(surfText,220,455);
  
  //x-axis ticks
  //wind mode:
  if (opMode == "SPEED")
  {
    for (int i=1;i<10;i++)
    {
      stroke(gray);
      line(78*i,415,78*i,15);
      fill(blue);
      textSize(12);
      text(str(i*18/7),78*i,415);
    }
  }
  //no ticks in time mode (do we need that?);
  
  
  //#============== plot function
  if (opMode == "TIME")
  {
    //increase wind speed at rate below till maxWindSpeed
    if (windSpeed < maxWindSpeed) {windSpeed += windAcceleration;}
    
    
    setWindSpeed(windSpeed); //tell arduino new windspeed [i.e. pwm]
    
    //get xy coordinates to plot.
    float xGraph = 7*(time)+xAxisPosition;
    float yFGraph = yAxisPosition-yForceDilation*getForceReading(windActual,time); //drag force
    float yWGraph = yAxisPosition-yWindDilation*windActual; //windspeed
    float yCgraph = yAxisPosition - yDragCoefficientDilation*dragCoefficient(windActual,getForceReading(windSpeed,time)); //coefficient
    
    //send data to file:
    String recordData[] = {str(yFGraph),str(yWGraph),str(yCgraph)};
    recordData(str(xGraph),recordData);

    //plot the force
    fill(red);
    stroke(red);
    rect(xGraph,yFGraph,1,1);
    //plot wind speed
    fill(blue);
    stroke(blue);
    rect(xGraph,yWGraph,1,1);
    //plot force
    fill(green);
    stroke(green);
    rect(xGraph,yCgraph,1,1);
    //write the data in bottom corner
    readout(windActual,time,getForceReading(windActual,time));
    
    
    //wait and add onto time.
    time += 0.01;
    //stop if time going of axis:
    if (time > 100){opMode = "FINISH";}
    
    //print(time);
    delay(10);
  }
  //=========== plot windspeed vs drag force and coefficient
  else if (opMode == "SPEED")
  {
    if (windSpeed < maxWindSpeed) {windSpeed += windAcceleration;}
    else{opMode = "NONE";}
    // only plot windspeed once:
    //if (true)
    if (windActual > lastWindSpeed && (windActual < (lastWindSpeed +1)))
    {
      lastWindSpeed = windActual;
    //set wind speed
    setWindSpeed(windSpeed);
    //calculate xy plot position
    float xGraph = 30*windActual+xAxisPosition;
    float yFGraph = yAxisPosition-yForceDilation*getForceReading(windActual,time);
    float yCgraph = yAxisPosition - yDragCoefficientDilation*dragCoefficient(windActual,getForceReading(windSpeed,time));
    
    //send data to file:
    String recordData[] = {str(yFGraph),str(yCgraph)};
    recordData(str(xGraph),recordData);
    
    
     //plot the force
    fill(red);
    stroke(red);
    rect(xGraph,yFGraph,1,1);
    //plot coefficint
   
    fill(green);
    stroke(green);
    rect(xGraph,yCgraph,1,1);
    
    
    //write the data in bottom corner
    
    //add time
    delay(10);
    time += 0.01;
    }
    readout(windActual,time,getForceReading(windActual,time));
  }

  else {
    windSpeed = 0;
    time = 0;
    lastWindSpeed = -1;
  }

  
}
