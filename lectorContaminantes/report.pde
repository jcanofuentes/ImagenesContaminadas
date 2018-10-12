import de.bezier.data.*;

class Report {
  PApplet parent = null;
  XlsReader xlsReader;

  // Data
  String stationName;
  ArrayList<Measurement> measurements = new ArrayList();

  void loadFromXLS(PApplet parent, String fileName)
  {
    println("Loading data from " + fileName );
    this.parent = parent;
    xlsReader = new XlsReader( parent, fileName );

    // Get station name
    xlsReader.firstRow();
    int index = 0;
    while (xlsReader.hasMoreCells())
    {
      String content = xlsReader.getString();
      if (content != "")
      {
        index++;
        if (index ==2)
        {
          stationName = content;
          break;
        }
      }
      xlsReader.nextCell();
    }
    println ("StationName: " + stationName);

    // Get data
    xlsReader.nextRow();
    xlsReader.nextRow();


    while ( xlsReader.hasMoreRows() )    // loop thru rows
    {
      xlsReader.nextRow();
      String hour = xlsReader.getString();
      xlsReader.nextCell();
      String date =  xlsReader.getString();

      xlsReader.nextCell();
      int SO2 =  xlsReader.getInt();
      xlsReader.nextCell(); 
      xlsReader.nextCell();   
      int NO =  xlsReader.getInt(); 
      xlsReader.nextCell(); 
      xlsReader.nextCell();   
      int NO2 =  xlsReader.getInt();    
      xlsReader.nextCell(); 
      xlsReader.nextCell();   
      float CO =  xlsReader.getFloat(); 

      xlsReader.nextCell(); 
      xlsReader.nextCell(); 
      int PM25 =  xlsReader.getInt(); 

      xlsReader.nextCell(); 
      xlsReader.nextCell(); 
      xlsReader.nextCell(); 
      int PM10 =  xlsReader.getInt(); 

      xlsReader.nextCell(); 
      xlsReader.nextCell(); 
      int O3 =  xlsReader.getInt(); 

      xlsReader.nextCell(); 
      xlsReader.nextCell(); 
      int BEN =  xlsReader.getInt(); 

      if (hour != "") {
        Measurement m = new Measurement( hour, date, SO2, NO, NO2, CO, PM25, PM10, O3, BEN);
        measurements.add(m);
        //m.printData();
      }
    }
    println("Number of measurements: " + measurements.size());
    println("Done!");
    println();
  }

  Measurement getMeasurement( int index )
  {
    if ( index < measurements.size() )
    {
      return measurements.get(index);
    } else {
      return null;
    }
  }
}
