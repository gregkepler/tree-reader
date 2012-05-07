import proxml.*;                    // The library that enables xml loading and saving


class DataRecorder 
{


  int countDownMax = 20;              // The amount of seconds to record
  int count;                          // The current countdown value
  boolean recording = false;          // Whether the countdown is happening or not
  ArrayList points;                   // List of points to save/draw
  XMLInOut xmlInOut;                  // The xml being saved out or loaded in
  boolean loaded = false;             // if the xml data is being loaded in

  float curX;                         // current x / last recorded x value
  float curY;                         // current y / last recorded y value
  float curZ;                         // current z / last recorded z value

  PApplet         mRoot;


  DataRecorder(PApplet root) {
    mRoot = root;
  }


  void update(PVector p) {

    if (recording) {
      if (frameCount%60 == 0) {
        count--;
      }

      // record the value
      points.add(p);

      textAlign(CENTER);
      text("RECORDING: "+ count, width/2, 20); // show the countdown text

      // Once the countdown is complete, save the data
      if (count == 0) {
        stopRecording();
      }
    }
  }


  // save the recorded points to a new file
  void saveDataToFile() 
  {
    xmlInOut = new XMLInOut(mRoot);
    proxml.XMLElement coords = new proxml.XMLElement("coords");
    for (int i=0; i<points.size(); i++)
    {
      PVector p = (PVector)points.get(i); 
      proxml.XMLElement rotation = new proxml.XMLElement("rotation");
      rotation.addAttribute("xRot", p.x);
      rotation.addAttribute("yRot", p.y);
      rotation.addAttribute("zRot", p.z);
      coords.addChild(rotation);
    }
    xmlInOut.saveElement(coords, "data_" + (System.currentTimeMillis()/1000) +".xml");
  }



  void startRecording() {
    recording = true;
    frameCount = 0;
    count = countDownMax;
    points = new ArrayList();
  }

  void stopRecording() {
    recording = false;
    saveDataToFile();
  }
}
