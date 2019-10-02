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
  int scene = 1;
  
  Thing(String sample, float pan, float gain) {
    start = millis();
    life = 250;
    this.sample = sample;
    this.pan = pan;
    this.gain = gain;
  }

  Thing(int scene, String sample, int sampleNum, float attack, float decay, float sustain, float globalSustain, float release, float pan, float gain, float gainMult, int hCutoff, int freq) {
    start = millis();
    this.scene = scene;
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
      
      switch(scene) {
        case 1: 
          scene1(sample, sampleNum, progress, wobble, mainSize, maxHPF, skew, freq, gain, pan, attack, decay, sustain, release);
          break;
        case 2: 
          scene2(sample, sampleNum, progress, wobble, mainSize, maxHPF, skew, freq, gain, pan, attack, decay, sustain, release);
          break;
        default:
          scene1(sample, sampleNum, progress, wobble, mainSize, maxHPF, skew, freq, gain, pan, attack, decay, sustain, release);
          break;
      }      
    }
  }
  
  public String toString() {
    String main = "scene: ["+this.scene+"] | sample: "+this.sample+" | pan: "+this.pan+" | gain: "+this.gain;
    String env = "A: "+this.attack+" | D: "+this.decay+" | S: "+this.sustain+" | R: "+this.release;
    return main + " --> "+ env; 
  } 
}
