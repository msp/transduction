Integer alpha(float progress, float attack, float decay, float hold, float release) {
  Integer a;
  Float maxOp = maxOpacity();
  
  //println(progress);
  
  if (progress <= attack) {
    // fade in
    //println("--------------- Attack");
    a = int(map(progress, 0, attack, 0, 1) * maxOp);
  } else if (    
    (progress > attack) && 
    (progress < hold)
    ) {
    //println("--------------- Hold");
    a = int(maxOp);
  } else {
    //println("--------------- Release");
    // fade out
    a = int(map((release - progress), 0.0, release, 0.0, 1.0) * maxOp);
    //a = 100;
  }
  return a;
}

Integer alphaPerc(float progress, float attack, float release) {
  Integer a;
  Float maxOp = maxOpacity();
  
  //println(progress);
  
  if (progress <= attack) {
    // fade in
    //println("--------------- Attack");
    a = int(map(progress, 0, attack, 0, 1) * maxOp);
  } else {
    //println("--------------- Release");
    // fade out
    a = int(map((release - progress), 0.0, release, 0.0, 1.0) * maxOp);
    //a = 100;
  }
  return a;
}

boolean postfxLive (HashMap fxValues) {
  boolean sentfx = false;
  
  ArrayList<String> whitelist = new ArrayList<String>();
  whitelist.add("noiseAmount");
  whitelist.add("noiseRate");
  
  for (Object key : fxValues.keySet()) {
    if (whitelist.contains(key.toString())) { 
      sentfx = true;
      break;
    }
  }
  
  //if (sentfx) {
  //  println("--------------- Got some post fx! "+ fxValues);
  //}
  
  return sentfx;
}

float maxOpacity  () {
  return 215.0;
}
