class Measurement
{
  String hour;
  String date;
  float SO2;
  float NO;
  float NO2;
  float CO;
  float PM25;
  float PM10;
  float O3;
  float BEN;

  Measurement( String hour, String date, int SO2, int NO, int NO2, float CO, int PM25, int PM10, int O3, int BEN)
  {
    this.hour = hour;
    this.date = date;
    this.SO2 = (float)SO2;
    this.NO = (float)NO;
    this.NO2 = (float)NO2;
    this.CO = CO;
    this.PM25 = (float)PM25;
    this.PM10 = (float)PM10;
    this.O3 = (float)O3;
    this.BEN = (float)BEN;
  }

  // printData()
  void printData()
  {
    println( hour + " " + date);
    println( "SO2: " + SO2 + " NO: " + NO + " NO2: " + NO2 + " CO: " + CO + " PM25: " + PM25 + " PM10: " + PM10 + " O3: " + O3 + " BEN: " + BEN);
  }
}
