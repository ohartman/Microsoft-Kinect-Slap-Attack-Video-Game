import processing.sound.*;
SoundFile file;
//color tracker
color trackcolor;
import processing.video.*;
Capture video;
int state=0;
int startDirection;
int[]rl;
int[]ud;
int ellinum;
int IsThereAElli;
int speedrl;
int speedud;

float accelerationrl;
float accelerationud;
int comback;

//face
ArrayList<PVector> vertices = new ArrayList<PVector>();
float rot_x = 0;
float rot_z = 0;
float rot_y = 0;

void setup() {
  size(1200, 800, P3D);  
  //color tracker

  video = new Capture(this, 320, 240);
  video.start();
  rl=new int[10];
  ud=new int[10];
  ellinum=0;
  speedrl=100;
  speedud=100;
  //timeNeeded=0;
  comback=0;
  IsThereAElli=0;

  //face
  loadPoints();

  //sound
  file = new SoundFile(this, "slap.mp3");
}

//color tracker
PImage captureEvent(Capture c) {  
  c.read();
  PImage camp=video.get();
  return camp;
}
void find(PImage video) {
  int closeX =0;//position of the closest color
  int closeY =0;
  float closest =10;//threshold
  int r1 = (trackcolor >> 16) & 0xff;
  int g1= (trackcolor >> 8) & 0xff;
  int b1= trackcolor & 0xff;
  for (int i =0; i<video.width; i++) {
    for (int j =0; j<video.height; j++) {
      int loc=i+j*video.width;
      color c=video.pixels[loc];
      int r = (c >> 16) & 0xff;
      int g = (c >> 8) & 0xff;
      int b = c & 0xff;

      float d= dist(r, g, b, r1, g1, b1);
      if (d<closest) {
        closeX=i;
        closeY=j;
        closest=d;
      }
    }
  }
  if (state==1) {
    // background(0);
    IsThereAElli=0;
    if (abs(closest)<10) {
      ellipse(closeX, closeY, 20, 20);
      IsThereAElli=1;
      rl[ellinum]=closeX;
      ud[ellinum]=closeY;
      //println(ellinum, ud[ellinum]);
      ellinum++;
    } else if (ellinum>3&&IsThereAElli==0) {
      rl[ellinum]=rl[ellinum-1]+(rl[ellinum-1]-rl[ellinum-2]);
      ud[ellinum]=ud[ellinum-1]+(ud[ellinum-1]-ud[ellinum-2]);
      //println("estimate speed",ellinum, ud[ellinum]);
      ellinum++;
    }
    if (ellinum>=rl.length-1) {
      file.play();
      direction();
      ellinum=0;
    }
  }
}
void direction() {
  int numzerorl=0;
  int numzeroud=0;
  for (int i=1; i<rl.length-1; i++) {
    int srl=rl[i]-rl[i-1];
    int sud=ud[i]-ud[i-1];
    //println(s);
    if (srl==0) {
      numzerorl++;
    }
    if (sud==0) {
      numzeroud++;
    }
    speedrl+=srl;
    speedud+=sud;
    //println(s,speed);
  }
  //println(numzero);
  speedrl=speedrl/(rl.length-numzerorl);
  speedud=speedud/(ud.length-numzeroud);
  //println("speed:",speed);
  if (abs(speedrl)>0) {
    accelerationrl=constrain(speedrl, -15, 15);
    //println("call direction, accrl:", accelerationrl,"ellinumber:", ellinum);
    state =2;
  }
  if (abs(speedud)>1) {
    accelerationud=constrain(speedud, -15, 15);
    //println("call direction, accud:", accelerationud,"ellinumber:", ellinum);
    state =2;
  }
}

void mouse() {
  if (mousePressed==true) {
    trackcolor=get(mouseX, mouseY);
    state=1;
    speedrl=10;
    speedud=0;
  }
}

// face
void loadPoints() {                                        
  String [] lines = loadStrings("face01.vert");
  for (int i = 0; i < lines.length; i++) {
    String[] pieces = split(lines[i], ' ');
    PVector m = new PVector(float(pieces[0]), float(pieces[1]), float(pieces[2]));
    vertices.add(m);
  }
}

void faceRotate() {
  
  if (comback==0&&(abs(rot_y)>=1||abs(rot_x)>=0.8)) {
    print("NON x: " + rot_x + " y: " + rot_y + "\n");
    accelerationrl=-accelerationrl;
    accelerationud=-accelerationud;
    comback=1;
    //println("rot_y too big");
  }

  if (comback==1&&abs(rot_y)<0.1&&abs(rot_x)<0.1) {
    print("COMEBACK x: " + rot_x + " y: " + rot_y + "\n");
    //println("1",rot_y);
    accelerationrl=0;
    accelerationud=0;
    state=1;
    comback=0;
  }
  //println("rotate",rot_y,comback);
}


void draw() {
  background(0);
  //color tracker
  video.loadPixels();
  //pushMatrix();
  PImage cam=captureEvent(video);  
  //scale(-1,1);
  image(cam, 0, 0);
  //popMatrix(); 

  mouse();  
  find(cam);//

  if (state==2) {
    //background(0);
    print("rl: " + accelerationrl*0.01 + "\n ud: " + accelerationud);
    rot_y = rot_y + accelerationrl*0.01;
    rot_x = rot_x + accelerationud*0.01;    
    faceRotate();
    //println(rot_y);
  }

  //face
  pushMatrix();   // saves the coordinate system; we're about to change it 

  //camera(640,height/2,100,1620,height/2,0, 0,-1,0);
  translate(width/2, height/2);
  scale(500);
  strokeWeight(0.01);
  rotateX(rot_x);
  rotateZ(PI);
  rotateY(-rot_y);
  stroke(255, 255, 255);
  beginShape(POINTS);
  for (PVector v : vertices) {
    vertex(v.x, v.y, v.z);
  }
  endShape();
  popMatrix();  // restore the old saved coordinate system
}
