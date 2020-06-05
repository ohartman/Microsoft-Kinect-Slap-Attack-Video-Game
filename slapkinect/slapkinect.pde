import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import processing.sound.*;

//objects
SoundFile file;
Kinect kinect;

//PImage
PImage depthImg;

//ints
int minDepth = 100;
int maxDepth = 700;
int state, sumI, sumJ, sumZ, xVel, yVel, rightVote, leftVote, downVote, upVote, voteTally, prevI, prevJ, currentI, currentJ, prevAvg, currentAvg = 0; 
int check1,check2, timeout = 0;
//floats
float angle; 

//face
ArrayList<PVector> vertices = new ArrayList<PVector>();
float rot_x = 0;
float rot_z = 0;
float rot_y = 0;

void setup() {
  
  
  size(1400, 700, P3D);

  kinect = new Kinect(this);
  kinect.initDepth();
  angle = kinect.getTilt(); 

  depthImg = new PImage(kinect.width, kinect.height);

  //face
  loadPoints();

  //sound
  file = new SoundFile(this, "slap.mp3");
}

void loadPoints() {                                        
  String [] lines = loadStrings("face01.vert");
  for (int i = 0; i < lines.length; i++) {
    String[] pieces = split(lines[i], ' ');
    PVector m = new PVector(float(pieces[0]), float(pieces[1]), float(pieces[2]));
    vertices.add(m);
  }
}

void draw() {
  background(0);
  
  fill(255);
  text("FOR BEST FUNCTIONALITY PLEASE MAKE SURE TO CLEAR THE AREA IN FRONT OF KINECT! A MESSAGE WILL APPEAR TO INFORM YOU WHEN SENSOR IS CLEAR OF NOISE!", 10,40);
  //image(kinect.getDepthImage(), 0, 0);
  int count = 0;
  sumI = 0; 
  sumJ = 0;
  sumZ = 0;
  int[] rawDepth = kinect.getRawDepth();
  if (state == 0) {
    for (int i = 0; i< depthImg.width; i+=10) {
      for (int j = 0; j < depthImg.height; j+=10) {
        int loc = i + j*depthImg.width; 
        if (rawDepth[loc] <= maxDepth && rawDepth[loc] >= minDepth) {
          sumI += i;
          sumJ += j; 
          count++;
        }
      }
    }
    if (count != 0) {
      prevI = currentI;
      prevJ = currentJ;
      currentI = sumI/count;
      currentJ = sumJ/count;
      xVel += abs(currentI - prevI);
      yVel += abs(currentJ - prevJ);
      if (prevI > currentI) {
        rightVote++;
      } 
      if (prevI < currentI) {
        leftVote++;
      }
      if (prevJ > currentJ) {
        upVote++;
      } 
      if (prevJ < currentJ) {
        downVote++;
      }
      voteTally++;
    } else {
      fill(255);
      text("SENSOR CLEAR! READY FOR A SLAP!", 250, 300);
    }
  }
  pushMatrix();
  if (voteTally >= 20) {
    if (state == 0) {
      xVel = xVel/voteTally;
      yVel = yVel/voteTally;
      file.play();
    }
    if (rightVote > leftVote && upVote > downVote) {//rightup --
      state = 1;
      ;
      rot_x -= abs(xVel *.001 +.0005);
      rot_y -= abs(yVel *.005 +.0005);
      timeout++;
      if (abs(rot_x) > 1 || abs(rot_y) >1.5|| timeout > 50) {
        check1 = 1;
      }
    }
    if (rightVote < leftVote && upVote > downVote) {//leftup +-
      state = 1;
      
      rot_x -= abs(xVel *.001 +.0005);
      rot_y += abs(yVel *.005 +.0005);
      timeout++;
      if (abs(rot_x) > 1 || abs(rot_y) >1.5|| timeout > 50) {
        check1 = 1;
      }
    }
    if (rightVote > leftVote && upVote < downVote) {//rightdown -+
      state = 1;
      rot_x += abs(xVel *.001 +.0005);
      rot_y -= abs(yVel *.005 +.0005);
      timeout++;
      if (abs(rot_x) > 1 || abs(rot_y) >1.5||timeout> 50) {
        check1 = 1;
      }
    }
    if (rightVote < leftVote && upVote < downVote) {//leftdown ++ 
      state = 1;
      rot_x += abs(xVel *.001 +.0005);
      rot_y += abs(yVel *.005 +.0005);
      timeout++;
      if (abs(rot_x) > 1 || abs(rot_y) >1.5||timeout > 50) {
        check1 = 1;
      }
    }
  }
  if (check1 == 1) {
    timeout = 0;
    rot_x = 0;
    rot_y = 0;
    check1 = 0;
    xVel = 0;
    yVel = 0;
    upVote = 0;
    leftVote = 0;
    downVote = 0;
    rightVote = 0;
    voteTally = 0;
    state = 0;
  }

  depthImg.updatePixels();
  translate(width/2, height/2);
  scale(500);
  strokeWeight(0.01);
  rotateX(rot_x);//down + up -
  rotateZ(PI);
  rotateY(-rot_y); //left + right -
  stroke(255, 255, 255);
  beginShape(POINTS);
  for (PVector v : vertices) {
    vertex(v.x, v.y, v.z);
  }
  endShape();
  popMatrix();
}
