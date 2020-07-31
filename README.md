# AudioProbe
Processing and Arduino code for a handheld audio sample explorer

## Setup Processing
The serial port has to be changed to match where the Arduino is sending information on your computer. To do this:

Find this line at the top of processing.pde
int arduinoPort = 4;

Change the 4 to whatever port number the Arduino is connected to.
(This is generally between 0 and 3, if you can't find the port number of the Arduino, start at 0 and see if you can run the sketch in Processing, then try 1, etc.)