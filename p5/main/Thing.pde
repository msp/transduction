class Thing {
  int start;
  float life;
  String txt;
  float pan;
  float gain;
  float gainMult;
  float attack;
  float decay;
  float sustain;
  float globalSustain;
  float release;  
  
  Thing(String txt, float pan, float gain) {
    start = millis();
    life = 250;
    this.txt = txt;
    this.pan = pan;
    this.gain = gain;
  }

  Thing(String txt, float attack, float decay, float sustain, float globalSustain, float release, float pan, float gain, float gainMult) {
    start = millis();
    this.txt = txt;
    // this is SC's notion of sustain i.e. a multiplier for each env phase
    this.attack = attack * sustain;
    this.decay = decay * sustain;
    this.sustain = sustain;
    this.globalSustain = globalSustain;
    this.release = release * sustain;
    this.pan = pan;
    this.gain = gain;
    this.gainMult = gainMult;
        
    if (this.txt.equals("mspAdd") 
      || this.txt.equals("msp808")
      || this.txt.equals("mspSnare")
      ) {
      life = (this.attack + this.decay + this.release) * 1000;
    } else {
          if (this.txt.equals("mspFM")){
            // hmmm fudge these as we don't have 'em
            this.attack = 0.01;
            this.decay = 0.1;
            this.sustain += this.globalSustain;
            this.release = 0.1 * this.sustain;
            life = (this.attack + this.decay + this.release) * 1000;
          } else {
            life = 350;
          }
    }
  }
  
  boolean alive () {
    //print("start: " + start + " life " + life + " now " + millis() + "\n");
    return((start+life) >= millis());
  }
  
  void draw () {
    float age = millis() - start;
    float progress = age/life;
    float wobble = randomGaussian() * 1;
    int mainSize = 300;
    int skew = 3;
     
    // scale a bit visually
    gain = gain * gainMult; 
    
    if (progress < 1) {      
      fill(204, 102, 0,this.alpha(progress));
      textAlign(CENTER);
      //text(txt,width*pan,height/2);
      //text(txt,width/2,height/2);
      
      if (this.txt.equals("mspAdd") || this.txt.equals("msprhodes") || this.txt.equals("m-metal")) {
        noStroke();
        //fill(255,255,255,this.alpha(progress));
        fill(255,0,0,this.alpha(progress));
        ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
        //rect((width - wobble)*pan, height/2, 500*gain,500*gain);
        //rect(width*pan, height/2, 500*gain,500*gain);
      } else if (this.txt.equals("mspFM") || this.txt.equals("superzow")) {
        noStroke();
        fill(0,255,0,this.alpha(progress));
        ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      } else if (this.txt.equals("form-msp4") || this.txt.equals("msp808")) {
        noStroke();
        //strokeWeight(this.sustain * 100+ wobble);
        //stroke(255,0,100,this.alpha(progress));
        //line(0, height*pan, width, height*pan); 
        fill(0,0,255,this.alpha(progress));
        ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);        
      } else if (this.txt.equals("superstatic")) {
        noStroke();
        fill(200,255,255,this.alpha(progress));
        ellipse(width*pan*wobble*15,height/2, mainSize*gain*wobble*3, 50*gain*wobble*3);        
      } else {
        strokeWeight(1);
        stroke(255,255,255,this.alpha(progress));
        line((width - wobble)*pan, 0, width*pan, height*gain); 
      }
    }
  }
  
  Integer alpha(float progress) {
    Integer a;
    Float maxOp = 255.0;
    
    if (progress <= this.attack) {
      // fade in
      a = int(map(progress, 0, this.attack, 0, 1) * maxOp);
    } else if (
      (progress > this.attack) && 
      (progress < (this.attack + this.decay))
      ) {
      // decay + sustain full
      a = int(maxOp);
    } else {
      // fade out
      a = int(map((this.release - progress), 0.0, this.release, 0.0, 1.0) * maxOp);
    }
    return a;
  }
  
  public String toString() {
    String main = "sample: "+this.txt+" | pan: "+this.pan+" | gain: "+this.gain;
    String env = "A: "+this.attack+" | D: "+this.decay+" | S: "+this.sustain+" | R: "+this.release;
    return main + " --> "+ env; 
  } 
}
