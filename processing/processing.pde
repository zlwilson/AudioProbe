import processing.serial.*;
import java.util.Random;
import processing.sound.*;

int sensorMax = 8000;
PImage img;
SoundFile file;
SoundSample[] samples;
Serial myPort;
String val;
IntList serialBuffer;
int serialBufferMaxLength = 20;
IntList varianceBuffer;
int varianceBufferMaxLength = 20;
int numberOfSamples = 36;
int sampleID;
IntDict inventory;
boolean firstContact = false;

int arduinoPort = 4; // Change this number to match your Arduino's serial port

void setup() {
  size(200, 200);
  background(255);
  img = loadImage("play.png");
  serialBuffer = new IntList();
  varianceBuffer = new IntList();
  samples = new SoundSample[70];
  sampleID = 0;
  inventory = new IntDict(); 
  setupInventory();

  for (int i = 0; i < numberOfSamples; i++) {
    int location = inventory.get("sample" + i);
    samples[location] = new SoundSample("sample"+i, new SoundFile(this, "sample"+i+".wav"));
  }

  String portName = Serial.list()[arduinoPort];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  delay(1000);
}

void draw() {
  image(img, 0, 0);
  if (mousePressed == true) {
    myPort.write('1');
    String sampleName = "sample"+sampleID+".wav";
    samples[sampleID].file.play();
    println("Playing sample: "+sampleName);
    delay(1000);
    mousePressed = false;
  }
}

void serialEvent(Serial myPort) {
  try {
    val = myPort.readStringUntil('\n');
    if (val != null) {
      val = trim(val);
      if (firstContact == false) {
        if (val.equals("ping")) {
          myPort.clear();
          firstContact = true;
          myPort.write("A");
          println("contact");
        }
      } else {
        int v = Integer.parseInt(val);
        processSerial(v);
        delay(100);
        sampleID = processSerialBuffer(serialBuffer, sampleID);
        myPort.write("A");
      }
    }
  } 
  catch(RuntimeException e) {
    e.printStackTrace();
  }
}

void processSerial(int v) {
  // check if it maxes out then button click, else doappend
  if (v > sensorMax) {
    mousePressed = true;
  } else {
    doAppend(serialBuffer, v);
  }
}

int processSerialBuffer(IntList buffer, int oldID) {
  int sd = getStanDev(buffer);
  int newID = 1;

  if (sd > 400) {
    newID = getDifferent(oldID, 5);
    myPort.write('1'); // tell arduino to wait
  } else if (sd > 200) {
    newID = getDifferent(oldID, 3);
    myPort.write('1'); // tell arduino to wait
  } else if (sd > 100) {
    newID = getDifferent(oldID, 1);
    myPort.write('1'); // tell arduino to wait
  } else {
    newID = oldID;
  }
  return newID;
}

void doAppend(IntList buffer, int i) {
  if (buffer.size() < serialBufferMaxLength) {
    buffer.append(i);
  } else {
    buffer.reverse();
    buffer.remove(buffer.size()-1);
    buffer.reverse();
    buffer.append(i);
  }
}

int getMean(IntList buffer) {
  int sum = 0;
  int variance = 0;
  for (int a : buffer) {
    sum += a;
  }
  variance = sum / buffer.size();
  return variance;
}

int getVariance(IntList buffer) {
  int mean = getMean(buffer);
  int variance = 0;
  for (int a : buffer) {
    variance += (a-mean)*(a-mean);
  }
  variance = variance / buffer.size()-1;
  doAppend(varianceBuffer, variance);
  return variance;
}

int getStanDev(IntList buffer) {
  int sd = (int) Math.sqrt(getVariance(buffer));
  return sd;
}

int getDifferent(int sampleID, int range) {
  int bound = 5;
  int newID = 0;
  int x = samples[sampleID].x; // old x value
  int y = samples[sampleID].y; // old y value
  int plusOrMinus = new Random().nextBoolean() ? 1 : -1;
  x = x + (new Random().nextInt(range) * plusOrMinus);
  plusOrMinus = new Random().nextBoolean() ? 1 : -1;
  y = y + (new Random().nextInt(range) * plusOrMinus);
  if (x < 0) {
    x = bound + x;
  } else if (x >= bound) {
    x = x % bound;
  }
  if (y < 0) {
    y = bound + y;
  } else if (y >= bound) {
    y = y % bound;
  }
  newID = x*10 + y;
  return newID;
}



void setupInventory() {
  inventory.set("sample0", 00);
  inventory.set("sample1", 55);
  inventory.set("sample2", 50);
  inventory.set("sample3", 5);
  inventory.set("sample4", 1);
  inventory.set("sample5", 2);
  inventory.set("sample6", 3);
  inventory.set("sample7", 4);
  inventory.set("sample8", 10);
  inventory.set("sample9", 11);
  inventory.set("sample10", 12);
  inventory.set("sample11", 13);
  inventory.set("sample12", 14);
  inventory.set("sample13", 15);
  inventory.set("sample14", 20);
  inventory.set("sample15", 21);
  inventory.set("sample16", 22);
  inventory.set("sample17", 23);
  inventory.set("sample18", 24);
  inventory.set("sample19", 25);
  inventory.set("sample20", 30);
  inventory.set("sample21", 31);
  inventory.set("sample22", 32);
  inventory.set("sample23", 33);
  inventory.set("sample24", 34);
  inventory.set("sample25", 35);
  inventory.set("sample26", 40);
  inventory.set("sample27", 41);
  inventory.set("sample28", 42);
  inventory.set("sample29", 43);
  inventory.set("sample30", 44);
  inventory.set("sample31", 45);
  inventory.set("sample32", 51);
  inventory.set("sample33", 52);
  inventory.set("sample34", 53);
  inventory.set("sample35", 54);
}

class SoundSample {
  String name;
  int x, y;
  SoundFile file;
  SoundSample(String n, SoundFile f) {
    name = n;
    file = f;
    setProps(this);
  }
  void setProps(SoundSample s) { // tens = x value, ones = y value
    int i = inventory.get(s.name);
    s.y = i % 10;
    s.x = i / 10;
  }
}
