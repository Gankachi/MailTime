  import processing.serial.*;
  import controlP5.*;

  Serial myPort;
  ControlP5 controller;
  Chart sensorChart;
  Textlabel stateLabel;
  Textlabel state;
  Textarea debug;
  Textlabel title;
  
  int light; // Light sensor value
  
  void setup () {
    size(800, 400);
  
    // In my case, the arduino is on my second COM channel; you may need to change this value
    myPort = new Serial(this, Serial.list()[1], 9600);

    // Commands are separated with newlines
    myPort.bufferUntil('\n');
    
    // Setting up ControlP5
    controller = new ControlP5(this);
    controller.setColorBackground(color(0)) 
              .setColorForeground(color(0,255,0));
    
    sensorChart = controller.addChart("dataflow")
                            .setPosition(10, 188)
                            .setSize(780, 190)
                            .setRange(-2, 50)  // A small negative zone is added for graphics
                            .setView(Chart.LINE) 
                            .setStrokeWeight(1.5)
                            .setLabel("Light Sensor")
                            ;
    sensorChart.addDataSet("sensor");
    sensorChart.setData("sensor", new float[100]);
    
    stateLabel = controller.addTextlabel("sensorLabel")
                           .setText("State:")
                           .setPosition(10,30)
                           .setColorValue(color(255))
                           ;
    
    state = controller.addTextlabel("state")
                      .setText("Unknown")
                      .setPosition(50,30)
                      .setColorValue(color(255))
                      ;
                      
    debug = controller.addTextarea("debug")
                      .setPosition(640,10)
                      .setSize(150,190)
                      .setText("")
                      .setScrollActive(color(255));
                      
    title = controller.addTextlabel("title")
                      .setPosition(350,10)
                      .setSize(10,10)
                      .setText("Mail~Time")
                      .setFont(createFont("Consolas",20));
   
  }

  void draw () {
   background(0);
   
   // push: add data from right to left (last in)
   sensorChart.push("sensor", light);
  }

  void updateSensor(String value){
      light = int(trim(value));
      
  }
  
  void updateState(String value){
    value  = trim(value);
    if(value.equals("New Mail")){
      println("New mail!");
      state.setText(value)
           .setColorValue(color(255,36,50));
    } else if(value.equals("No Mail")){
      state.setText(value)
           .setColorValue(color(94,255,97));
    } else {
      state.setText("Unknown")
           .setColorValue(color(255));
    }
  }

  void updateDebug(String value){
     debug.setText(debug.getText()+value);
  }
  
  void serialEvent (Serial myPort) {
    try{
    // get the ASCII string:
    String inString = myPort.readStringUntil('\n');
    if (inString != null) {
      //Sending data to debug
      updateDebug(inString);
      // trim off any whitespace:
      String[] data = split(inString,":");
      if(data[0].equals("Sensor")){
        updateSensor(data[1]);
      } else if(data[0].equals("State")){
        updateState(data[1]);
      } else {
        println("Unrecognized command : '"+data[0]+"'");
      }
    }
    } catch(Exception e){
      println("Exception : "+e.getMessage());
    }
  }