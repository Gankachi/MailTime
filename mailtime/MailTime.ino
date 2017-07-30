// Pins
int pButton = 12;
int pLaser = 2; // VCC of laser system : Laser && sensor
int pLed = 7;
int pSensor = 2;

// States
bool newMail = false;
bool bLock = false;
 



// Startup code
void setup(){
  pinMode(pButton,INPUT);
  pinMode(pSensor,INPUT);
  
  pinMode(pLaser,OUTPUT);
  pinMode(pLed,OUTPUT);

  digitalWrite(pLaser,HIGH);
  Serial.begin(9600);
}

// Functions
void reset(){ // Resetting after getting the mail
  digitalWrite(pLed,LOW);
  digitalWrite(pLaser,HIGH);  
  Serial.println("Reset!");
  newMail = false;
}

void notify(){ // New mail detected
  digitalWrite(pLed,HIGH);
  digitalWrite(pLaser,LOW);
  newMail = true;
  Serial.println("New Mail detected!");
}

bool isPressed(int button){
  bool output = false;
  if(digitalRead(button) == HIGH){ // Button is being pressed at this moment
    if(bLock == false){ // Button was not pressed last loop
      output = true;
    }
  } else { // The button is not being pressed at this moment
    if (bLock == true){  // If the lock is on, we can reset it
      bLock = false;
    }
  }
  return output; 
}
  


// Loop code
void loop(){
  if (!newMail){ // No new mail at the end of last loop
    int light = analogRead(pSensor);
    if(light > 500){ // Laser was cut!
      notify();
    }
  } else { // New mail already detected
    if(isPressed(pButton)){ // Someone reset the system
      reset();
    }
  }
}
