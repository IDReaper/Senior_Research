import com.shigeodayo.ardrone.manager.*;
import com.shigeodayo.ardrone.navdata.*;
import com.shigeodayo.ardrone.utils.*;
import com.shigeodayo.ardrone.processing.*;
import com.shigeodayo.ardrone.command.*;
import com.shigeodayo.ardrone.*;
import com.shigeodayo.ardrone.video.*;

import hypermedia.video.*;
import java.awt.*;
import SimpleOpenNI.*;
import com.shigeodayo.ardrone.processing.*;

ARDroneForP5 ardrone;


OpenCV opencv;


int w = 640;
int h = 480;
int threshold = 50;
Point centroid;
int mousex;
int mousey;

boolean find=true;
int drag = 0;
int s;
int blob;
Blob[] blobs;
Point TrackCent;

PFont font;
PImage img;

SimpleOpenNI  context;

void setup() { 

  size(w*2+30, h*2+30);
  
  ardrone = new ARDroneForP5("192.168.1.1");
  //connect to the AR.Drone.
  ardrone.connect();
  //connect to the sensor info.
  ardrone.connectNav();
  //connect to the image info.
  ardrone.connectVideo();
  //start the connections.
  ardrone.start();
  
  
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // mirror is by default enabled
  context.setMirror(false);

  // enable RGB generation 
  context.enableRGB();
  context.enableDepth();

  opencv = new OpenCV( this );
  opencv.capture(w, h);

  //font = loadFont( "AndaleMono.vlw" );
  font = createFont("", 10); 
  textFont( font );

  println( "Drag mouse inside sketch window to change threshold" );
  println( "Press space bar to record background image" );
}

void draw() {
  
  //println(s);
  //Update kinect, grab image, opencv.copy(img), remove opencv.read()
  background(0);
  context.update();
  PVector[] realWorldMap = context.depthMapRealWorld();
  img = context.rgbImage();
  opencv.copy(img);

  PImage droneImg = ardrone.getVideoImage(false);
  if (droneImg == null)
    return;
  //opencv.flip( OpenCV.FLIP_HORIZONTAL );

  image(droneImg, 0, -50);

  //image( opencv.image(), 10, 10 );  // RGB image
  image( opencv.image(), 10, 10+h );
  //image( opencv.image(OpenCV.GRAY), 20+w, 10 );   // GRAY image
  //image( opencv.image(OpenCV.MEMORY), 10, 20+h ); // image in memory

  opencv.absDiff();
  opencv.threshold(threshold);
  image( opencv.image(OpenCV.GRAY), 20+w, 10+h ); // absolute difference image


  float pitch = ardrone.getPitch();
  float roll = ardrone.getRoll();
  float yaw = ardrone.getYaw();
  float altitude = ardrone.getAltitude();
  float[] velocity = ardrone.getVelocity();
  int battery = ardrone.getBatteryPercentage();


  // working with blobs
  blobs = opencv.blobs( 1000, 15000, 20, true );

  noFill();

  pushMatrix();
  translate(20+w, 10);     
  try {
    // rectangle
    noFill();
    if (dist(TrackCent.x, TrackCent.y, blobs[blob].centroid.x, blobs[blob].centroid.y)<100) {
      stroke( blobs[blob].isHole ? 128 : 64 );
      Rectangle bounding_rect  = blobs[blob].rectangle;
      rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );
      println(threshold);

      // centroid

        float area = blobs[blob].area;
      float circumference = blobs[blob].length;
      centroid = blobs[blob].centroid;
      Point []points = blobs[blob].points;
      int loc = centroid.x +centroid.y*opencv.image().width;
      float depth = realWorldMap[loc].z;

      stroke(0, 0, 255);
      line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
      line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
      noStroke();
      fill(0, 0, 255);
      String string;
      string = "("+nf(centroid.x, 4)+","+nf(centroid.y, 4)+","+nf(depth, 4, 1);
      text( string, centroid.x+5, centroid.y+5 );


      fill(255, 0, 255, 64);
      stroke(255, 0, 255);
      if ( points.length>0 ) {
        beginShape();
        for ( int j=0; j<points.length; j++ ) {
          vertex( points[j].x, points[j].y );
        }
        endShape(CLOSE);
      }

      noStroke();
      fill(255, 0, 255);
      //text( circumference, centroid.x+5, centroid.y+15 );
    }
  } 
  catch(Exception e) {
    //println("error index");
  }

  popMatrix();
}

void keyPressed() {
  if ( key==' ' ) opencv.remember();
  if ( key == 't') drag = 1;
  if ( key == 'y') drag = 0;
  
  if ( key == 'o')
    takeoffRotate();
    //x,y,z,rotate
    //ardrone.move3D(0, 0, 0, -50);    
    //ardrone.landing();    
  
  
  if ( key == 'i')
    ardrone.landing();
}

void mouseDragged() {
  if (drag == 1) threshold = int( map(mouseX, 0, width, 0, 255) );
} 

void mousePressed() {
  mousex = mouseX;
  mousey = mouseY;
  for ( int i=0; i<blobs.length; i++ ) {        
    centroid = blobs[i].centroid;
    if (dist(centroid.x, centroid.y, mousex, mousey) < 100) {
      println(i);
      blob = i;
      TrackCent = centroid;
    }
  }
}
public void stop() {
  opencv.stop();
  super.stop();
}

void takeoffRotate(){
  s = second();
  println(s);
  ardrone.takeOff();
  while(s < 10){
    s = second();
    println(s);
  }
  ardrone.move3D(0, 0, 0, -100);
  
    
}

