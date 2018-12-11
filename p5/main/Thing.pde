class Thing {
  int start;
  float life;
  String sample;
  int sampleNum;
  float pan;
  float gain;
  float gainMult;
  float attack;
  float decay;
  float sustain;
  float globalSustain;
  float release;
  int hCutoff;
  int freq;
  
  Thing(String sample, float pan, float gain) {
    start = millis();
    life = 250;
    this.sample = sample;
    this.pan = pan;
    this.gain = gain;
  }

  Thing(String sample, int sampleNum, float attack, float decay, float sustain, float globalSustain, float release, float pan, float gain, float gainMult, int hCutoff, int freq) {
    start = millis();
    this.sample = sample;
    this.sampleNum = sampleNum;
    // this is SC's notion of sustain i.e. a multiplier for each env phase
    this.attack = attack * sustain;
    this.decay = decay * sustain;
    this.sustain = sustain;
    this.globalSustain = globalSustain;
    this.release = release * sustain;
    this.pan = pan;
    this.gain = gain;
    this.gainMult = gainMult;
    this.hCutoff = hCutoff;
    this.freq = freq;
        
    if (this.sample.equals("mspAdd") 
      || this.sample.equals("msp808")
      || this.sample.equals("mspSnare")
      || this.sample.equals("superzow")
      ) {
      life = (this.attack + this.decay + this.release) * 1000;
    } else {
          if (this.sample.equals("mspFM")){
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
    int maxHPF = 2000;
    int skew = 3;
    int freq = 440;
         
    // hcutoff -> init height
    mainSize = floor(map(this.hCutoff, 0, maxHPF, height/3, 10));
    
    freq = floor(map(this.freq, 0, 8000, 1, 255));
    
    // scale a bit visually
    gain = gain * gainMult; 
        
    if (progress < 1) {      
      //fill(204, 102, 0,this.alpha(progress));
      //textAlign(CENTER);
      //text(sample,width*pan,height/2);
      //text(sample,width/2,height/2);
      
      if (this.sample.equals("mspAdd") || this.sample.equals("msprhodes") || this.sample.equals("m-metal")) {
        noStroke();
        //fill(255,255,255,this.alpha(progress));
        fill(255,0,0,this.alpha(progress));
        ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      } else if (this.sample.equals("mspFM")) {
        strokeWeight(10);
        stroke(0,255,0,this.alpha(progress));
        noFill();        
        ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      } else if (this.sample.equals("superzow")) {
        noStroke();
        colorMode(HSB);
        fill(freq,255,255,this.alpha(progress));
        colorMode(RGB, 255, 255, 255);
        //strokeWeight(10);
        //stroke(0,255,0,this.alpha(progress));
        //noFill();        
        ellipse(width*(pan+wobble/2000),height/2, (mainSize/skew)*gain,mainSize*gain);

      } else if (this.sample.equals("form-msp4") || this.sample.equals("msp808")) {
        //noStroke();
        //fill(0,0,255,this.alpha(progress));
        noFill();
        strokeWeight(20);
        stroke(0,0,255,this.alpha(progress));
        ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);        
      } else if (this.sample.equals("superstatic")) {
        noStroke();
        fill(200,255,255,this.alpha(progress));
        ellipse(width*pan*wobble*15,height/2, mainSize*gain*wobble*3, 50*gain*wobble*3);        
      } else if (this.sample.equals("m-r-play")) {
        //noStroke();
        strokeWeight(25);
        stroke(255,255,255,this.alpha(progress));
        noFill();
        //fill(200,255,255,this.alpha(progress));
        //rect(0, height/3, width, height/3 * wobble);
        //line(0, height/3*wobble, width, height/3*wobble);
        ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      } else if (this.sample.equals("form-msp8")) {        
        if (this.sampleNum == 2) {
          strokeWeight(mainSize);
          stroke(55,55,255,this.alpha(progress));
          //noFill();
          ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
          //line(0, height/3*wobble, width, height/3*wobble);
        } else {
          //strokeWeight(mainSize);
          //stroke(255,55,255,this.alpha(progress));
          fill(255,55,255,this.alpha(progress));
          //noFill();
          ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
          //line((width - wobble)*pan, 0, width*pan, height*gain);

      }
      } else if (this.sample.equals("gabba") || this.sample.equals("form-msp7")) {
        noStroke();
        if (this.sample.equals("form-msp7")) {
          fill(200,255,255,this.alpha(progress));
        } else {
          fill(0,255,255,this.alpha(progress));
        }
        rect(0, height/3, width, height/3 * wobble);        
      } else if (this.sample.equals("form-msp5")) {
        noStroke();
        fill(255,100,100,this.alpha(progress));
        rect(0, height/3 * wobble, width, height/3);        
      } else {
        strokeWeight(1);
        stroke(255,255,255,this.alpha(progress));
        line((width - wobble)*pan, 0, width*pan, height*gain); 
      }
    }
  }
  
  Integer alpha(float progress) {
    Integer a;
    Float maxOp = 215.0;
    
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
    String main = "sample: "+this.sample+" | pan: "+this.pan+" | gain: "+this.gain;
    String env = "A: "+this.attack+" | D: "+this.decay+" | S: "+this.sustain+" | R: "+this.release;
    return main + " --> "+ env; 
  } 
}
