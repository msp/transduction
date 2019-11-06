public void scene3(String sample, 
            int sampleNum, 
            float note,
            float progress, 
            float wobble, 
            int hCutoff, 
            int maxHPF, 
            int skew, 
            int freq, 
            float gain, 
            float pan, 
            float attack, 
            float decay, 
            float hold,
            float sustain, 
            float release) {
              
  // hcutoff -> init height
  float mainSize = floor(map(hCutoff, 0, maxHPF, height/3, 10));  
  
  float shape_width = 1;
  float shape_height = height;

  if (sample.equals("m-metal")) {
    noStroke();
    fill(255,100,100,alphaPerc(progress, attack, release));
    rect(width*pan*wobble,height/2, (mainSize/skew)*gain,mainSize*gain);
    
    //rect(0, height/3 * wobble, width, height/3);
      
  } else if (sample.equals("mspFM")) {
    strokeWeight(10);
    stroke(0,255,0,alpha(progress, attack, decay, hold, release));
    noFill();        
    ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
    
 } else if (sample.equals("superzow") || sample.equals("testsuperzow")) {
    noStroke();
    colorMode(HSB);
  
    fill(freq,255,255,alpha(progress, attack, decay, hold, release));
    //fill(freq,255,255);
  
    colorMode(RGB, 255, 255, 255);
    //strokeWeight(10);
    //stroke(0,255,0,this.alpha(progress));
    //noFill();        
    
    ellipse(width*(pan+wobble/2000),height/2, (mainSize/skew)*gain,mainSize*gain);
    //ellipse(width*(pan),height/2, (mainSize/skew)*gain,mainSize*gain);

  } else if (sample.equals("form-msp4") || sample.equals("msp808")) {
    //shape_width = (mainSize/skew)*gain;
    //noFill();
    //strokeWeight(20);
    //stroke(0,0,0,alpha(progress, attack, decay, hold, release));           
    //rect(width*pan - shape_width/2, height/2, shape_width, mainSize*gain);

    noStroke();
    fill(255,100,100, (alphaPerc(progress, attack, release/2)));    
    rect(0, height/3, width, height/3);    
    
  } else if (sample.equals("superstatic")) {
    noStroke();
    fill(200,255,255,alpha(progress, attack, decay, hold, release));
    ellipse(width*pan*wobble*15,height/2, mainSize*gain*wobble*3, 50*gain*wobble*3);        
  } else if (sample.equals("m-r-play")) {
    //noStroke();
    strokeWeight(25);
    stroke(255,255,255,alpha(progress, attack, decay, hold, release));
    noFill();
    //fill(200,255,255,this.alpha(progress));
    //rect(0, height/3, width, height/3 * wobble);
    //line(0, height/3*wobble, width, height/3*wobble);
    ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
  } else if (sample.equals("form-msp8")) {        
    if (sampleNum == 2) {
      strokeWeight(mainSize);
      stroke(55,55,255,alpha(progress, attack, decay, hold, release));
      //noFill();
      ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      //line(0, height/3*wobble, width, height/3*wobble);
    } else {
      //strokeWeight(mainSize);
      //stroke(255,55,255,this.alpha(progress));
      fill(255,55,255,alpha(progress, attack, decay, hold, release));
      //noFill();
      ellipse(width*pan,height/2, (mainSize/skew)*gain,mainSize*gain);
      //line((width - wobble)*pan, 0, width*pan, height*gain);

  }
  } else if (sample.equals("gabba") || sample.equals("form-msp7")) {
    noStroke();
    if (sample.equals("form-msp7")) {
      fill(200,255,255,alpha(progress, attack, decay, hold, release));
    } else {
      fill(0,255,255,alpha(progress, attack, decay, hold, release));
    }
    rect(0, height/3, width, height/3 * wobble);        
  
  } else if (sample.equals("form-msp5")) {
    
    //Keep but not for this sound
    //noStroke();
    //fill(255,100,100,alpha(progress, attack, decay, hold, release));
    //rect(0, height/3 * wobble, width, height/3);
    // end keep

    shape_height = map(progress, 0, 1, 0, height);

    fill(255,100,100);
    //strokeWeight(progress*shape_height/5);
    strokeWeight(10);
    stroke(255,255,255,alpha(progress, attack, decay, hold, release));
    //line((width - wobble)*pan, 0, width*pan, height*gain);
  
    line(0+((1-progress)*(width/3)), shape_height, width-((1-progress)*(width/3)), shape_height);     //<>//
    //line(0+((progress)*(width/2)), shape_height, width-((progress)*(width/2)), shape_height);
    
    //rect(0, height/3, width, height/3);

} else if (sample.equals("superhex")) {    
    strokeWeight(freq);
    stroke(255,255,255,alpha(progress, attack, decay, hold, release));
    line((width - wobble)*pan, 0, width*pan, height*gain); 

    //fill(255,100,100, (255 - alpha(progress, attack, decay, hold, release)));
    fill(255,100,100);
    rect(0, height/3, width, height/3);

  

  } else if (sample.equals("mspLaser")) {    
    strokeWeight(sustain * width/20);
    
    stroke(255,255,255,alphaPerc(progress, attack, release/2));
    
    line((width)*pan, 0, width*pan, height*gain); 

    
  

  } else if (sample.equals("mspWaves")) {
    //int noteRange = 40;
    int noteRange = 60; // (C0 == -60, C5 == 0, C10 == 60)
    float yPos = floor(map(note, noteRange * -1, noteRange, height, 0));
    float lineLength = (width*pan)+map(progress, 0, 1, width*pan, width-(width*pan));
    float lineHeight = 160;
    //float lineHeight = (height / 1.5);

    strokeCap(PROJECT);
    //strokeWeight(80);
    strokeWeight(map(progress, 0, 1, 1, floor(lineHeight)));
    stroke(255,255,255,alpha(progress, attack, decay, hold, release));

    
    if (pan <= 0.5) {
      line(width*pan, yPos, lineLength, yPos);  
    } else {
      line(width*pan, yPos, (width*pan)-map(progress, 0, 1, width-(width*pan), width*pan), yPos);
    }
    
    //line(width*pan, yPos, (width*pan)+ width - (width*pan), yPos);
    
  } else if (sample.equals("mspVibSawPlucker")) {
    int noteRange = 60; // (C0 == -60, C5 == 0, C10 == 60)
    float yPos = floor(map(note, noteRange * -1, noteRange, height, 0));
    float lineLength = (width*pan)+map(progress, 0, 1, width*pan, width-(width*pan));
    float lineHeight = 160;

    strokeCap(PROJECT);
    //strokeWeight(80);
    strokeWeight(map(progress, 0, 1, 1, floor(lineHeight)));
    stroke(255,255,255,alpha(progress, attack, decay, hold, release));

    
    if (pan <= 0.5) {
      line(width*pan, yPos, width*pan, lineLength);  
    } else {
      line(width*pan, yPos, width*pan, (height*pan)-map(progress, 0, 1, height-(height*pan), height*pan));
    }
  } else {
    strokeWeight(5);
    stroke(255,255,255,alpha(progress, attack, decay, hold, release));
    line((width - wobble)*pan, 0, width*pan, height*gain); 
  }
  
}
