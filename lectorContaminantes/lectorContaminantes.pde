//------------------------------------------------------------------------
// DESCRIPTION :
//      Read contaminants data from XLS data sheets and send measurements
//      through OSC to Resolume
//------------------------------------------------------------------------
// Import libraries
import de.looksgood.ani.*;
import oscP5.*;
import netP5.*;
import spout.*;
import themidibus.*;

// Managing reports and measurements
ArrayList <Report> reports = new ArrayList();
int currentReport = 0;
int currentMeasurement = 0;

// Values to be animated
float SO2 = -10.0f;
float NO = -10.0f;
float NO2 = -10.0f;
float CO = -10.0f;
float PM25 = -10.0f;
float PM10 = -10.0f;
float O3 = -10.0f;
float BEN = -10.0f;

boolean SO2_show = true;
boolean NO_show = true;
boolean NO2_show = true;
boolean CO_show = true;
boolean PM25_show = true;
boolean PM10_show = true;
boolean O3_show = true;
boolean BEN_show = true;

// Other
float duration = .5f; 
OscP5 oscP5;
NetAddress myRemoteLocation;
Spout spout;
PGraphics displayInfo;
MidiBus myBus;

//------------------------------------------------------------------------
// setup()
//------------------------------------------------------------------------
void setup ()
{
  size( 256, 256, P2D );

  // Init OSC
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 7000);

  println("----------------------------------------------------------------");
  println("Imagenes Contaminadas v1  - Oct 2018");
  println("----------------------------------------------------------------");

  loadReport("informeHorario_Argentina_20180923-044043.xls");
  loadReport("informeHorario_Argentina_20180923-044911.xls");
  loadReport("informeHorario_Cangas del Narcea_20180923-044528.xls");
  loadReport("informeHorario_Castilla_20180924-095636.xls");
  loadReport("informeHorario_Llano Ponte_20180924-095952.xls");
  loadReport("informeHorario_Matadero_20180923-043851.xls");
  loadReport("informeHorario_Matadero_20180923-044225.xls");
  loadReport("informeHorario_Montevil_20180923-044426.xls");
  loadReport("informeHorario_Salinas_20180923-043450.xls");

  println("All data loaded!");
  println("----------------------------------------------------------------");

  // Start animation
  Ani.init(this);
  println("Start reading from first report, the first measurement...");
  Measurement m = reports.get(currentReport).getMeasurement(currentMeasurement);
  //m.printData();
  println("Reading from... " + reports.get(currentReport).stationName + "" + m.date + " " + m.hour);

  Ani.to(this, duration, "SO2", m.SO2, Ani.LINEAR);
  Ani.to(this, duration, "NO", m.NO, Ani.LINEAR);
  Ani.to(this, duration, "NO2", m.NO2, Ani.LINEAR);
  Ani.to(this, duration, "CO", m.CO, Ani.LINEAR);
  Ani.to(this, duration, "PM25", m.PM25, Ani.LINEAR);
  Ani.to(this, duration, "PM10", m.PM10, Ani.LINEAR);
  Ani.to(this, duration, "O3", m.O3, Ani.LINEAR);
  Ani.to(this, duration, "BEN", m.BEN, Ani.LINEAR, "onStart:aniStart, onEnd:aniEnd");

  String message = "/track" + 1 + "/connect";
  OscMessage myMessage = new OscMessage(message);
  myMessage.add(1);
  oscP5.send(myMessage, myRemoteLocation);

  // PGraphics
  displayInfo = createGraphics(1280, 128);
  spout = new Spout(this);
  spout.createSender("IC_DisplayInfo");

  // MIDI
  myBus = new MidiBus(this, "LPD8", -1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}
//------------------------------------------------------------------------
// loadReport()
//------------------------------------------------------------------------
void loadReport(String fileName)
{
  Report r = new Report();
  r.loadFromXLS(this, fileName);
  reports.add(r);
}
//------------------------------------------------------------------------
// draw()
//------------------------------------------------------------------------
void draw()
{
  /*
   SO2   (dióxido de azufre):    0 - 125 mg/m3    FX: INVERT RGB / GREEN
   NO    (monóxido de azufre):   0 - 30 mg/m3     FX: SHIFT GLITCH
   NO2   (dióxido de azufre) :   0 - 40 mg/m3     FX: GOO
   CO    (monóxido de carbono) : 10 mg/m3.        FX: COLOR PASS
   PM25  (P. mater < 2.5 micras):0 - 25 μg/m3     FX: DISPLACE / Y (Centrado en 0.5)
   PM10  (P. mater < 10 micras): 0 - 50 lg/m3     FX: DISPLACE / X (Centrado en 0.5)
   BEN   (benzeno):              5 lg/m3          FX: INVERT RGB / RED
   O3    (Ozono):                100 μg/m3        FX: INVERT RGB / BLUE
   */

  // Invert RGB - Green
  float v1 = map( SO2, 0, 125, 0.0f, 1f );
  sendOSCValue(SO2, v1, "/layer1/video/effect1/param2/values");

  // Goo - MaxDistortionZ
  float v2 = map( NO, 0, 30, 0.0f, 1f );
  sendOSCValue(NO, v2, "/layer1/video/effect2/param4/values");

  // Shift glitch - Horizontal
  float v3 = map( NO2, 0, 40, 0.0f, 1f );
  sendOSCValue(NO2, v3, "/layer1/video/effect3/param3/values"); 

  // Colour pass - Hue 1
  float v4 = map( CO, 0, 10, 0.0f, 1f );
  sendOSCValue(CO, v4, "/layer1/video/effect4/opacity/values"); 

  // Displace - y factor
  float v5 = map( PM25, 0, 25, 0.45f, 0.55f );
  if ( PM25 == 0.0f || PM25 == 9999f )
  {
    OscMessage myMessage = new OscMessage("/layer1/video/effect5/param2/values");
    myMessage.add(random(0.45f, 0.55f));
    oscP5.send(myMessage, myRemoteLocation);
    //println("no data, get random value on displace y");
  } else {
    OscMessage myMessage = new OscMessage("/layer1/video/effect5/param2/values");
    myMessage.add(v5);
    oscP5.send(myMessage, myRemoteLocation);
  }

  // Displace - x factor
  float v6 = map( PM10, 0, 50, 0.45f, 0.55f );
  if ( PM10 == 0.0f || PM10 == 9999f )
  {
    OscMessage myMessage = new OscMessage("/layer1/video/effect8/param1/values");
    myMessage.add(random(0.45f, 0.55f));
    oscP5.send(myMessage, myRemoteLocation);
    //println("no data, get random value on displace x");
  } else {
    OscMessage myMessage = new OscMessage("/layer1/video/effect8/param1/values");
    myMessage.add(v6);
    oscP5.send(myMessage, myRemoteLocation);
  }

  // Invert RGB - Red
  float v7 = map( BEN, 0, 5, 0.0f, 1f );
  sendOSCValue(BEN, v7, "/layer1/video/effect6/param1/values"); 

  // Invert RGB - Blue
  float v8 = map( O3, 0, 100, 0.0f, 1f );
  sendOSCValue(O3, v8, "/layer1/video/effect7/param3/values");

  // Display info
  Measurement m = reports.get(currentReport).getMeasurement(currentMeasurement);
  String message = reports.get(currentReport).stationName + "      " + m.date + " " + m.hour + "h";

  displayInfo.beginDraw();
  displayInfo.background(0, 0);
  displayInfo.fill(0);
  displayInfo.rect(0, 0, 270, 32);
  displayInfo.fill(255);
  displayInfo.text(message, 10, 20);

  displayInfo.pushStyle();
  displayInfo.rectMode(CENTER);
  displayInfo.noStroke();

  int x = 265;
  String name = "SO2";
  String units = "(µg/m³)";
  contaminantInfo(  x, name, units, SO2, SO2_show );

  x = 366;
  name = "NO";
  units = "(µg/m³)";
  contaminantInfo(  x, name, units, NO, NO_show );

  x = 467;
  name = "NO2";
  units = "(µg/m³)";
  contaminantInfo(  x, name, units, NO2, NO2_show );

  x = 568;
  name = "CO";
  units = "(mg/m³)";
  contaminantInfo(  x, name, units, CO, CO_show );

  x = 669;
  name = "PM25";
  units = "(µg/m³)";
  contaminantInfo(  x, name, units, PM25, PM25_show );

  x = 770;
  name = "PM10";
  units = "(µg/m³)";
  contaminantInfo(  x, name, units, PM10, PM10_show );

  x = 871;
  name = "O3";
  units = "(µg/m³)";
  contaminantInfo(  x, name, units, O3, O3_show );

  x = 972;
  name = "BEN";
  units = "(µg/m³)";
  contaminantInfo(  x, name, units, BEN, BEN_show );

  displayInfo.popStyle();
  displayInfo.endDraw();

  image(displayInfo, 0, 0);

  spout.sendTexture(displayInfo);
}

//------------------------------------------------------------------------
// contaminantInfo()
//------------------------------------------------------------------------
void contaminantInfo( int x, String name, String units, float currentValue, boolean show )
{
  displayInfo.fill(0);
  displayInfo.rect(x, 64, 60, 70);
  displayInfo.fill(255);
  displayInfo.textAlign(CENTER, CENTER);
  displayInfo.textSize(14);
  displayInfo.text(name, x, 64 - 24);
  displayInfo.textSize(10);
  displayInfo.text(units, x, 64 - 10);

  if (currentValue == 0.0f || currentValue == 9999.0f)
  {
    displayInfo.text("NO DATA", x, 64 +10);
  } else {
    displayInfo.text(currentValue, x, 64 +10);
  }

  if (!show)
  {
    displayInfo.fill(0, 220);
    displayInfo.rect(x, 64, 60, 70);
  }
}

//------------------------------------------------------------------------
// keyPressed()
//------------------------------------------------------------------------
void keyPressed()
{
  switch(key) {
  default:
    int a = Character.getNumericValue(key);
    String message = "/track" + a + "/connect";
    OscMessage myMessage = new OscMessage(message);
    myMessage.add(1);
    oscP5.send(myMessage, myRemoteLocation);
    break;
  }
  if (key == ' ')
  {
  }
}

//------------------------------------------------------------------------
// Ani callbacks
//------------------------------------------------------------------------
void aniStart() {
}

void aniEnd() {
  // Move index / get next measurement
  currentMeasurement++;
  Measurement m = reports.get(currentReport).getMeasurement(currentMeasurement);
  if (m == null)
  {
    println("Load next report...");
    currentReport++;
    if (currentReport>=reports.size())
      currentReport=0;
    currentMeasurement = 0;
    m = reports.get(currentReport).getMeasurement(currentMeasurement);

    // Play current track inside Resolume
    String message = "/track" + (currentReport + 1) + "/connect";
    OscMessage myMessage = new OscMessage(message);
    myMessage.add(1);
    //oscP5.send(myMessage, myRemoteLocation);
  }

  Ani.to(this, duration, "SO2", m.SO2, Ani.LINEAR);
  Ani.to(this, duration, "NO", m.NO, Ani.LINEAR);
  Ani.to(this, duration, "NO2", m.NO2, Ani.LINEAR);
  Ani.to(this, duration, "CO", m.CO, Ani.LINEAR);
  Ani.to(this, duration, "PM25", m.PM25, Ani.LINEAR);
  Ani.to(this, duration, "PM10", m.PM10, Ani.LINEAR);
  Ani.to(this, duration, "O3", m.O3, Ani.LINEAR);
  Ani.to(this, duration, "BEN", m.BEN, Ani.LINEAR, "onStart:aniStart, onEnd:aniEnd");
}

//------------------------------------------------------------------------
// OSC and MIDI communication
//------------------------------------------------------------------------
void sendOSCValue( float value, float normalizedValue, String OSCMessage )
{
  if ( value == 0.0f || value == 9999f )
  {
    OscMessage myMessage = new OscMessage(OSCMessage);
    myMessage.add(random(0.0f, 1.0f));
    oscP5.send(myMessage, myRemoteLocation);
    //println("no data, get random value");
  } else {
    OscMessage myMessage = new OscMessage(OSCMessage);
    myMessage.add(normalizedValue);
    oscP5.send(myMessage, myRemoteLocation);
  }
}

void oscEvent(OscMessage theOscMessage) {
}

void noteOn(int channel, int pitch, int velocity) {
}

void noteOff(int channel, int pitch, int velocity) {
  if ( pitch == 40 )
  {
    NO2_show = !NO2_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect2/bypassed");
    myMessage.add(int(!NO2_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
  if ( pitch == 41 )
  {
    NO_show = !NO_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect3/bypassed");
    myMessage.add(int(!NO_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
  if ( pitch == 42 )
  {
    CO_show = !CO_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect4/bypassed");
    myMessage.add(int(!CO_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
  if ( pitch == 43 )
  {
    PM25_show = !PM25_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect5/bypassed");
    myMessage.add(int(!PM25_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
  if ( pitch == 36 )
  {
    BEN_show = !BEN_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect6/bypassed");
    myMessage.add(int(!BEN_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
  if ( pitch == 37 )
  {
    SO2_show = !SO2_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect1/bypassed");
    myMessage.add(int(!SO2_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
  if ( pitch == 38 )
  {
    O3_show = !O3_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect7/bypassed");
    myMessage.add(int(!O3_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
  if ( pitch == 39 )
  {
    PM10_show = !PM10_show;
    OscMessage myMessage = new OscMessage("/layer1/video/effect8/bypassed");
    myMessage.add(int(!PM10_show));
    oscP5.send(myMessage, myRemoteLocation);
  }
}

void controllerChange(int channel, int number, int value) {
}
