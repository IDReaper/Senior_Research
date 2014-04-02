import hypermedia.video.*;
import java.awt.*;
import SimpleOpenNI.*;



OpenCV opencv;

int w = 640;
int h = 480;
int threshold = 55;
int droneIDX;
int ballIDX=0;
int[] error_rgb =  {27,6,28};

Point centroid;
Point[] points;

boolean find=true;

PFont font;
PImage img;

color trackColor = color(227,12,56);

SimpleOpenNI  context;

void setup() {

    size(w*2+30, h+30);
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
    //image( opencv.image(OpenCV.GRAY), 20+w, 10 );   // GRAY image
    image( opencv.image(OpenCV.MEMORY), 10, 20+h ); // image in memory

    opencv.absDiff();
    opencv.threshold(threshold);
    image( opencv.image(OpenCV.GRAY), 20+w, 10 ); // absolute difference image


    // working with blobs
    Blob[] blobs = opencv.blobs( 1000, 15000, 20, true );

    noFill();

    pushMatrix();
    translate(20+w,10);
    
    for( int i=0; i<blobs.length; i++ ) {        
      
        centroid = blobs[i].centroid;
        points = blobs[i].points;
        
        // Color tracking for bloobs
        int loc = centroid.x +centroid.y*opencv.image().width;
        color currentColor = opencv.image().pixels[loc];
//        if (abs(red(currentColor) - red(trackColor)) <= error_rgb[0]){
//          if (abs(green(currentColor) - green(trackColor)) <= error_rgb[1]){
//            if (abs(blue(currentColor) - blue(trackColor)) <= error_rgb[2]){
//              ballIDX = i;    
//            }
//          } 
//        }
        if (red(currentColor) >= 200){
          if (green(currentColor) >= 50 && green(currentColor) <= 75){
            if (blue(currentColor) >= 50 && blue(currentColor) <= 75){
              ballIDX = i;
            }
          }
        }
    }       
    
        // rectangle
        noFill();
        println(ballIDX);
        stroke( blobs[ballIDX].isHole ? 128 : 64 );
        Rectangle bounding_rect  = blobs[ballIDX].rectangle;
        rect( bounding_rect.x, bounding_rect.y, bounding_rect.width, bounding_rect.height );
        println(threshold);

        // centroid
        
        float area = blobs[ballIDX].area;
        float circumference = blobs[ballIDX].length;
        centroid = blobs[ballIDX].centroid;
        points = blobs[ballIDX].points;
        int loc = centroid.x +centroid.y*opencv.image().width;
        float depth = realWorldMap[loc].z;
        
        stroke(0,0,255);
        line( centroid.x-5, centroid.y, centroid.x+5, centroid.y );
        line( centroid.x, centroid.y-5, centroid.x, centroid.y+5 );
        noStroke();
        fill(0,0,255);
        String string = "("+nf(centroid.x,4)+","+nf(centroid.y,4)+","+nf(depth,4,1)+")";
        text( string,centroid.x+5, centroid.y+5 );


        fill(255,0,255,64);
        stroke(255,0,255);
        if ( points.length>0 ) {
            beginShape();
            for( int j=0; j<points.length; j++ ) {
                vertex( points[j].x, points[j].y );
            }
            endShape(CLOSE);
        }

        noStroke();
        fill(255,0,255);
        //text( circumference, centroid.x+5, centroid.y+15 );

    
    popMatrix();

}

void keyPressed() {
    if ( key==' ' ) opencv.remember();
}

void mouseDragged() {
    threshold = int( map(mouseX,0,width,0,255) );
}

public void stop() {
    opencv.stop();
    super.stop();
}
