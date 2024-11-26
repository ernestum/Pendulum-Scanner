Table calibration_table;
float x_offset, y_offset;
float reference_angle = 0;

float min_brightness = 100000;
float max_brightness = 0;

float axisToCalibrate() {
  return phi;  // change this to theta if you want to calibrate the other axis
}

float estimatedAngleToCalibrate() {
  return phiRadians();  // change this to thetaRadians if you want to calibrate the other axis
}

// Determined by a least squares of calibration data
float fit_m_theta = -0.0002478156;
float fit_c_theta = 0.5547055134;
float fit_m_phi = -0.0002750557;
float fit_c_phi = 0.6048611663;

float thetaRadians() {
  return theta * fit_m_theta + fit_c_theta;
}

float phiRadians() {
  return phi * fit_m_phi + fit_c_phi;
}

void drawCalibrationInterface() {
  while (readSensorValues()) { // Ensure we have the newest sensor values
    min_brightness = min(light, min_brightness);
    max_brightness = max(light, max_brightness);
  }

  background(255);  // white background

  { // Print the reference angle and estiated angle
    textSize(50);
    text("angle: " + degrees(reference_angle), 50, 50);
    text("measured angle: " + degrees(estimatedAngleToCalibrate()), 50, 100);
    text("min brightness: " + min_brightness, 50, 150);
    text("max brightness: " + max_brightness, 50, 200);
  }

  {
    pushMatrix();
    translate(x_offset, y_offset);
    rotate(-PI/2);

    // Draw origin marker
    fill(0);
    ellipseMode(CENTER);
    ellipse(0, 0, 30, 30);


    { // Draw reference angle as line
      pushMatrix();
      rotate(reference_angle);
      stroke(0);
      strokeWeight(2);
      line(0, 0, width, 0);
      popMatrix();
    }


    { // Draw estimation angle as line
      pushMatrix();
      rotate(estimatedAngleToCalibrate());
      stroke(255, 0, 0);
      line(0, 0, width, 0);
      popMatrix();
    }

    popMatrix();
  }

  { // Draw a simple plot of calibration data in the bottom left corner
    pushMatrix();
    translate(50, height - 50);
    plotCalibrationPoints(500, 400);
    popMatrix();
  }

  if (mousePressed) {
    reference_angle = atan2(mouseY - y_offset, mouseX - x_offset) + PI/2;  // when mouse is pressed, make reference angle line go through mouse
    if (keyPressed && key == 'r') {  // if R is pressed at the same time, also record a calibration point. very usful if you have a touch screen
      recordCalibrationPoint();
    }
  }
}

void recordCalibrationPoint() {
  TableRow row = calibration_table.addRow();
  row.setFloat("measured", axisToCalibrate());
  row.setFloat("actual", reference_angle);
  saveTable(calibration_table, "data/calib_.csv");
}

void keyPressed() {
  if (calibration_mode) {
    if (key == CODED) {
      if (keyCode == RIGHT) x_offset += 10;
      if (keyCode == LEFT) x_offset -= 10;
      if (keyCode == UP) y_offset -= 10;
      if (keyCode == DOWN) y_offset += 10;
    }
    if (key == TAB) {
      reference_angle += PI/100;
      if (reference_angle > PI/2) reference_angle = -PI/2;
    }
    if (key == ENTER || key == RETURN) {
      recordCalibrationPoint();
    }
    if (key == 'b') {
      min_brightness = 100000;
      max_brightness = 0;
    }
  }
  if (key == 'c') {
    calibration_mode = !calibration_mode;
    background(255);
  }
}

void plotCalibrationPoints(float w, float h) {
  pushMatrix();

  scale(1, -1); // y axis goes up now

  stroke(50);
  strokeWeight(1);
  noFill();

  { // draw scatter points
    beginShape(POINTS);
    for (TableRow row : calibration_table.rows()) {
      float x = map(row.getFloat("actual"), -PI/2, PI/2, 0, w);
      float y = map(row.getFloat("measured"), 0, 4096, 0, h);
      vertex(x, y);
    }
    endShape();
  }

  { // draw axes
    stroke(100, 100, 100, 100);
    line(0, 0, w, 0);
    line(0, 0, 0, h);
  }
  popMatrix();
}
