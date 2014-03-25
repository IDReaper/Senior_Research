import hypermedia.video.*;
import java.awt.*;
import SimpleOpenNI.*;



OpenCV opencv;

int w = 640;
int h = 480;
int threshold = 80;
int [] IDX = new int [2]
int idxChoice = 0;
Point mouse;

Point centroid;
Point[] points;

boolean find=true;

PFont font;
PImage img;

color trackColor = color(162,4,28);

SimpleOpenNI  context;

void setup() {

    size(w*2+30, h*2+30);
    //size(w+30, h+30);
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
    opencv.capture(w,h);
    
    //font = loadFont( "AndaleMono.vlw" );
    font = createFont("",10); 
    textFont( font );

    println( "Drag mouse inside sketch window to change threshold" );
    println( "Press space bar to record background image" );

}



void draw() {
    //Update kinect, grab image, opencv.copy(img), remove opencv.read()
    background(0);
    context.update();
    PVector[] realWorldMap = context.depthMapRealWorld();
    img = context.rgbImage();
    opencv.copy(img);
    
    //opencv.flip( OpenCV.FLIP_HORIZONTAL );

    image( opencv.image(), 10, 10 );              // RGB image
    image( opencv.image(OpenCV.GRAY), 20+w, 10 );   // GRAY image
    image( opencv.image(OpenCV.MEMORY), 10, 20+h ); // image in memory

    opencv.absDiff();
    opencv.threshold(threshold);
    image( opencv.image(OpenCV.GRAY), 20+w, 10 ); // absolute difference image


    // working with blobs
    Blob[] blobs = opencv.blobs( 100, w*h/3, 20, true );

    noFill();

    pushMatrix();
    translate(20+w,10);
    
    for( int i=0; i<blobs.length; i++ ) {        
      
        centroid = blobs[i].centroid;
        points = blobs[i].points;
        
        float d = dist(centroid.x,centroid.y, mouse.x,mouse.y)
        if (d < 10)
          IDX[idxChoice] = i;
    }       
    
    // rectangle
    noFill();
    stroke( blobs[IDX[idxChoice]].isHole ? 128 : 64 );
    Rectangle bounding_rect  = blobs[ballIDX].rectangle;
    rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );

    // centroid
    centroid = blobs[IDX[idxChoice]].centroid;
    points = blobs[IDX[idxChoice]].points;
    
    stroke(0,0,255);
    line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
    line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
    noStroke();
    fill(0,0,255);
    int loc = centroid.x +centroid.y*opencv.image().width;
    String string = "("+nf(centroid.x,4)+","+nf(centroid.y,4)+","+nf(realWorldMap[loc].z,4,1)+")";
    text( string,centroid.x+5, centroid.y+5 );
    
    popMatrix();

}

void keyPressed() {
    if ( key==' ' ) opencv.remember();
    if ( key ==',') idxChoice = 0;
    if ( key =='.') idxChoice = 1;
}

void mouseDragged() {
    threshold = int( map(mouseX,0,width,0,255) );
}

void mousePressed() {
  mouse.x = mouseX;
  mouse.y = mouseY;
  
}


public void stop() {
    opencv.stop();
    super.stop();
}
