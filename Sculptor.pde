import processing.opengl.*;
import proxml.*;                    // The library that enables xml loading and saving

class Sculptor {

  float curAngle;
  int amt = 100;
  float radiusMult = 500;
  boolean loaded = false;
  ArrayList<PVector> points;                   // List of points to save/draw
  PApplet mRoot;


  Sculptor(PApplet root) {
    mRoot = root;
    //lights();
  }


  void update() {
    fill(255);
    if (loaded) {
      //println("DRAW THE DAMN THING");
       
      // loop through all the points     
      int amt = points.size();
      println(amt);
      float spacing = 4.0;
      float maxHeight = spacing * amt;
      for (int i=0; i<amt; i++) {
        PVector pt = points.get(i);
        
        // makes sure the data is in the range of -1 to 1
        pt.x = constrain(pt.x, -1, 1);
        pt.y = constrain(pt.y, -1, 1);
        pt.z = constrain(pt.z, -1, 1);
        
        pushMatrix();
        translate(0, -maxHeight/2 + (i*spacing + (pt.z*spacing)));
        rotateX(PI/2);
       
        ellipse(0, 0, pt.x*radiusMult, pt.y*radiusMult);
        popMatrix();
        
      }
    }
  }




  // load an xml file
  void loadDataFromFile() 
  {
    String loadPath = selectInput("Select XML file");  // Opens file chooser
    if (loadPath == null) {
      // If a file was not selected
      println("No file was selected...");
    } 
    else {
      // If a file was selected, print path to file
      println(loadPath);
      XMLInOut xmlInOut = new XMLInOut(mRoot);
      xmlInOut.loadElement(loadPath);
    }

    
  
  }


  // Called once the xml file is loaded
  void loadXmlEvent(proxml.XMLElement element) 
  {
    points = new ArrayList();
    for (int i=0; i<element.countChildren(); i++)
    {
      proxml.XMLElement rotation = element.getChild(i);
      PVector p = new PVector(new Float(rotation.getAttribute("xRot")), new Float(rotation.getAttribute("yRot")), new Float(rotation.getAttribute("zRot")));
      points.add(p);
    }

    println("DATA LOADED");
    // setting loaded to true will trigger it to draw the points
    loaded = true;
  }
}



