import controlP5.*;              // The ui library
import processing.opengl.*;


DataRecorder         recorder;        // records the accelerometer data
Sculptor             sculptor;        // loads and displays the accelerometer data
Accelerometer        accelerometer;   // reads in data from an acclerometer

// Values used to rotate in 3D space in READ_MODE
float rotX=0, rotY=0;
float rotX2=0, rotY2=0;
float r=0, phi=0, theta=0;


PVector curVel = new PVector(0, 0, 0);    // velocity of the point based on the current accelerometer values
PVector curPos;                           // current position of the point
boolean drawMode = false;                 // whether you should see a trail or not
ArrayList<PVector> drawPoints;            // points to actually draw

// For changing and keeping track of the current mode
String RECORD_MODE = "record";
String READ_MODE = "read";
String modes[] = {
  RECORD_MODE, READ_MODE
};
int curMode = 0;

ControlP5 controlP5;                    // The ui for the mode buttons


void setup()
{
  size(800, 800, OPENGL);
  background(0);
  smooth();

  curPos = new PVector(width/2, height/2, 0);

  accelerometer = new Accelerometer(this);
  recorder = new DataRecorder(this);
  sculptor = new Sculptor(this);

  // make ui
  controlP5 = new ControlP5(this);
  Radio r = controlP5.addRadio("radio", width - 56, 6);
  r.add("record", 0);
  r.add("read", 1);
}


// Event that comes from the ui to switch modes
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController()) {
    //println("got something from a controller "+theEvent.value());
    curMode = int(theEvent.value());
  }
}




void draw()
{
  background(0);

  // Do somehting different based on which mode is activated
  switch(curMode) {
  case 0:
    displayRecordMode();
    break;

  case 1:
    displayReadMode();
    break;
  }
}




void displayRecordMode() {

  // draw the current position using the values from the accelerometer as velociy
  curVel.x = accelerometer.accXval*4;
  curPos.x = constrain(curPos.x + curVel.x, 0, width);
  curVel.y = accelerometer.accYval*4;
  curPos.y = constrain(curPos.y + curVel.y, 0, height);


  stroke(255);
  fill(255);

  if (drawMode) {
    drawPoints.add(new PVector(curPos.x, curPos.y, curPos.z));
    if (drawPoints.size() > 1) {

      // connect the drawing points with a line
      for (int i=1; i<drawPoints.size(); i++) {
        PVector prevPt = drawPoints.get(i-1);
        PVector curPt = drawPoints.get(i);
        line(prevPt.x, prevPt.y, curPt.x, curPt.y);
      }
    }
  }

  noStroke();
  fill(255);
  ellipse(curPos.x, curPos.y, 5, 5);

  // draw the accelerometer update
  if (accelerometer != null) {
    accelerometer.update();
  }

  fill(200);
  text(int(frameRate), 20, 60);

  // send the accelerometer values to the recorder
  recorder.update(new PVector(accelerometer.accXval, accelerometer.accYval, accelerometer.accZval));
}




void displayReadMode() {

  // rotate around in 3D space
  pushMatrix();

  translate(width/2, height/2, 0);
  rotateY(TWO_PI*rotX2);
  rotateX(TWO_PI*rotY2);
  rotateY(TWO_PI*rotX);
  rotateX(TWO_PI*rotY);
  sculptor.update();
  popMatrix();
}



// recieve the xml load event and pass to the sculptor
void xmlEvent(proxml.XMLElement element) {
  sculptor.loadXmlEvent(element);
}


void keyPressed()
{
  switch(curMode) {
  case 0:
    
    // Calibrate the accelerometer
    if (key == 'c' || key == 'C') 
    {
      accelerometer.recalibrate();
    }
    
    // Start/Stop the recording of acceleromter data
    else  if (key == 'r' || key == 'R') 
    {
      if (!recorder.recording) {

        recorder.startRecording();
      }
      else {
        recorder.stopRecording();
      }
    }
    
    // Turn drawing mode on/off
    else if (key == 'd' || key == 'D') 
    {
      if (drawMode == true) {
        drawMode = false;
      } 
      else {
        drawPoints = new ArrayList<PVector>();
        drawMode = true;
      }
    }

    break;

  case 1:
    // Load xml data from a file
    if (key == 'l' || key == 'L') 
    {
      sculptor.loadDataFromFile();
    }
    
    // save out an image
    else if (key == 'p' || key =='P') 
    {
      saveFrame((System.currentTimeMillis()/1000)+".png");
    }
    break;
  }

  // quit the program
  if (key == 'q' || key == 'Q') 
  {
    exit();
  }
}


void mouseDragged() {
  if (mouseButton==LEFT) {
    rotX2=(float) 2*(mouseX-width/2)/(float) width;
    rotY2=(float) 2*(mouseY-height/2)/(float) height;
  }
}

