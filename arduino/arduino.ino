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

char val; // data from Processing

#define debug Serial //Uncomment this line if you're using an Uno or ESP
//#define debug SerialUSB //Uncomment this line if you're using a SAMD21

void setup() {
  //initialize serial communications at a 9600 baud rate
  Serial.begin(9600);
  establishContact();

  // Initialize sensor
  if (particleSensor.begin() == false) {
    debug.println("MAX30105 was not found. Please check wiring/power. ");
    while (1);
  }

  particleSensor.setup(); //Configure sensor. Use 6.4mA for LED drive
}

void loop() {
  if (Serial.available() > 0) { // If data is available from Processing
    val = Serial.read(); // read and store
    if (val == '1') { // Processing is calling for delay
      delay(1000);
    }
    delay(10);
  } else {
    Serial.println(particleSensor.getIR());
    delay(100);
  }
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("ping");
    delay(300);
  }
}
