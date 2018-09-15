
import oscP5.*;
import netP5.*;

OscP5 osc;

ArrayList<Thing> things = new ArrayList<Thing>();
PFont font;

void setup() {
  smooth();
  size(1000, 1000);
  //fullScreen();
  textSize(40);
  osc = new OscP5(this, 1818);
  font = loadFont("Inconsolata-48.vlw");
  textFont(font,48);
}

void draw() {
  background(0);

  for (int i = things.size() - 1; i >= 0; i--) {
    Thing thing = things.get(i);
      if (thing.alive()) {
        thing.draw();
      }
      else {
        things.remove(i);
      }
  }
}

void oscEvent(OscMessage m) {
  int i;
  String sample = null;
  float pan = 0.5;
  float gain = 1;
  float attack = 0;
  float decay = 0;
  float sustain = 1;
  float release = 0.5;
  Thing thing;

  for(i = 0; i < m.typetag().length(); ++i) {
    String name = m.get(i).stringValue();
    switch(name) {
      case "s":
        sample = m.get(i+1).stringValue();
        break;
      case "pan":
        pan = m.get(i+1).floatValue();
        break;
      case "attack":
        attack = m.get(i+1).floatValue();
        break;
      case "decay":
        decay = m.get(i+1).floatValue();
        break;
      case "sustain":
        sustain = m.get(i+1).floatValue();
        break;
      case "release":
        release = m.get(i+1).floatValue();
        break;
      case "gain":
        gain = m.get(i+1).floatValue();
        break;
      case "scene":
        String scene = m.get(i+1).stringValue();
        println("scene: " + scene);
        break;
    }
    ++i;
  }
  
  if (sample != null) {
    thing = new Thing(sample, attack, decay, sustain, release, pan, gain);
    println(thing.toString());
    things.add(thing);
  }
}