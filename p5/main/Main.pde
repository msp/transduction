import oscP5.*;
import netP5.*;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

PostFX fx;
OscP5 osc;

ArrayList<Thing> things = new ArrayList<Thing>();
HashMap<String, Float> fxValues = new HashMap();
PFont font;
float globalSustain = 1.0;

PShader blur;

void settings() {
  size(1024, 768, P3D); //local low res
  //size(1920, 1200, P3D); //Gray Arts resolution
  //fullScreen(P3D, 2);
}

void setup() {
  fx = new PostFX(this);
  //smooth(); // can be set for P2d & P3D
  //textSize(40);
  osc = new OscP5(this, 1818);
  //font = loadFont("Inconsolata-48.vlw");
  //textFont(font,48);
}

void draw() {
  background(0);

  for (int i = things.size() - 1; i >= 0; i--) {
    Thing thing = things.get(i);
      if (thing != null && thing.alive()) {
        thing.draw();
        
      }
      else {
        things.remove(i);
      }
  }
  
  if (postfxLive(fxValues)) {
    fx.render()
      //.sobel()
      //.bloom(0.5, 20, 30)
      //.pixelate(50)
      //.bloom(0.2, 20, 40.0)
      //.noise(0.15, 0.2)
      .noise(fxValues.getOrDefault("noiseAmount", 0.15), 
             fxValues.getOrDefault("noiseRate", 0.2))
      .compose();  
  }
}
