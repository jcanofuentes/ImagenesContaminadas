import de.looksgood.ani.*;

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

float duration = 0.1f; 

void setup ()
{
  size( 600, 400 );

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
}

void loadReport(String fileName)
{
  Report r = new Report();
  r.loadFromXLS(this, fileName);
  reports.add(r);
}

void draw()
{
  //println(" SO2: " + SO2);
}

void aniStart() {
  //println("aniStart");
}

void aniEnd() {
  // Move index
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
  }
  println("Reading from... " + reports.get(currentReport).stationName + "" + m.date + " " + m.hour);

  Ani.to(this, duration, "SO2", m.SO2, Ani.LINEAR);
  Ani.to(this, duration, "NO", m.NO, Ani.LINEAR);
  Ani.to(this, duration, "NO2", m.NO2, Ani.LINEAR);
  Ani.to(this, duration, "CO", m.CO, Ani.LINEAR);
  Ani.to(this, duration, "PM25", m.PM25, Ani.LINEAR);
  Ani.to(this, duration, "PM10", m.PM10, Ani.LINEAR);
  Ani.to(this, duration, "O3", m.O3, Ani.LINEAR);
  Ani.to(this, duration, "BEN", m.BEN, Ani.LINEAR, "onStart:aniStart, onEnd:aniEnd");
}