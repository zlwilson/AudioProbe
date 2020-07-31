/*
  MAX30105 Breakout from SparkFun Electronics

  Hardware Connections (Breakoutboard to Arduino):
  -5V = 5V (3.3V is allowed)
  -GND = GND
  -SDA = A4 (or SDA)
  -SCL = A5 (or SCL)
  -INT = Not connected
*/

#include <Wire.h>
#include "MAX30105.h"

MAX30105 particleSensor;
const int serialBufferMaxLength = 20;
int serialBuffer[serialBufferMaxLength] = {};

const int lowNote = 24; // c1
const int highNote = 108; // c8
int currentNote = 0;

void setup() {
  //initialize serial communications at MIDI baud rate
  Serial.begin(31250);
  randomSeed(analogRead(0));

  // Initialize sensor
  if (particleSensor.begin() == false) {
    Serial.println("MAX30105 was not found. Please check wiring/power. ");
    while (1);
  }

  particleSensor.setup(); //Configure sensor. Use 6.4mA for LED drive
}

void loop() {
  if (particleSensor.getIR() > 8000) {
    // sensor is tapped, play note
    noteOn(currentNote, 0x45); // play current note at middle velocity
  } else {
    noteOff();
    append(serialBuffer, particleSensor.getIR());
    // check variance, see if shaken
    if (getVariance(serialBuffer) > 300) {
      shaken();
    }
  }
  delay(100);
}

// randomly choose a new MIDI note
void shaken() {
  currentNote = random(lowNote,highNote);
}

// append newest readings from sensor to array
void append(int myArray[], int val) {
  if (sizeof(myArray)/4 >= serialBufferMaxLength) {
    for (int i = 1; i < serialBufferMaxLength; i++) {
      myArray[i - 1] = myArray[i];
    }
    myArray[serialBufferMaxLength] = val;
  } else {
    myArray[sizeof(myArray)/4] = val;
  }
}

// play a MIDI note
void noteOn(int pitch, int velocity) {
  int cmd = 0x90; // play note on channel 1
  Serial.write(cmd);
  Serial.write(pitch);
  Serial.write(velocity);
}

// turn MIDI note off
void noteOff() {
  noteOn(currentNote, 0x00);
}

// calculate variance of int array
int getVariance(int myArray[]) {
  int mean = getMean(myArray);
  int variance = 0;
  for (int i = 0; i < sizeof(myArray) / 4; i++) {
    variance += (myArray[i] - mean) * (myArray[i] - mean);
  }
  variance = variance / (serialBufferMaxLength - 1);
  return variance;
}

// calculate mean of int array
int getMean(int myArray[]) {
  int sum = 0;
  int mean = 0;
  for (int i = 0; i < sizeof(myArray) / 4; i++) {
    sum += myArray[i];
  }
  mean = sum / serialBufferMaxLength;
  return mean;
}
