#define BAUD_RATE 230400
#define MILL_PIN  15

#include <Wire.h>
#include <Adafruit_GFX.h>
#include "Adafruit_LEDBackpack.h"

Adafruit_7segment matrix = Adafruit_7segment();

void setup() {
  // put your setup code here, to run once:
    Serial.begin(BAUD_RATE);
    pinMode(MILL_PIN, INPUT_PULLUP);
    matrix.begin(0x70);
    matrix.print(1200,DEC);
    matrix.writeDigitRaw(2,0x02 );
    matrix.writeDisplay();
} 

char hour[2];
char minutes[2];
char starthour[2];
char startmin[2];

int time;


int charToInt(char raw[]){
  int result;
  result = (raw[0]-'0')*10 + raw[1]-'0';
  //no light
  return result; 
  
}
int charTo12Int(char raw[]){
  int result;
  result = (raw[0]-'0')*10 + raw[1]-'0';
  if( result == 0){
    result = 12;
    // am light
      
  }else if(result > 12){
     result = result- 12;
     //pm light
    
  }
  return result; 
  
}


int firstrecieve =0;

int lastStateb1 = HIGH; // the previous state from the input pin
int currentStateb1;    // the current reading from the input pin
bool didpressb1 = false;
bool show12 = false;

void loop() {
  // put your main code here, to run repeatedly:

  currentStateb1 = digitalRead(MILL_PIN);
 

  if(lastStateb1 == LOW && currentStateb1 == HIGH && didpressb1 == false){
    didpressb1 = true; 
    
  }
  if (lastStateb1 == HIGH && currentStateb1 == LOW && didpressb1 == true){
      show12 = !show12;
  }
  
  // save the last state
  lastStateb1 = currentStateb1;


      
  if(Serial.available()){
     if( firstrecieve == 0){
        Serial.readBytes(hour,2);
        Serial.readBytes(minutes, 2);
        
        starthour[0] = hour[0];
        starthour[1] = hour[1];
        
       
        startmin[0] = minutes[0];
        startmin[1]= minutes[1];     
     }else{
       Serial.readBytes(hour,2);
       Serial.readBytes(minutes, 2);
     }

     if (show12){
         time = (charTo12Int(hour) * 100) + charToInt(minutes);
         Serial.println(time);
         matrix.print(time,DEC);

      
     }else{
         time = (charToInt(hour) * 100) + charToInt(minutes);
         Serial.println(time);
         matrix.print(time,DEC);
     }
      matrix.drawColon(true);
      matrix.writeDisplay();


    
  }

}
