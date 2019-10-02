
import oscP5.*;
import netP5.*;

OscP5 osc;

ArrayList<Thing> things = new ArrayList<Thing>();
PFont font;
float globalSustain = 1.0;

void setup() {
  size(1024, 768);
  //size(1920, 1080);
  //size(1920, 1200); -- Gray Arts resolution  
  //fullScreen(2);
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

void oscEvent(OscMessage m) {
  int i;
  String sample = null;
  int scene = 1; 
  int sampleNum = 0;
  float pan = 0.5;
  float gain = 1;
  float attack = 0;
  float decay = 0;
  float sustain = 1;
  float release = 0.5;
  float gainMult = 1.0;
  int hCutoff = 0;
  int freq = 440;

  Thing thing;

  //inspect the OSC message
  //m.print();

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
  } else if(m.getAddress().equals( "/amp/env/sustain")) {
    println("got sustain message");
    println("Address\t" + m.getAddress());
    println("Typetag\t" + m.getTypetag());
    println("Args\t"+m.floatValue(0));

    globalSustain = m.floatValue(0);
  } else if(m.getAddress().equals( "/play2")) {
    for(i = 0; i < m.typetag().length(); ++i) {
      String name = m.get(i).stringValue();
      //println(name);
      switch(name) {
        case "scene":
          scene = (int) m.get(i+1).floatValue();
          break;
        case "s":
          sample = m.get(i+1).stringValue();
          break;
        case "n":
          sampleNum = floor(m.get(i+1).floatValue());
          break;
        case "pan":
          pan = m.get(i+1).floatValue();
          //pan = random(0,1);
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
        case "gmult":
          gainMult = m.get(i+1).floatValue();
          break;
        case "hcutoff":
          hCutoff = floor(m.get(i+1).floatValue());
          break;
        case "freq":
          freq = floor(m.get(i+1).floatValue());
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
    thing = new Thing(scene, sample, sampleNum, attack, decay, sustain, globalSustain, release, pan, gain, gainMult, hCutoff, freq);
    things.add(thing);
    println(thing.toString());
  }
}
