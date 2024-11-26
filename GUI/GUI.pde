/*
This sketch reads lines from the serial port
 
 Before first running: set serial port in setup()
 
 Usage:
 Delete/Backspace: clear screen
 
 c: toggle calibration mode
 Enter/Return: save calibration point
 arrow keys: move origin of calibration line
 Tab: rotate calibration line clockwise
 
 To record calibration points to csv file:
 1. Place the GameTrack such that the rotation axis is roughly in front of the bottom middle of the screen (use large screen or projector, best: large touchscreen)
 2. Start sketch and go into calibration mode (press C)
 3. Align the origin of the reference line with the rotation origin of the GameTrack by moving it using the arrow keys
 4. Record calibration points at different angles:
   - Pull string out of GameTrack and align it with the (black) reference line
   - Hit enter to record a raw measurement/actual angle pair
   - Move around the reference line by
     - Pressing TAB
     - Clicking somewhere
  - Pro tip if you have a large touchscreen: hold "R" pressed and press the string from the GameTrack against the screen on different points. This will place the reference line AND record a calibration point. QUICKKK!
  
To change the axis to calibrate edit the code in the Calibration tab according to the instrucitons at the top.
 */

import processing.serial.*;

Serial port;

PImage image;

float phi, theta, w, light;
boolean calibration_mode = false;

void setup() {
  fullScreen();  // Note: also works without fullscreen
  port = new Serial(this, "/dev/ttyACM0", 9600);  // Change to the port on your machine
  background(255);  // Start with a blank screen
  
  image = createImage(4096, 4096, RGB);
  

  // Setup for calibration mode
  x_offset = width/2;
  y_offset = height-20;
  calibration_table = new Table();
  calibration_table.addColumn("measured");
  calibration_table.addColumn("actual");
}

void draw() {
  if (calibration_mode) {
    drawCalibrationInterface();
  } else {
    if (keyPressed && (key == DELETE || key == BACKSPACE)) {
      image.loadPixels();
      for(int i = 0; i < image.pixels.length; i++) image.pixels[i] = color(255);
      image.updatePixels();
    }
    drawDotsForSensorValues();
    
    if(keyPressed && key == 's') {
      image.save("image-" + frameCount + ".png");
    }
  }
}

// Read sensor values from serial, place them in in phi/theta/w/light global variables. Returns true if new values were available
boolean readSensorValues() {
  String line = port.readStringUntil(10);
  if (line != null) {
    String[] parts = split(line, " ");
    if (parts.length != 4) return false;
    phi = float(parts[0]);
    theta = float(parts[1]);
    w = float(parts[2]);
    light = float(parts[3]);
    return true;
  }
  return false;
}

// Place a pixel according to angle/brightness readings from sensors. No calibration is used here since calibration does not help anyway
void drawDotsForSensorValues() {
  image.loadPixels();
  while (readSensorValues()) {
    //int x = int(map(theta, 0, 4096, width/2.-height/2., width/2.+height/2.));
    //int y = int(map(phi, 0, 4096, 0, height));
    //int x = int(map(thetaRadians(), -radians(30), radians(30), width/2.-height/2., width/2.+height/2.));
    //int y = int(map(phiRadians(), -radians(30), radians(30), 0, height));
    int x = int(theta);
    int y = int(phi);
    float brightness = map(light, 50, 300, 0, 255);
    image.pixels[y*4096+x] = color(brightness);
  }
  image.updatePixels();
  imageMode(CENTER);
  image(image, width/2, height/2, height, height);
}
