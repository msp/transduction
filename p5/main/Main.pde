
import oscP5.*;
import netP5.*;

// Needs a manual install of 2.0.4 from here: https://github.com/sojamo/oscp5/releases
// Instructions in the zip. 
// NB: it still reports itself as 2.0.3 in library.properties :/ 
OscP5 osc;

ArrayList<Thing> things = new ArrayList<Thing>();
PFont font;
float globalSustain = 1.0;

void settings() {
  //size(1024, 768);
  //size(1920, 1080);
  //size(1920, 1200); //Gray Arts resolution  
  fullScreen(2);
}

void setup() {
  //smooth();
  //textSize(40);
  osc = new OscP5(this, 1818);
  //font = loadFont("Inconsolata-48.vlw");
  //textFont(font,48);
}

void draw() {
  background(0);

  for (int i = things.size() - 1; i >= 0; i--) {
    Thing thing = things.get(i);
      if (thing != null && thing.alive()) {
        thing.draw();
      }
      else {
        things.remove(i);
      }
  }
}
