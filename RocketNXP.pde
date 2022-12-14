import processing.serial.*;
Serial myPort;

float yaw = 0.0;
float pitch = 0.0;
float roll = 0.0;
PImage img;

void setup()
{
  size(900, 900, P3D);
  // if you have only ONE serial port active
  myPort = new Serial(this, Serial.list()[0], 115200); // if you have only ONE serial port active
  // if you know the serial port name
  //myPort = new Serial(this, "COM6:", 9600);        // Windows "COM#:"
  //myPort = new Serial(this, "\\\\.\\COM41", 9600); // Windows, COM10 or higher
  //myPort = new Serial(this, "/dev/ttyACM0", 9600);   // Linux "/dev/ttyACM#"
  //myPort = new Serial(this, "/dev/cu.usbmodem1217321", 9600);  // Mac "/dev/cu.usbmodem######"
  textSize(16); // set text size
  textMode(SHAPE); // set text mode to shape
}

void draw()
{
  serialEvent();  // read and parse incoming serial message
  background(255); // set background to white
  lights();
  translate(width/2, height/2); // set position to centre
  pushMatrix(); // begin object
  float c1 = cos(radians(roll));
  float s1 = sin(radians(roll));
  float c2 = cos(radians(-pitch));
  float s2 = sin(radians(-pitch));
  float c3 = cos(radians(-yaw));
  float s3 = sin(radians(-yaw));
  applyMatrix( c2*c3, s1*s3+c1*c3*s2, c3*s1*s2-c1*s3, 0,
               -s2, c1*c2, c2*s1, 0,
               c2*s3, c1*s2*s3-c3*s1, c1*c3+s1*s2*s3, 0,
               0, 0, 0, 1);

  //drawPropShield();  //we are going to draw a rocket instead

  draw2();
  popMatrix(); // end of object
  //Print Values to the bottom of window
  text("ALTITUDE",-400,400);//heading
  text(" ROLL",-300,400);  //heading
  text(roll,-300,420);     //print variable  
  text(" PITCH",-200,400);
  text(pitch,-200,420);
  text(" YAW",-100,400);
  text(360-yaw,-100,420);
  
  // Print values to console
  print(roll);
  print("\t");
  print(-pitch);
  print("\t");
  print(360-yaw);
  println();
}


void draw2()
{
    background(0, 128, 255);
    lights();
    fill(255,0,0);
    rotateY(PI/2);
    pushMatrix();
    drawCylinder( 30, 50, 50, 500);
    popMatrix();
    pushMatrix();    
    translate( 0, 0, -325);
    fill(0);
    drawCylinder( 30, 0, 50, 150 );
    popMatrix();

beginShape();
//start rocket fin set
  fill(255,255,255);
  translate( 0, 0, 100 );
  rotateY(PI);
  //rotateZ(PI/3);
  vertex(-100, 0, -150);
  vertex( 100, 0, -150);
  vertex(   0,    0,  100);
endShape();

//start rocket fin set
  fill(0);
  translate( 0, 0, -150 );
  beginShape();
  vertex( 0, 100, 0);
  vertex( 0,  -100, 0);
  vertex(   0,    0,  250);
endShape();

}

void drawCylinder( int sides, float r1, float r2, float h)
{
    float angle = 360 / sides;
    float halfHeight = h / 2;

    // draw top of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r1;
        float y = sin( radians( i * angle ) ) * r1;
        vertex( x, y, -halfHeight);
    }
    endShape(CLOSE);

    // draw bottom of the tube
    beginShape();
    for (int i = 0; i < sides; i++) {
        float x = cos( radians( i * angle ) ) * r2;
        float y = sin( radians( i * angle ) ) * r2;
        vertex( x, y, halfHeight);
    }
    endShape(CLOSE);
    
    // draw sides
    beginShape(TRIANGLE_STRIP);
    stroke(180,0,0);
    for (int i = 0; i < sides + 1; i++) {
        float x1 = cos( radians( i * angle ) ) * r1;
        float y1 = sin( radians( i * angle ) ) * r1;
        float x2 = cos( radians( i * angle ) ) * r2;
        float y2 = sin( radians( i * angle ) ) * r2;
        vertex( x1, y1, -halfHeight);
        vertex( x2, y2, halfHeight);    
    }
    endShape(CLOSE);
}

void serialEvent()
{
  int newLine = 13; // new line character in ASCII
  String message;
  do {
    message = myPort.readStringUntil(newLine); // read from port until new line
    if (message != null) {
      String[] list = split(trim(message), " ");
      if (list.length >= 4 && list[0].equals("O:")) {  
        yaw = float(list[1]); // convert to float yaw
        pitch = float(list[2]); // convert to float pitch
        roll = float(list[3]); // convert to float roll
      }
    }
  } while (message != null);
}



void drawPropShield()   //not being used or displayed here
{
  // 3D art by Benjamin Rheinland
  stroke(0); // black outline
  fill(0, 128, 0); // fill color PCB green
  box(190, 6, 70); // PCB base shape

  fill(255, 215, 0); // gold color
  noStroke();

  //draw 14 contacts on Y- side
  translate(65, 0, 30);
  for (int i=0; i<14; i++) {
    sphere(4.5); // draw gold contacts
    translate(-10, 0, 0); // set new position
  }

  //draw 14 contacts on Y+ side
  translate(10, 0, -60);
  for (int i=0; i<14; i++) {
    sphere(4.5); // draw gold contacts
    translate(10, 0, 0); // set position
  }

  //draw 5 contacts on X+ side (DAC, 3v3, gnd)
  translate(-10,0,10);
  for (int i=0; i<5; i++) {
    sphere(4.5);
    translate(0,0,10);
  }

  //draw 4 contacts on X+ side (G C D 5)
  translate(25,0,-15);
  for (int i=0; i<4; i++) {
    sphere(4.5);
    translate(0,0,-10);
  }

  //draw 4 contacts on X- side (5V - + GND)
  translate(-180,0,10);
  for (int i=0; i<4; i++) {
    sphere(4.5);
    translate(0,0,10);
  }

  //draw audio amp IC
  stroke(128);
  fill(24);    //Epoxy color
  translate(30,-6,-25);
  box(13,6,13);

  //draw pressure sensor IC
  stroke(64);
  translate(32,0,0);
  fill(192);
  box(10,6,18);

  //draw gyroscope IC
  stroke(128);
  translate(27,0,0);
  fill(24);
  box(16,6,16);

  //draw flash memory IC
  translate(40,0,-15);
  box(20,6,20);

  //draw accelerometer/magnetometer IC
  translate(-5,0,25);
  box(12,6,12);

  //draw 5V level shifter ICs
  translate(42.5,2,0);
  box(6,4,8);
  translate(0,0,-20);
  box(6,4,8);
}