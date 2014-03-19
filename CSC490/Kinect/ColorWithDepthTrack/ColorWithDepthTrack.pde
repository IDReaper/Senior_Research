import SimpleOpenNI.*;
SimpleOpenNI kinect;
// Frame
PImage currentFrame;
color trackColor;
int[] distXY = new int[4];
int[] mid1 = new int[2];
int [] mid2 = new int[2];
int [] averageDepth = new int[307200];



void setup()
{
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableRGB();
  kinect.enableDepth();

  trackColor = color (255, 0, 0);
  smooth ();

  currentFrame = createImage (640, 480, RGB);
  String[] stuff = loadStrings("C:/Users/Shawn/Documents/GitHub/Test_Repo/CSC490/Kinect/StaticEnv/avgDepthData.txt");
  averageDepth = int(split(stuff[0],' '));
  
}

void draw()
{
  background(color(0,0,0));
  kinect.update();
  int[]   depthMap = kinect.depthMap();
  currentFrame = kinect.rgbImage ();
  image(currentFrame, 0, 0);

  currentFrame.loadPixels();

  // Before we begin searching, the "world record" for closest color is set to a high number that is easy for the first pixel to beat.
  float worldRecord = 500;

  // XY coordinate of closest color
  int closestX = 0;
  int closestY = 0;

  // Begin loop to walk through every pixel
  for (int x = 0; x < currentFrame.width; x ++ ) {
    for (int y = 0; y < currentFrame.height; y ++ ) {
      int loc = x + y*currentFrame.width;
      // What is current color
      color currentColor = currentFrame.pixels[loc];
      //color currentColor = color(0, 0, 255);
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);
      
      //trackColor = color(53, 78, 139); //blue ball
      trackColor = color(155,15,15); //orange reflectors
      // Using euclidean distance to compare colors
      float d = dist(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.

      // If current color is more similar to tracked color than
      // closest color, save current location and current difference
      if (d < worldRecord) {
        worldRecord = d;
        closestX = x;
        closestY = y;
      }
    }
  }

  // We only consider the color found if its color distance is less than 10.
  // This threshold of 10 is arbitrary and you can adjust this number depending on how accurate you require the tracking to be.
  if (worldRecord < 10) {
    // Draw a circle at the tracked pixel
    fill(trackColor);
    strokeWeight(4.0);
    stroke(0);
    //ellipse(closestX, closestY, 16, 16);
    int dist = sqDist(distXY[0],distXY[1],closestX,closestY);
    if (distXY[0] == 0 && distXY[1] == 0){
      distXY[0] = closestX;
      distXY[1] = closestY;  
    }
    if (dist > 25000 && dist < 75000){
      distXY[2] = closestX;
      distXY[3] = closestY;
    }
    else{
      distXY[0] = closestX;
      distXY[1] = closestY; 
    }
    int loc = mid1[0]+mid1[1]*currentFrame.width;
    if (depthMap[loc]-averageDepth[loc]>-100 && depthMap[loc]-averageDepth[loc]<100){
          ellipse(distXY[0],distXY[1], 16, 16);
          ellipse(distXY[2],distXY[3], 10, 10);
    }
    else {
          println("failed to draw");
    }
    //ellipse(distXY[0],distXY[1], 16, 16);
    //ellipse(distXY[2],distXY[3], 10, 10);
    if (mid1[0] == 0){
      mid1 = midP(distXY[0],distXY[1],distXY[2],distXY[3]);
    }
    else{
      mid2 = midP(distXY[0],distXY[1],distXY[2],distXY[3]);
    }
    dist = int(dist(mid1[0],mid1[1],mid2[0],mid2[1]));
    if (dist < 100){
      mid1[0] = mid2[0];
      mid1[1] = mid2[1];
    }
    
    //ellipse(mid1[0],mid1[1], 16, 16);
  }
  
}

void mousePressed() {
    
  color c = get(mouseX, mouseY);
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY*(currentFrame.width);
  println (loc);

  trackColor = currentFrame.pixels[loc];
  
}

int sqDist(int x1, int y1, int x2, int y2){
   int dist = int(pow((x2-x1),2)+pow((y2-y1),2));
   return dist;
}

int [] midP(int x1, int y1, int x2, int y2){
   int midX = int((x2+x1)/2);
   int midY = int((y2+y1)/2);
   int [] mid = {midX,midY};
   return mid;
}

