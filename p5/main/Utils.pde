Integer alpha(float progress, float attack, float decay, float sustain, float release) {
  Integer a;
  Float maxOp = 215.0;
  
  if (progress <= attack) {
    // fade in
    a = int(map(progress, 0, attack, 0, 1) * maxOp);
  } else if (
    (progress > attack) && 
    (progress < (attack + decay))
    ) {
    // decay + sustain full
    a = int(maxOp);
  } else {
    // fade out
    a = int(map((release - progress), 0.0, release, 0.0, 1.0) * maxOp);
  }
  return a;
}
