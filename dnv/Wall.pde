class Wall {
  int start_x,start_y,end_x,end_y;
  int opacity = 200;
      
  Wall(int s_x, int s_y, int e_x, int e_y) {
    start_x = s_x;
    start_y = s_y;
    end_x = e_x;
    end_y = e_y; 
  }
  
  void draw() {
    strokeWeight(10);
    stroke(64, 128, 128, opacity);
    line(start_x, start_y, end_x, end_y);
  }
  
  int getDistance(int _x, int _y){
  return 0;
  }

}
