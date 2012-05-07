import processing.serial.*;

class Accelerometer
{

  PApplet mRoot;                                   // The parent applet
  Serial myPort;                                   // the arduino port
  int linefeed = 10;                               // for reading from the arduino board
  int sensors[];                                   // The arduino sensors
  boolean showing = true;                          // whether or nor the acclerometer graph is showing

  boolean calibrate = false;                       // If it's currently calibrating
  int calCount = 0;
  int calMax = 100;

  float resultAccX, resultAccY, resultAccZ;        // accelerometer calibration average value (used to convert the values to final values)
  float accXval, accYval, accZval;

  float targX;
  float targY;
  float targZ;
  float curX;
  float curY;
  float curZ;

  float r = 0;
  float accelDisW = 50;



  Accelerometer(PApplet root) {
    mRoot = root;

    // Find the arduino port
    myPort = new Serial(mRoot, Serial.list()[1], 14400);

    // Find the calibration values that were saved previously.
    // If they don't exist, start off with a calibration.
    // If it does exist, use those values.

    String lines[] = loadStrings("calibration.txt");
    if (lines == null) {
      calibrate = true;
    }
    else {
      resultAccX = new Float(lines[0]);
      resultAccY = new Float(lines[1]);
      resultAccZ = new Float(lines[2]);
    }
  }




  void update() {
    if (showing) {
      pushMatrix();
      // Display the x, y, z graph in the corner
      translate(accelDisW+20, accelDisW+20, 0);
      rotateY(r);
      stroke(255, 0, 0);
      line(-accelDisW, 0, 0, accelDisW, 0, 0);
      line(-accelDisW, 0, 0, -accelDisW+5, 5, 0);
      line(-accelDisW, 0, 0, -accelDisW+5, -5, 0);
      line(accelDisW, 0, 0, accelDisW-5, 5, 0);
      line(accelDisW, 0, 0, accelDisW-5, -5, 0);

      stroke(0, 255, 0);
      line(0, -accelDisW, 0, 0, accelDisW, 0);
      line(0, -accelDisW, 0, 5, -accelDisW+5, 0);
      line(0, -accelDisW, 0, -5, -accelDisW+5, 0);
      line(0, accelDisW, 0, 5, accelDisW-5, 0);
      line(0, accelDisW, 0, -5, accelDisW-5, 0);

      stroke(0, 0, 255);
      line(0, 0, -accelDisW, 0, 0, accelDisW);
      line(0, 0, -accelDisW, -5, 0, -accelDisW+5);
      line(0, 0, -accelDisW, 5, 0, -accelDisW+5);
      line(0, 0, accelDisW, -5, 0, accelDisW-5);
      line(0, 0, accelDisW, 5, 0, accelDisW-5);

      // determine the sphere value along the axis
      curX += (targX - curX) * .1;
      curY += (targY - curY) * .1;
      curZ += (targZ - curZ) * .1;

      sphereDetail(10);
      noStroke();

      pushMatrix();
      translate(curX, 0, 0);
      fill(255, 0, 0);
      sphere(5);
      popMatrix();

      pushMatrix();
      translate(0, curY, 0);
      fill(0, 255, 0);
      sphere(5);
      popMatrix();

      pushMatrix();
      translate(0, 0, curZ);
      fill(0, 0, 255);
      sphere(5);
      popMatrix();


      // add text
      fill(255);
      textMode(MODEL);
      textAlign(LEFT);
      textSize(10);

      text("x: "+accXval, -accelDisW, -accelDisW);
      text("y: "+accYval, -accelDisW, -accelDisW + 12);
      text("z: "+accZval, -accelDisW, -accelDisW + 24);

      popMatrix();
    }



    // Get the accelerometer data now
    serialEvent();

    if (calibrate) {
      textMode(SCREEN);
      textAlign(CENTER);
      int countdown = round((1.0 - (float(calCount)/float(calMax))) * 10);
      text("CALIBRATING: " + countdown, width/2, 20);
    }
  }




  void serialEvent() 
  {
    //println("--------------------------BEGIN SERIAL EVENT--------------------------");

    String myString = myPort.readStringUntil(linefeed);      // read the serial buffer

    if (myString != null) {

      myString = trim(myString);                            // removes white space from the string
      myString = split(myString, "-")[0];                   // removes the "-" character/delimeter
      sensors = int(split(myString, ','));                  // and convert the sections into integers via the "," delimeters

      PVector p;                                            // All 3 x, y, and x values


      // If in calibration mode, record each value and then average them
      // The averaged value will be used to get an accurate value or the accelerometer's rotation

      if (calibrate) {
        if (calCount == 0) {
          resultAccX = 0;
          resultAccY = 0;
          resultAccZ = 0;
        }
        resultAccX += sensors[0];
        resultAccY += sensors[1];
        resultAccZ += sensors[2];
        calCount++;

        if (calCount >= calMax) {
          // find the average values
          resultAccX /= calMax;
          resultAccY /= calMax;
          resultAccZ /= calMax;

          // Save these values to the calibration text file
          String calibrationVals[] = {
            Float.toString(resultAccX), Float.toString(resultAccY), Float.toString(resultAccZ)
            };
            saveStrings("calibration.txt", calibrationVals);
          calibrate = false;
        }
      }
      // If not in calibration mode
      else {
        // Values are determined based on the accelerometer's sensitivity and voltage
        // Based on this post: http://arduino.cc/forum/index.php?topic=58048

        accXval = (sensors[0]-resultAccX)/102.3;//(accXadc-accZeroX)/Sensitivity - in quids              Sensitivity = 0.33/3.3*1023=102.3
        accYval = (sensors[1]-resultAccY)/102.3;//(accXadc-accZeroX)/Sensitivity - in quids              Sensitivity = 0.33/3.3*1023=102.3
        accZval = (sensors[2]-resultAccZ)/102.3;//(accXadc-accZeroX)/Sensitivity - in quids              Sensitivity = 0.33/3.3*1023=102.3
        accZval -= accZval/2;

        p = new PVector(accXval, accYval, accZval);

        // will have the option to hide the accelerometer display
        if (showing) {
          updateTargetValues(p);
        }
      }
    }
    //println("--------------------------END SERIAL EVENT--------------------------");
  }


  // Update the target values of the accelerometer
  void updateTargetValues(PVector p) {
    targX = accelDisW * p.x;
    targY = accelDisW * p.y;
    //targZ = -accelDisW + ((accelDisW * p.z) * 2);
    targZ = accelDisW * p.z;
  }


  // Recalibrate the acclerometer
  void recalibrate() {
    calCount = 0;
    calibrate = true;
  }
}

