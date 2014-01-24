import SimpleOpenNI.*;

SimpleOpenNI context;

void setup()
{
  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // disable mirror
  context.setMirror(false);

  // enable depthMap generation 
  context.enableDepth();

  int i = 0;
  while (i<10) {
    context.update();
    println(context.depthHeight());
    println(context.depthWidth());
  }
}

