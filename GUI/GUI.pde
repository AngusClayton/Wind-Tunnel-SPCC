/* Angus Clayton
 * 15/6/2021
 * Raspberry Pi Windtunnel Code
 */
import processing.serial.*;
boolean debugMode = true; //disables all com-port interaction; and replaces arduino-interface functions with placeholders.
Serial myPort; 

//colors
color white = color(255,255,255);
color black = color(0,0,0);
color red = color(255,0,0);
color blue = color(0,128,255);
color green = color(0,200,100);
//constants
float xDilation = 1;
//drag constants
float surfaceArea = 0.1; //surface area of car m^2
float p = 1.225; //kg/m^3 density of air
//customisation of wind controll
float windAcceleration = 0.02; // m/s/10ms [sorry for horrific units]
float maxWindSpeed = 20; // m/s

//file writer 
PrintWriter output;


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
float getForceReading(float x,float t)  
{
  return (x*x)/100 + sin(t); //just some preset stuff rn whilst arduino not done.
}

// calculate drag coefficient
float dragCoefficient(float windSpeed, float force)
{
  float cd = (2*force)/(p*windSpeed*windSpeed*surfaceArea);
  if (cd > 0) {return cd;}
  else {return 9.99;}

}

//===== show readout:
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
  fill(black);
  rect(625,395,155,60);
  // windspeed
  fill(blue);
  textSize(16);
  String WindSpeedText = "Windspeed: " + str(round(windSpeed*10)/10) + "m/s";
  text(WindSpeedText,630,450);
  //drag force
  fill(red);
  String DragText = "Drag: " + str(round(force*10)/10) + "N";
  text(DragText,630,430);
  
  //calculate drag coefficient
  float cd = dragCoefficient(windSpeed,force);
  //display drag coefficient
  fill(green);
  String coefText = "Coef: 0." + str(round(cd*100));
  text(coefText,630,410);
  
}

//======== mouse clicked function; handels any buttons
void mouseClicked()
{
    if (overRect(10,15,60,40)) {
    print("Starting Wind Testing; Time vs (Windspeed,Force)\n");
    opMode = "TIME";
    //insert headers into file
    String headers[] = {"Force","Windspeed","Coefficient"};
    recordData("Time",headers); 
    }
    
    if (overRect(10,65,60,40))
    {
      print("Started Testing; Windspeed vs (Force, Drag Coefficient)\n");
      opMode = "SPEED";
      
      //insert headers into file
      String headers[] = {"WindSpeed","Force","Coefficient"};
      recordData("Time",headers);
      
    }
}

//==== setup
void setup() {
  size(800, 480); //Raspberry pi Touchscreen resolution
  //====== Main Graph Screen
  fill(white);
  rect(85,15,700,450);
  //====== Buttons
  //time versus wind speed and force.
  rect(10,15,60,40);
  fill(black);
  textSize(16);
  text("x:TIME",14,42);
  
  //wind speed vs force vs drag.
  fill(white);
  rect(10,65,60,40);
  fill(black);
  textSize(16);
  text("x:WIND",14,82);
  
  //create writer for file output:
  output = createWriter("windData.csv"); 
  
  
}
// varibles initialised for main draw.
float time = 0; 
float windSpeed = 0;

void draw() { 
  if (opMode == "TIME")
  {
    //increase wind speed at rate below till maxWindSpeed
    if (windSpeed < maxWindSpeed) {windSpeed += windAcceleration;}
    
    
    setWindSpeed(windSpeed); //tell arduino new windspeed
    
    //get xy coordinates to plot.
    float xGraph = 7*(time)+85;
    float yFGraph = 460-30*getForceReading(windSpeed,time); //drag force
    float yWGraph = 460-15*windSpeed; //windspeed
    float yCgraph = 430 - 300*dragCoefficient(windSpeed,getForceReading(windSpeed,time)); //coefficient
    
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
    readout(windSpeed,time,getForceReading(windSpeed,time));
    
    
    //wait and add onto time.
    time += 0.01;
    //stop if time going of axis:
    if (time > 100){opMode = "FINISH";}
    
    print(time);
    delay(10);
  }
  //=========== plot windspeed vs drag force and coefficient
  else if (opMode == "SPEED")
  {
    if (windSpeed < maxWindSpeed) {windSpeed += windAcceleration;}
    //calculate xy plot position
    float xGraph = 30*windSpeed+85;
    float yFGraph = 460-30*getForceReading(windSpeed,time);
    float yCgraph = 430 - 300*dragCoefficient(windSpeed,getForceReading(windSpeed,time));
    
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
    readout(windSpeed,time,getForceReading(windSpeed,time));
    //add time
    delay(10);
    time += 0.01;
  }

  else {
    windSpeed = 0;
    time = 0;
  }

  
}
