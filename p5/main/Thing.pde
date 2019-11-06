class Thing {
  int start;
  float life;
  String sample;
  int sampleNum;
  float note;
  float pan;
  float gain;
  float gainMult;
  float attack;
  float decay;
  float hold;
  float sustain;
  float globalSustain;
  float release;
  int hCutoff;
  int freq;
  int scene = 1;
  
  Thing(String sample, float pan, float gain) {
    start = millis();
    life = 250;
    this.sample = sample;
    this.pan = pan;
    this.gain = gain;
  }

  Thing(int scene, String sample, int sampleNum, float note, float attack, float decay, float hold, float sustain, float globalSustain, float release, float pan, float gain, float gainMult, int hCutoff, int freq) {
    start = millis();
    this.scene = scene;
    this.sample = sample;
    this.sampleNum = sampleNum;
    this.note = note;
    // This is SC's notion of sustain i.e. a multiplier for each env phase or duration
    this.attack = attack;
    this.decay = decay;
    this.hold = hold;
    this.sustain = sustain;
    this.globalSustain = globalSustain;
    this.release = release;
    this.pan = pan;
    this.gain = gain;
    this.gainMult = gainMult;
    this.hCutoff = hCutoff;
    this.freq = freq;
        
    if (this.sample.equals("mspAdd") 
      || this.sample.equals("msp808")
      || this.sample.equals("mspSnare")
      || this.sample.equals("superzow")
      || this.sample.equals("testsuperzow")
      || this.sample.equals("mspWaves")
      || this.sample.equals("mspVibSawPlucker")
      || this.sample.equals("mspLaser") 
      || this.sample.equals("form-msp5") 
      ) {
      // In SC, the release is the longest part of the env so just convert that to millis 
      // it may however be scaled by the sustain param so include that.
      life = this.release * sustain * 1000;
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
    //print("start: " + start + " at " + (millis() - start) + "/" + life + "\n");
    return((start+life) >= millis());
  }
  
  void draw () {
    float age = millis() - start;
    float progress = age/life;
    float wobble = randomGaussian() * 1;
    //int mainSize = 300;
    int maxHPF = 2000;
    int skew = 3;
    //int freq = 440;
             
    // scale a bit visually
    gain = gain * gainMult; 
        
    if (progress < 1) {      
      //fill(204, 102, 0,this.alpha(progress));
      //textAlign(CENTER);
      //text(sample,width*pan,height/2);
      //text(sample,width/2,height/2);
      
      
      //method("scene" + scene);
      
      switch(scene) {
        case 1: 
          scene1(sample, sampleNum, note, progress, wobble, hCutoff, maxHPF, skew, freq, gain, pan, attack, decay, hold, sustain, release);
          break;
        case 2: 
          scene2(sample, sampleNum, note, progress, wobble, hCutoff, maxHPF, skew, freq, gain, pan, attack, decay, hold, sustain, release);
          break;
        case 3: 
          scene3(sample, sampleNum, note, progress, wobble, hCutoff, maxHPF, skew, freq, gain, pan, attack, decay, hold, sustain, release);
          break;
        default:
          scene1(sample, sampleNum, note, progress, wobble, hCutoff, maxHPF, skew, freq, gain, pan, attack, decay, hold, sustain, release);
          break;
      }      
    }
  }
  
  public String toString() {
    String main = "scene: ["+this.scene+"] | sample: "+this.sample+" | pan: "+this.pan+" | gain: "+this.gain;
    String env = "A: "+this.attack+" | D: "+this.decay+" | H: "+this.hold+" | R: "+this.release+ " | " + this.life;
    return main + " --> "+ env; 
  } 
}
