#include <Wire.h>
#include <ACROBOTIC_SSD1306.h>
#include "MAX30105.h"          
//#include "spo2_algorithm.h"
#include "MODIF_SPO2.h"
//#include "heartRate.h"
MAX30105 particleSensor;

uint16_t irBuffer[60]; //infrared LED sensor data
uint16_t redBuffer[60]; 
int32_t bufferLength; //data length
int32_t spo2; //SPO2 value
int8_t validSPO2; //indicator to show if the SPO2 calculation is valid

const byte RATE_SIZE = 4; //Increase this for more averaging. 4 is good.
byte rates[RATE_SIZE]; //Array of heart rates
byte rateSpot = 0;
long lastBeat = 0; //Time at which the last beat occurred
float beatsPerMinute;
int beatAvg;


byte pulseLED = 11; //Must be on PWM pin
byte readLED = 13; //Blinks with each data read

void setup()
{ Serial.begin(115200); // Baud Rate: 115200
  Wire.begin();	
  oled.init();                      // Initialze SSD1306 OLED display
  oled.clearDisplay();              // Clear screen
  oled.setTextXY(1,0);              // Set cursor position, start of line 1
  oled.putString(F("ZhangScope"));
  oled.setTextXY(5,0);
  oled.putString(F("initializing"));
  delay(5000);
  oled.clearDisplay();
  pinMode(pulseLED, OUTPUT);
  pinMode(readLED, OUTPUT);


  Serial.read();
  particleSensor.begin(Wire, I2C_SPEED_FAST);
  byte ledBrightness = 60; //Options: 0=Off to 255=50mA
  byte sampleAverage = 4; //Options: 1, 2, 4, 8, 16, 32
  byte ledMode = 2; //Options: 1 = Red only, 2 = Red + IR, 3 = Red + IR + Green
  byte sampleRate = 100; //Options: 50, 100, 200, 400, 800, 1000, 1600, 3200
  int pulseWidth = 411; //Options: 69, 118, 215, 411
  int adcRange = 4096; //Options: 2048, 4096, 8192, 16384
  particleSensor.begin(Wire, I2C_SPEED_FAST);
  particleSensor.setup(ledBrightness, sampleAverage, ledMode, sampleRate, pulseWidth, adcRange); //Configure sensor with these settings
  bufferLength = 100; //buffer length of 100 stores 4 seconds of samples running at 25sps
  for (byte i = 0 ; i < bufferLength ; i++){
    while (particleSensor.available() == false) //do we have new data?
      particleSensor.check(); //Check the sensor for new data

    redBuffer[i] = particleSensor.getRed();
    irBuffer[i] = particleSensor.getIR();
    particleSensor.nextSample(); //We're finished with this sample so move to next sample
  }
  maxim_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2); 
  
}
void loop(){  

    
  for (byte i = 30; i < 60; i++)
    {
      redBuffer[i - 30] = redBuffer[i];
      irBuffer[i - 30] = irBuffer[i];
    }
       
  long delta = millis() - lastBeat;                   //Measure duration between two beats
  lastBeat = millis();

  beatsPerMinute = 60 / (delta / 1000.0);           //Calculating the BPM

  if (beatsPerMinute < 255 && beatsPerMinute > 20)    //To calculate the average we strore some values (4) then do some math to calculate the average
    {
      rates[rateSpot++] = (byte)beatsPerMinute; //Store this reading in the array
      rateSpot %= RATE_SIZE; //Wrap variable

          
      beatAvg = 0;
      for (byte x = 0 ; x < RATE_SIZE ; x++)
        beatAvg += rates[x];
      beatAvg /= RATE_SIZE;
    }   
  for (byte i = 30; i < 60; i++)
    {
      while (particleSensor.available() == false) //do we have new data?
        particleSensor.check(); //Check the sensor for new data

      digitalWrite(readLED, !digitalRead(readLED)); //Blink onboard LED with every data read

      redBuffer[i] = particleSensor.getRed();
      irBuffer[i] = particleSensor.getIR();
      particleSensor.nextSample(); //We're finished with this sample so move to next sample
        
      if (spo2 <= 70){ 
        
        oled.setTextXY(3,0);
        oled.putString(F("SPO2 ="));
        oled.setTextXY(3,8);
        oled.putString(F("N/A"));
          
            
      }else if (spo2 > 60 && spo2 < 100 ){

        oled.setTextXY(3,0);
        oled.putString(F("SPO2 = "));
        oled.setTextXY(3,8);
        oled.putNumber(0);
        oled.setTextXY(3,8);
        oled.putNumber(spo2);
        tone(3,1000);
        noTone(3);
      }else{
        oled.setTextXY(3,0);
        oled.putString(F("SPO2 ="));
        oled.setTextXY(3,8);
        oled.putNumber(spo2);
        tone(3,1000);
        noTone(3);
      }
      
      //  Output to serial port for Bluetooth Communication
      //  (VERY IMPORTANT)
      Serial.println(spo2);

    }

    //After gathering 25 new samples recalculate HR and SP02
    maxim_oxygen_saturation(irBuffer, bufferLength, redBuffer, &spo2, &validSPO2);
}