import SimpleOpenNI.*;
import blobscanner.*;

Detector bd;

PImage img,img1;
SimpleOpenNI  context;
int []       averageDepth = new int[307200];

void setup()
{
  size(640, 480);
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // mirror is by default enabled
  context.setMirror(false);

  // enable depthMap generation 
  context.enableDepth();
  context.enableRGB();
  
  String[] stuff = loadStrings("C:/Users/Dae/Documents/GitHub/Test_Repo/CSC490/Kinect/StaticEnv/avgDepthData.txt");
  averageDepth = int(split(stuff[0],' '));
//  int[][] combinedDepth = new int[100][307200];
//  for (int i = 0; i<100;i++) {
//    context.update();
//    int[]   depthMap = context.depthMap();
//    combinedDepth[i] = depthMap;
//  }
//  for (int i = 0; i<100;i++){
//    for (int x = 0; x<context.depthWidth()*context.depthHeight();x++){
//      averageDepth[x]+=combinedDepth[i][x];
//    }
//  }
//  for (int i = 0; i<context.depthWidth()*context.depthHeight();i++){
//     averageDepth[i] /= 100;
//  }
  
//  context.update();
//  img = context.depthImage();
}

void draw()
{
  // update the cam
  context.update();
  background(200, 0, 0);
  
  int     index;
  PVector realWorldPoint;
  int[]   depthMap = context.depthMap();
  PVector[] realWorldMap = context.depthMapRealWorld();
  
  img1 = context.rgbImage();
  img = context.depthImage();
  
  for(int y=0;y < context.depthHeight();y+=1)
  {
    for(int x=0;x < context.depthWidth();x+=1)
    {
      index = x + y * context.depthWidth();
      if(depthMap[index] > 0)
      { 
        // draw the projected point
//        realWorldPoint = context.depthMapRealWorld()[index];
        realWorldPoint = realWorldMap[index];
        if (depthMap[index]-averageDepth[index]>-100 && depthMap[index]-averageDepth[index]<100) {
          img.pixels[index] = color(0,0,0);
        }
        else {
          img.pixels[index] = color(255,255,255);
        }
      }
      //println("x: " + x + " y: " + y);
    }
  }

  bd = new Detector(this, 255 );
  

  // draw depthImageMap
  image(img1, 0, 0);
  bd.imageFindBlobs(img);
  bd.loadBlobsFeatures();

  strokeWeight(5);
  stroke(255, 0, 0);
  bd.findCentroids();
  point(bd.getCentroidX(0), bd.getCentroidY(0));
  fill(0,200,100);
  text("x-> " + bd.getCentroidX(0) + "\n" + "y-> " + bd.getCentroidY(0), bd.getCentroidX(0), bd.getCentroidY(0)-7);
  println("Blob 0 has centroid's coordinates at x:" 
              + bd.getCentroidX(0) 
              + " and y:" 
              + bd.getCentroidY(0)); 
              
  println(bd.version());
}
