/* --------------------------------------------------------------------------
 * SimpleOpenNI DepthImage Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import blobscanner.*;

Detector bd;

PImage img,img1;
PFont f = createFont("", 10);

SimpleOpenNI  context;

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
  context.setMirror(true);

  // enable depthMap generation 
  context.enableDepth();
  context.enableRGB();
}

void draw()
{
  // update the cam
  context.update();

  background(200, 0, 0);
  img = context.depthImage();
  img1 = context.rgbImage();
  textFont(f, 10);

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

