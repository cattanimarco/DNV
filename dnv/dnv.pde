import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.Vector;
import processing.serial.*;
import processing.net.*;
import java.util.Calendar;

/* -------------- PARAMETERS ------------------- */

// File names
String anchorsFile = "./data/anchor_nodes.txt";
String positionsFile = "./data/node_positions.txt";
String topologyFile = "./data/plans.jpg";
String logFile = "./sniffer_log.txt";

// Visualization
int frmRate = 25; // Framerate of the visualization
boolean paused = true; //Start in a paused state (press 'p' key to start reading the log)
int max_nodes = 100; // Maximum number of nodes
color[] nodeColors = {#92B2CC,#C2D6AD,#E6E699,#EBC2AD}; // Set of node' colors
int edgeTTL = frmRate*2; // set the amount of time an edge will be visualized (default: 2s)
String grid_placement = "fixed"; //other options are 'grid' and 'random'
float birthX = 278.0; // set the location to make non-anchor nodes to appear (in fixed mode)
float birthY = 500.0; // set the location to make non-anchor nodes to appear (in fixed mode)



/* -------------- VARIABLES --------------------- */

String[] anchorNodes;
String[] nodePositions;
PImage topologyImg;
PrintWriter positionFile;
long Tms = 0;
Calendar c = Calendar.getInstance();
String[] log;
int log_line = 0;
int count = 0; // Actual number of nodes in the network
HashMap<String,Float> nodeX = new HashMap<String,Float>(100); // defaul node position 
HashMap<String,Float> nodeY = new HashMap<String,Float>(100);  // default node position
boolean edit_mode,edit_preview = false;
int start_x,start_y;
Vector walls = new Vector();
Node[] nodes = new Node[max_nodes];
int[][] edges = new int[max_nodes][max_nodes]; 
HashMap<String,Integer> labelToId = new HashMap<String,Integer>(100); // label-id association
Set<String> anchorSet = new HashSet<String>(50); // anchor nodes

/* -------------- FUNCTIONS --------------------- */

int addNodeToGraph(String _label){
    if (!labelToId.containsKey(_label)) {
      // associate id to label
      labelToId.put(_label,count);
      if (grid_placement == "random")nodes[count] = new Node(_label,nodeColors[0],random(width),random(height));
      if (grid_placement == "fixed")nodes[count] = new Node(_label,nodeColors[0],birthX,birthY);       
      // check if node is an anchor
      for (int i = 0; i < anchorNodes.length; i = i+1) {
        if (_label.equals(anchorNodes[i])) {
          nodes[count].setAnchor();
          nodes[count].setColor(nodeColors[3]);
        }          
      }    
      count = count+1;
      // return numerical node id
      return count-1;
    } else {
      // return numerical node id
      return labelToId.get(_label);
    }
}

int evalExchange(String _node1, String _node2, String _val) {
  float new_x,new_y;
    // check if node is already in the network. Add to network OR get their ID
    int n1 = addNodeToGraph(_node1);
    int n2 = addNodeToGraph(_node2);
    // set the value of the first node
    nodes[n1].setValue(10000.0/float(_val));
    // set node destination to their median position
    new_x = new_y = 0.0;    
    new_x = ((nodes[n1].x+nodes[n2].x)/2)+ random(10)-5 ;
    new_y = ((nodes[n1].y+nodes[n2].y)/2)+ random(10)-5 ;
    // reset TTL if one of the 2 nodes is an anchor
    if (nodes[n2].isAnchor()||nodes[n1].isAnchor()){
      edges[n1][n2] = edgeTTL;
      edges[n2][n1] = edgeTTL;
      nodes[n1].ttlReset();
      nodes[n2].ttlReset();
      nodes[n1].setDestination(new_x,new_y); // Anchors will not move
      nodes[n2].setDestination(new_x,new_y); // Anchors will not move 
      return 1;
    }
    return 0;
}

void setup() {   
  // Load topology
  topologyImg = loadImage(topologyFile);
  size(topologyImg.width, topologyImg.height); 
  // Load experiment's files 
  log = loadStrings(logFile);
  anchorNodes = loadStrings(anchorsFile);
  // Setup visualization
  frameRate(frmRate);
  // Initialize edges
  for (int i=0;i<max_nodes;i++) 
    for (int j=0;j<max_nodes;j++) 
      edges[i][j] = 0;
}

void draw() {

  // Draw background + floorplan  
  background(255,255,255,0);
  image(topologyImg, 0, 0);
  fill(255, 255, 255, 220);
  rect(0, 0, width, height);

  if(!paused){
    // Read 10 line per frame
    //TOD0: read based on timestamp in the log --> split(log[log_line],' ')[1] 
    for (int i=0;i<10;i++){
      evalExchange(split(log[log_line],' ')[2],split(log[log_line],' ')[3],split(log[log_line],' ')[4]);
      log_line++;
      log_line = log_line % (log.length-1);
     }
     // Print date and time
    fill(#000000,100);
    textSize(15);
    textAlign(RIGHT,BOTTOM);
    c.setTimeInMillis(Long.parseLong(split(log[log_line],' ')[0]));
    text(c.get(Calendar.DAY_OF_MONTH)+"/"+c.get(Calendar.MONTH)+"/"+c.get(Calendar.YEAR)+" "+c.get(Calendar.HOUR_OF_DAY)+":"+c.get(Calendar.MINUTE),width-50,height-200);
  }
  // Draw edges
  for (int i=0; i<count; i++){
    for (int j=0;j<count;j++) {
      if (nodes[i].ttl*nodes[j].ttl!=0){ 
        if (edges[i][j]>0) {
          edges[i][j] = edges[i][j] - 1; // decrease edge TTl
          strokeWeight(1);       
          stroke(64, 128, 128,(edges[i][j]*255)/(edgeTTL*2)); // I normalize the TTL (2 times since I draw the edge 2 time) and then scale it from 0 to 225. 
          line(nodes[i].x, nodes[i].y, nodes[j].x, nodes[j].y);
        }
      }
    }
  }
  // Draw nodes
  for (int i=0; i<count; i++){
    noStroke();
    nodes[i].draw();
    // update nodes' history every second (1 tick of the visualized clock)
     if ((frameCount%frmRate) == 0) nodes[i].updateHistory();
  }
  // Draw walls
  for (int i=0; i<walls.size(); i++){
    Wall w = (Wall)walls.get(i);
    w.draw();
  }   
  // Edit mode visualization
  if(edit_mode) {
    fill(#ff0000,30);
    textSize(150);
    textAlign(CENTER);
    text("EDITING",width/2,height/2);
    if (edit_preview) {
      Wall w = new Wall(start_x,start_y,mouseX,mouseY);
      w.draw();
    }      
  }
}

void keyPressed() {
  if (key == 's'){
    positionFile = createWriter("node_positions.txt"); 
    for (int i=0; i<count; i++){
      positionFile.print(nodes[i].label +" "+nodes[i].x+" "+nodes[i].y+"\n");
    }
    positionFile.flush();  // Writes the remaining data to the file
    positionFile.close();
  }
  if (key == 'l'){
    nodePositions = loadStrings("node_positions.txt");  
    for (int i = 0; i < nodePositions.length; i = i+1) {
      String[] fileFields = split(nodePositions[i],' ');        
      int idx = addNodeToGraph(fileFields[0]);
      if (nodes[idx].isAnchor()){
        nodes[idx].x = Float.parseFloat(fileFields[1]);
        nodes[idx].y = Float.parseFloat(fileFields[2]);
      }
    }
  } 
  if (key == 'p'){
    paused = !paused;
  }
  if (key == 'e'){
    if (edit_mode == false){
      edit_mode = true;
    } else {
      edit_mode = false;
    }
  }
}

void mousePressed () {
  // If in edit mode, get wall's starting point
  if(edit_mode){
    edit_preview = true;
    start_x = mouseX;
    start_y = mouseY;
    return;
  }
  // Handle node's drag&drop
  for (int j=0;j< count;j++) {
    // If the circles are close...
    if (sq(nodes[j].x - mouseX) + sq(nodes[j].y - mouseY) < sq(nodes[j].r/2)) {
      // Store data showing that this circle is locked, and where in relation to the cursor it was
      nodes[j].locked = true;
      nodes[j].lockedOffsetX = mouseX - (int)nodes[j].x;
      nodes[j].lockedOffsetY = mouseY - (int)nodes[j].y;
      // Break out of the loop because we found our circle
      nodes[j].dragging = true;
      break;
    }
  }
}

void mouseReleased() {
  // If in edit mode, get wall's ending point. Then draw the wall
  if(edit_mode){
    edit_preview = false;
    walls.add(new Wall(start_x,start_y,mouseX,mouseY));
    return;
  }
  // register that user is no-longer dragging
  for (int j=0;j< count;j++) {
    if(nodes[j].dragging) {
      nodes[j].dragging = false;
      break;
    }
  }
}
