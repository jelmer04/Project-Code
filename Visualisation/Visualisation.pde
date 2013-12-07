import processing.serial.*;

Serial myPort;

int[] motion = new int[7];    //    ax, ay, az, gx, gy, gz, count

int[] jerk = {0, 0, 0};
int[] accel = {0, 0, 0};
int[] old = {0, 0, 0};
int[] velo = {0, 0, 0};
int[] displ = {0, 0, 0};

void setup() {
  size(640, 480, P3D);
  println(Serial.list());
  
  myPort = new Serial(this, Serial.list()[4], 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  
  background(150,150,150);
  
  position(accel, 10);
    
  box(100);

}

void serialEvent (Serial myPort) {
  
  String inString = myPort.readStringUntil('\n');
  
  println(inString);
  
  String[] split = splitTokens(inString, ", ");
  
  println(split.length + " values found");
  if (split.length == 7) {
  for (int i = 0; i < 7; i++)
  {
    print(split[i]);
    print('\t');
    motion[i] = int(split[i]);
  }
  
  for (int i = 0; i < 3; i++) {
    
    jerk[i] = old[i] - motion[i];
    old[i] = motion[i];
    accel[i] += jerk[i];
    velo[i] += accel[i];
    displ[i] += velo[i];
    
    print(displ[i]);
    print('\t');
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
  }
}

void position(int[] data, int scalar) {
    translate((width/2 + (data[0]/scalar)), (height/2 + (data[1]/scalar)), -500 + (data[2]/scalar));

}
