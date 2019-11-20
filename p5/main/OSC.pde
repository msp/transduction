void oscEvent(OscMessage m) {
  int i;
  String sample = null;
  int scene = 1; 
  int sampleNum = 0; // for samples
  float speed = 1;
  float note = 0; // for synths
  float pan = 0.5;
  float gain = 1;
  // these env defaults match our standard ENV shape in SC
  float attack = 0.01;
  float decay = 0.2;
  float hold = 0.95;
  float sustain = 1;
  float release = 1;
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
        case "speed":
          speed = floor(m.get(i+1).floatValue());
          break;
        case "note":
          note = m.get(i+1).floatValue();
          break;
        case "pan":
          pan = m.get(i+1).floatValue();
          //pan = random(0,1);
          break;
        case "mAttackTime":
          attack = m.get(i+1).floatValue();
          break;
        case "mDecayTime":
          decay = m.get(i+1).floatValue();
          break;
        case "mHoldTime":
          hold = m.get(i+1).floatValue();
          break;
        // the SC mulitplier, not the ENV sustain which is mHoldTime above
        case "sustain":
          sustain = m.get(i+1).floatValue();
          break;
        case "mReleaseTime":
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
        case "fxNoiseAmount":
          fxValues.put("noiseAmount", m.get(i+1).floatValue());
          break;
        case "fxNoiseRate":
          fxValues.put("noiseRate", m.get(i+1).floatValue());
          break;
        case "fxSobel":
          fxValues.put("sobel", m.get(i+1).floatValue());
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
    thing = new Thing(scene, sample, sampleNum, speed, note, attack, decay, hold, sustain, globalSustain, release, pan, gain, gainMult, hCutoff, freq);
    things.add(thing);
    //println(thing.toString());
  }
}
