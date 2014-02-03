import SimpleOpenNI.*;

SimpleOpenNI context;
PrintWriter output1;
PrintWriter output2;

void setup()
{
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  output1 = createWriter("allDepthData.txt");
  output2 = createWriter("avgDepthData.txt");
  
  context.enableDepth();
  
  println(context.depthHeight(),context.depthWidth());
  
  int[][] combinedDepth = new int[100][307200];
  for (int i = 0; i<100;i++) {
    context.update();
    int[]   depthMap = context.depthMap();
    combinedDepth[i] = depthMap;
  }
  for (int i = 0; i<100;i++){
     for (int x = 0; x<context.depthWidth()*context.depthHeight();x++){
       if (!(i == 307199))
         output1.print(combinedDepth[i][x] + " ");
       else
         output1.print(combinedDepth[i][x]);
     }
     output1.print("\n");
  }

  int[] averageDepth = new int[307200];
  for (int i = 0; i<100;i++){
    for (int x = 0; x<context.depthWidth()*context.depthHeight();x++){
      averageDepth[x]+=combinedDepth[i][x];
    }
  }
  for (int i = 0; i<context.depthWidth()*context.depthHeight();i++){
     averageDepth[i] /= 100;
     if (!(i == 307199))
       output2.print(averageDepth[i] + " ");
     else
       output2.print(averageDepth[i]);
  }
  output1.flush();
  output1.close();
  output2.flush();
  output2.close();
  exit();
  return;
}
