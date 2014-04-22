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
  PVector[] realWorldMap = kinect.depthMapRealWorld();

  PImage img = kinect.rgbImage ();
  image(img, 0, 0);
  if (!(Bmousex == 0 && Bmousey == 0 && Dmousex == 0 && Dmousey == 0)){
    int Bloc = Bmousex + Bmousey * img.width;
    int Dloc = Dmousex + Dmousey * img.width;
    Bmousez = realWorldMap[Bloc].z;
    Dmousez = realWorldMap[Dloc].z;
    if (Bmousez == 0){
      Bmousex = 0;
      Bmousey = 0;
    }
    else if ( Dmousez == 0){
      Dmousex = 0;
      Dmousey = 0;
    }
    else {
       println(Bmousex,Bmousey,Bmousez);
       println(Dmousex,Dmousey,Dmousez);
    }
    
  }
  
  
}

void  delay(int wait) {
    int time = millis();
    while(millis()-time <= wait) {
      continue;   
    }
}

void keyPressed() {
    if ( key==',' ) ball = 1;
    if ( key == '.') ball = 0;
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
