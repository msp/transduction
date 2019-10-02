void scene2(String sample, 
            int sampleNum, 
            float progress, 
            float wobble, 
            int mainSize, 
            int maxHPF, 
            int skew, 
            int freq, 
            float gain, 
            float pan, 
            float attack, 
            float decay, 
            float sustain, 
            float release) {
              

  if (sample.equals("mspAdd") || sample.equals("msprhodes") || sample.equals("m-metal")) {
    noStroke();
    //fill(255,255,255,this.alpha(progress));
    fill(255,0,0,alpha(progress, attack, decay, sustain, release));
    ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
  } else if (sample.equals("mspFM")) {
    strokeWeight(10);
    stroke(0,255,0,alpha(progress, attack, decay, sustain, release));
    noFill();        
    ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
    
  } else if (sample.equals("superzow")) {
    noStroke();
    colorMode(HSB);
    fill(freq,255,255,alpha(progress, attack, decay, sustain, release));
    colorMode(RGB, 255, 255, 255);
    //strokeWeight(10);
    //stroke(0,255,0,this.alpha(progress));
    //noFill();        
    //ellipse(width*(pan+wobble/2000),height/2, (mainSize/skew)*gain,mainSize*gain);
    ellipse(width/2,height/2, (mainSize/skew)*gain,mainSize*gain);

  } else if (sample.equals("form-msp4") || sample.equals("msp808")) {
    //noStroke();
    //fill(0,0,255,this.alpha(progress));
    noFill();
    strokeWeight(20);
    stroke(0,0,255,alpha(progress, attack, decay, sustain, release));
    ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);        
  } else if (sample.equals("superstatic")) {
    noStroke();
    fill(200,255,255,alpha(progress, attack, decay, sustain, release));
    ellipse(width*pan*wobble*15,height/2, mainSize*gain*wobble*3, 50*gain*wobble*3);        
  } else if (sample.equals("m-r-play")) {
    //noStroke();
    strokeWeight(25);
    stroke(255,255,255,alpha(progress, attack, decay, sustain, release));
    noFill();
    //fill(200,255,255,this.alpha(progress));
    //rect(0, height/3, width, height/3 * wobble);
    //line(0, height/3*wobble, width, height/3*wobble);
    ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
  } else if (sample.equals("form-msp8")) {        
    if (sampleNum == 2) {
      strokeWeight(mainSize);
      stroke(55,55,255,alpha(progress, attack, decay, sustain, release));
      //noFill();
      ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      //line(0, height/3*wobble, width, height/3*wobble);
    } else {
      //strokeWeight(mainSize);
      //stroke(255,55,255,this.alpha(progress));
      fill(255,55,255,alpha(progress, attack, decay, sustain, release));
      //noFill();
      ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      //line((width - wobble)*pan, 0, width*pan, height*gain);

  }
  } else if (sample.equals("gabba") || sample.equals("form-msp7")) {
    noStroke();
    if (sample.equals("form-msp7")) {
      fill(200,255,255,alpha(progress, attack, decay, sustain, release));
    } else {
      fill(0,255,255,alpha(progress, attack, decay, sustain, release));
    }
    rect(0, height/3, width, height/3 * wobble);        
  } else if (sample.equals("form-msp5")) {
    noStroke();
    fill(255,100,100,alpha(progress, attack, decay, sustain, release));
    rect(0, height/3 * wobble, width, height/3);        
  } else {
    strokeWeight(1);
    //stroke(255,255,255,alpha(progress, attack, decay, sustain, release));
    //line((width - wobble)*pan, 0, width*pan, height*gain);
    //int _alpha = alpha(progress, attack, decay, sustain, release);
    //float widthOffset = map(progress, 0.0, 1.0, 0, width/2);
    //rect(width/2 + widthOffset, height/2, 10, 1 - _alpha );
    
    fill(255,100,100,alpha(progress, attack, decay, sustain, release));
    rect(0, height/3, width, height/3);        
    
  }
  
}
