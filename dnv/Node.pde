import org.apache.commons.collections15.buffer.*;
import java.nio.*;

class Node
{
  
/* -------------- COLORS--------------------- */
  
// Hardcoded color gradient for the values from black to red to yellow to white 
float[][] gradient = {  
{0.0417,0,0},
{0.0833,0,0},
{0.1250,0,0},
{0.1667,0,0},
{0.2083,0,0},
{0.2500,0,0},
{0.2917,0,0},
{0.3333,0,0},
{0.3750,0,0},
{0.4167,0,0},
{0.4583,0,0},
{0.5000,0,0},
{0.5417,0,0},
{0.5833,0,0},
{0.6250,0,0},
{0.6667,0,0},
{0.7083,0,0},
{0.7500,0,0},
{0.7917,0,0},
{0.8333,0,0},
{0.8750,0,0},
{0.9167,0,0},
{0.9583,0,0},
{1.0000,0,0},
{1.0000,0.0417,0},
{1.0000,0.0833,0},
{1.0000,0.1250,0},
{1.0000,0.1667,0},
{1.0000,0.2083,0},
{1.0000,0.2500,0},
{1.0000,0.2917,0},
{1.0000,0.3333,0},
{1.0000,0.3750,0},
{1.0000,0.4167,0},
{1.0000,0.4583,0},
{1.0000,0.5000,0},
{1.0000,0.5417,0},
{1.0000,0.5833,0},
{1.0000,0.6250,0},
{1.0000,0.6667,0},
{1.0000,0.7083,0},
{1.0000,0.7500,0},
{1.0000,0.7917,0},
{1.0000,0.8333,0},
{1.0000,0.8750,0},
{1.0000,0.9167,0},
{1.0000,0.9583,0},
{1.0000,1.0000,0},
{1.0000,1.0000,0.0625},
{1.0000,1.0000,0.1250},
{1.0000,1.0000,0.1875},
{1.0000,1.0000,0.2500},
{1.0000,1.0000,0.3125},
{1.0000,1.0000,0.3750},
{1.0000,1.0000,0.4375},
{1.0000,1.0000,0.5000},
{1.0000,1.0000,0.5625},
{1.0000,1.0000,0.6250},
{1.0000,1.0000,0.6875},
{1.0000,1.0000,0.7500},
{1.0000,1.0000,0.8125},
{1.0000,1.0000,0.8750},
{1.0000,1.0000,0.9375},
{1.0000,1.0000,1.0000} };
  
/* -------------- PARAMETERS--------------------- */

  int maxValue = 30; // maximum node's value
  int ttl,max_ttl = 60; // node lifetime
  int historySize = 60; //number of past values that are visualized
  float value = 10.0; //default starting value
  
/* -------------- VARIABLES --------------------- */

  // Visualization
  float opacity = 255;
  PFont arial = loadFont("Arial-Black-20.vlw");
  int lockedOffsetX,lockedOffsetY;
  color nodeColor = #669933;
  float x = 0;
  float y = 0;
  float dest_x = 0;
  float dest_y = 0;
  float r = 30;
  int ds = 2;
  float growing = 0;
  float scaleValues = 5.0;
  String label; 
  boolean selected;
  boolean locked = false;
  boolean dragging = false;
  boolean anchor = false;
  float[] valueHistory = new float[historySize];
  int historyIndex = 0;

  

/* -------------- FUNCTIONS --------------------- */

Node(String _label, color _color, float _x, float _y) {
  label=_label; 
  x=_x; 
  y=_y; 
  dest_x = _x;
  dest_y = _y;
  nodeColor = _color;
  ttl = max_ttl;
  for(int i=0;i<historySize;i++) valueHistory[i]=0.0;  
}

void ttlReset(){
  ttl = max_ttl;
}

void setAnchor(){
  anchor = true;
}

boolean isAnchor(){
  return anchor;
}

void setColor(color _color){
  nodeColor = _color;
}

void setDestination(float _x,float _y){
  dest_x = _x;
  dest_y = _y;
}

void updateHistory(){  
  valueHistory[historyIndex] = value;
  historyIndex = (historyIndex + 1) % historySize;
  if (ttl>0) ttl = ttl-1;
}
  
  void setValue(float _value){    
    value = _value;
  }

  void setLabel(String _label){
    label = _label;
  }


  void lock(){
    locked = true;
  }

  void unlock(){
    locked = false;
  }

  boolean equals(Node other) {
    if(this==other) return true;
    return label.equals(other.label); }

  void setPosition(int _x, int _y) {
    x=_x; y=_y; }

  void setRadius(int _r) {
    r=_r;
  }

  void draw() {
    // if node dies, do not visualize
    if((ttl==0)&&(!anchor)) {
      // go back home and don't visualize
      x = 278.0;
      y = 500.0;
      return;
    }
    
    // if node is selected
    selected = (sq(x - mouseX) + sq(y - mouseY) < sq(30/2));
    // show values on a larger circle
    if (selected) {
      fill(#E56498, opacity);  // pink if mouseover
      if (growing < maxValue) growing = growing+1.0;
    }
    else {
      if (ttl>0)
        fill(nodeColor, opacity); // regular
      else 
        fill(#FF0000, opacity); 
      //if (growing > 0) growing = growing-1.0;
      growing = 0.0;
    }
    
    // Handle node's drag&drop
    if ((locked && dragging)) {
      // Move the particle's coordinates to the mouse's position, minus its original offset
      x=mouseX-lockedOffsetX;
      y=mouseY-lockedOffsetY;
    }
    
    // Move node to its destination   
    if(!anchor && !dragging){
    if (x>dest_x) x=x-1;
    if (x<dest_x) x=x+1;
    if (y>dest_y) y=y-1;
    if (y<dest_y) y=y+1;
    }
    
    // Draw moving node
    if(!anchor){
    ellipse(x, y, r/1.5, r/1.5);
    // Draw id
    textSize(10);
    fill(0,0,0,150);
    textAlign(CENTER,CENTER);
    String text = label ;
    text(text,x,y);   
    return;   
    }
    
    // Draw anchor node  
    ellipse(x, y, r, r);    
    noStroke();          
    //Draw ID
    textSize(12);
    fill(0,0,0,150);
    textAlign(CENTER,CENTER);
    String text = label ;
    text(text,x,y);   
    // draw history (colored dots around the node)
     stroke(0,0,0,25);
      noFill();
      if(selected){
      float firstCircle = r+2*((maxValue/3)*scaleValues);
      float secondCircle = r+2*(((maxValue*2)/3)*scaleValues);
      float thirdCircle = r+2*(maxValue*scaleValues);
      ellipse(x, y, thirdCircle, thirdCircle);
      ellipse(x, y, secondCircle, secondCircle);
      ellipse(x, y, firstCircle, firstCircle);
      } 
    for(int i=0;i<historySize;i++){      
      int idx = (historyIndex + i) % historySize;       
      float degree = (float(idx)/float(historySize))*(PI*2);
      // skip 0 values
      if (valueHistory[idx]==0) continue;
      // scale the values and apply growing animation
      float val = min(valueHistory[idx],growing)*scaleValues;
      // decide gradient color
      int indexColor = int((min(valueHistory[idx],maxValue)/maxValue)*63);
      // compute line positions
      float start_x = cos(degree)*(r/2);
      float start_y = sin(degree)*(r/2);      
      float val_x = cos(degree)*((r/2)+val);
      float val_y = sin(degree)*((r/2)+val);
      strokeWeight(1);
      // draw circular density
      if (i == historySize-1){
        if(selected){
          fill(#FF7777);
          textAlign(RIGHT,TOP);
          text("DENSITY: "+int(valueHistory[idx]),width,0);
        }
        stroke(255,0,0, 255);
        line(x+start_x, y+start_y, x+val_x, y+val_y);
        noStroke();
        fill(gradient[indexColor][0]*255,gradient[indexColor][1]*255,gradient[indexColor][2]*255, 255);
        ellipse(x+val_x,y+val_y, 8, 8);
      } else {
        stroke(0,0,0, 25);
        line(x+start_x, y+start_y, x+val_x, y+val_y);
        noStroke();
        fill(gradient[indexColor][0]*255,gradient[indexColor][1]*255,gradient[indexColor][2]*255, 255);
        ellipse(x+val_x, y+val_y, 3, 3);
      }
    }
  }
}
