import SimpleOpenNI.*;
import com.shigeodayo.ardrone.manager.*;
import com.shigeodayo.ardrone.navdata.*;
import com.shigeodayo.ardrone.utils.*;
import com.shigeodayo.ardrone.processing.*;
import com.shigeodayo.ardrone.command.*;
import com.shigeodayo.ardrone.*;
import com.shigeodayo.ardrone.video.*;

ARDroneForP5 ardrone;
SimpleOpenNI kinect;
PImage img;
PVector[] realWorldMap;
int Bmousex,Bmousey=0;
float Bmousez,Dmousez=0.0;
int Dmousex,Dmousey;
int ball = 1;
/**
 *  added new method.
 *  void move3D(int speedX, int speedY, int speedZ, int speedSpin)
 *  @param speedX : the speed of x-axis, [-100,100]
 *  @param speedY : the speed of y-axis, [-100,100]
 *  @param speedZ : the speed of z-axis, [-100,100]
 *  @param speedSpin : the speed of rotation, [-100,100]
 */

void setup()
{
  size(640, 480);
  ardrone = new ARDroneForP5("192.168.1.1");
  //connect to the AR.Drone.
  ardrone.connect();
  //connect to the sensor info.
  ardrone.connectNav();
  //connect to the image info.
  ardrone.connectVideo();
  //start the connections.
  ardrone.start();
  
  kinect = new SimpleOpenNI(this);
  if (kinect.isInit() == false){
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }
  kinect.setMirror(false);
  kinect.enableRGB();
  kinect.enableDepth();

}

void draw()
{
  kinect.update();
  realWorldMap = kinect.depthMapRealWorld();

  img = kinect.rgbImage ();
  image(img, 0, 0);
  if (!(Bmousex == 0 && Bmousey == 0 && Bmousez == 0.0 && Dmousex == 0 && Dmousey == 0 && Dmousez == 0.0)){
       println(Bmousex,Bmousey,Bmousez);
       println(Dmousex,Dmousey,Dmousez);
    }
    
}

void  delay(int wait) {
    int time = millis();
    while(millis()-time <= wait) {
      continue;   
    }
}

//void search() {
// ardrone.takeOff();
// delay(3500);
// while(true){
// ardrone.move3D(0,0,0, -1);
// }
// ardrone.landing();  
//}

void moveTo(){
  //ardrone.takeOff();
  int posCheckX = Dmousex - Bmousex;
  while (posCheckX != 0){
    if (posCheckX < 0){
      ardrone.move3D(1,0,0,0);
    }
    
    posCheckX =  Dmousex - Bmousex;
  }
  ardrone.landing();
}



void keyPressed() {
    if ( key==',' ) ball = 1;
    if ( key == '.') ball = 0;
    if (key == '/'){
      int Bloc = Bmousex + Bmousey * img.width;
      int Dloc = Dmousex + Dmousey * img.width;
      Bmousez = realWorldMap[Bloc].z;
      Dmousez = realWorldMap[Dloc].z;
    }
    if ( key == 't') ardrone.takeOff();
    if (key == 'y') moveTo();
    println(ball);
}

void mousePressed() {
  if (ball == 1){
    Bmousex=mouseX;
    Bmousey=mouseY;
    println(Bmousex,Bmousey);
  }
  if (ball == 0){
    Dmousex = mouseX;
    Dmousey = mouseY;
    println(Dmousex,Dmousey);
  }
}
