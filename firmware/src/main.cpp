#include <Arduino.h>

const int lightPin = A0;
const int phiPin = A1;
const int thetaPin = A3;
const int wPin = A2;

void setup() {
    Serial.begin(9600);
    for(auto pin : {lightPin, phiPin, thetaPin, wPin}) {
        pinMode(pin, INPUT);
    }
    // Increase the resolution of the analogRead function to 12 bit (0-4095)
    analogReadResolution(12);
}

void loop() {
    // Send sensor values in the format "phi theta w light"
    for(auto pin : {phiPin, thetaPin, wPin}) {
        Serial.print(analogRead(pin));
        Serial.print(" ");
    }
    Serial.println(analogRead(lightPin));
    
    // Ensure we don't send too many values too quickly
    delayMicroseconds(100);
}
