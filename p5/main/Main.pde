
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

  if(m.getAddress().equals( "/amp/env")) {
    println("got test message");
    println("Address\t" + m.getAddress());   
    println("Typetag\t" + m.getTypetag());
    byte[]  v0 = m.bytesValue(0);
    println("Args\t"+v0);
    println(">--");
    
    // TODO: collect into Levels ArrayList and set globally for all 
    // future FM synths same for env Times    
    for( Object o : m.getArguments() ) {
      println( o.getClass().getSimpleName() + "\t" + o );
    }
    println("--<");    
    //r = m.floatValue( 0 );
  } else if(m.getAddress().equals( "/play2")) {    
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
  } else {
    println( "------------------------------------------------------" );
    println( "WARNING! Unhandled OSC at:" );
    println( "Address\t" + m.getAddress() );
  }
  
  if (sample != null) {
    thing = new Thing(sample, attack, decay, sustain, release, pan, gain);
    println(thing.toString());
    things.add(thing);
  }
}
