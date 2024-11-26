# Pendulum Scanner

The idea of the pendulum scanner is the following:
Attach a photodiode pointing downwards to a pendulum.
Track the pendulum motion using a [GameTrack](https://en.wikipedia.org/wiki/Gametrak) Playstation 2 controller.
Read the controllers valus using a RP2040 microcontroller together with the photodiode.
Assemble everything back to an image using a processing sketch.

You find the code for the RP2040 in the `firmware` folder and the processing sketch in the `GUI` folder.

The firmware does nothing more than reading the sensor values and printing them to the serial port.

The GUI reads the sensor readings from the serial port and places pixels on the canvas according to the sensor readings.

There is also a calibration mode to record pairs of sensor readings and angles to determine the mapping from sensor readings to angles. The `axis_identification.ipynb` notebook contains the code to determine the mapping using least-squares fitting.
However, even with calibration the angle readings are so inaccurate that the mapping can not be used for imaging.

## Result

The angle readings are not accurate enough to determine the position of the pendulum in 3D space or even 2D space.

## What does not work

Determining the cartesian 3D coordinates of the end of the string by using the standart transformation from polar to cartesian coordinates.
It just is a different mapping.

Therefore everything you find in calibration_math.ipynb is not working.

Mapping theta/phi to x/y by taking sin(theta) and sin(phi) is not working.

To determine the mapping from raw sensor values to angle, it might be tempting
to manually sweep the string and record the min/max values of the sensor.
However, there are some nonlinearities towards the end of the spectrum.
Better take lots of samples of pairs of known angle and measured sensor value and do a least squares fit (see axis_identification.ipynb for the least-squares fit and look at the calibration mode of the GUI for a helper to quickly collect those angle/measurement pairs).

## Future Work

Port most of [https://github.com/casiez/libgametrak](Libgametrak) to the RP2040 to get more accurate sensor readings through filtering and the correct quaternion math.