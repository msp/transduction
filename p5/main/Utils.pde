Integer alpha(float progress, float attack, float decay, float hold, float release) {
  Integer a;
  Float maxOp = 215.0;
  
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
