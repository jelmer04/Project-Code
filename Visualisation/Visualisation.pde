import processing.serial.*;

Serial myPort;

int[] motion = new int[7];    //    ax, ay, az, gx, gy, gz, count


int[] jerk = {0, 0, 0};
int[] accel = {0, 0, 0};
int[] old = {0, 0, 0};
int[] velo = {0, 0, 0};
int[] displ = {0, 0, 0};

int[] gyro = {0, 0, 0};
int[] omega = {0, 0, 0};
int[] theta = {0, 0, 0};

void setup() {
  size(640, 480, P3D);
  println(Serial.list());
  
  myPort = new Serial(this, Serial.list()[4], 38400);
  myPort.bufferUntil('\n');
}

void draw() {
  
  background(150);
  
  pushMatrix();
  
  noFill();
  
  position(new int[3], 1);
    
  box(100);
  
  popMatrix();
  
  
  pushMatrix();
  
  fill(255, 0, 0, 100);
  
  position(old, 100);
    
  box(100);
  
  popMatrix();
  
  
  pushMatrix();
  
  fill(255, 0, 0, 100);
  
  position(accel, 100);
    
  box(100);
  
  popMatrix();
  
  
  pushMatrix();
  
  fill(0, 255, 0, 100);
  
  position(velo, 100);
    
  box(100);
  
  popMatrix();
  
 
  pushMatrix();
  
  fill(0, 0, 255, 100);
  
  position(displ, 1000);
    
  box(100);
  
  popMatrix();
  

}

void serialEvent (Serial myPort) {
  
  String inString = myPort.readStringUntil('\n');
  
  //println(inString);
  
  String[] split = splitTokens(inString, ", ");
  
  if (split.length == 7) {
  for (int i = 0; i < 7; i++)
  {
    print(split[i]);
    print('\t');
    motion[i] = int(split[i]);
  }
  
  for (int i = 0; i < 3; i++) {
    
    jerk[i] = (-old[i] + motion[i]);
    old[i] = motion[i];
    accel[i] += jerk[i];
    //accel[i] = motion[i];
    velo[i] += accel[i];
    displ[i] += velo[i];
    
    gyro[i] = motion[i+3];
    omega[i] += gyro[i];
    theta[i] += omega[i];

  }
  print('\n');
  }
  
}

void mouseClicked() {
  for (int i = 0; i < 3; i++) {
    jerk[i] = 0;
    accel[i] = 0;
    velo[i] = 0;
    displ[i] = 0;
    
    gyro[i] = 0;
    omega[i] = 0;
    theta[i] = 0;
  }
}

int position(int[] data, int scalar, int mode) {
  int output = 0;
  switch (mode) {
    case 0:
    output = (width/2 + (data[0]/scalar));
    break;
    case 1:
    output = (height/2 + (data[1]/scalar));
    break;
    case 2:
    output = (-200 + (data[2]/scalar));
    break;
    default:
    translate(position(data,scalar,0), position(data,scalar,1), position(data,scalar,2));
    rotateXYZ(theta,32768*PI*2);
  }
  return output;
}

void position(int[] data, int scalar) {
  position(data, scalar, 4);
}

void rotateXYZ(int[] data, float scalar) {
  rotateX(data[0]/scalar);
  rotateY(data[1]/scalar);
  rotateZ(data[2]/scalar);
}
