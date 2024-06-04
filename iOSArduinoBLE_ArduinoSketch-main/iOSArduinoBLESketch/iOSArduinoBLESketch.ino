/*
  iOSArduinoBLE

  Board: Arduino Nano 33 BLE Sense

  by Leonardo Cavagnis
*/
// has pedometer and temp; needs ECG/heartbeat
#include <math.h>
#include <ArduinoBLE.h>

// accelerometer pins
const int xpin = A1;
const int ypin = A2;
const int zpin = A3;

// heartrate pin
const int heartratepin = A5;

// temp pin
const int sensorPin = A6;

// ecg
const int low_plus = 10;
const int low_minus = 11;

// led service/characteristic
BLEService ledService("e550bcc0-b2a9-41bd-b6fe-b6b3fe107944");
BLEByteCharacteristic ledstatusCharacteristic("e550bcc0-b2a9-41bd-b6fe-b6b3fe107944", BLEWrite);
// temp sensor service/characteristic
BLEService sensorService("7ac79fc2-f903-44ba-ac69-04285203cd01");
BLEByteCharacteristic temperatureCharacteristic("7ac79fc2-f903-44ba-ac69-04285203cd01", BLERead | BLENotify);
// step service/characteristic
BLEService stepService("33a66063-b1f3-48c1-930d-dfacc8f49499");
BLEByteCharacteristic stepCharacteristic("33a66063-b1f3-48c1-930d-dfacc8f49499", BLERead | BLENotify);
// distance service/characteristic
BLEService distanceService("416318d1-44e2-4705-9dfd-cdbe160651a2");
BLEByteCharacteristic distanceCharacteristic("416318d1-44e2-4705-9dfd-cdbe160651a2", BLERead | BLENotify);
// heartbeat service/characteristic
BLEService heartbeatService("71ec868a-dd68-4866-b31a-c71d77118e69");
BLEByteCharacteristic heartbeatCharacteristic("71ec868a-dd68-4866-b31a-c71d77118e69", BLERead | BLENotify);

float temperature = 0;
int step_count = 1;
int step_increment = 0;
float total_distance = 0;
int heart_signal;
int heart_threshold = 470;
int count;
int bpm = 17;
bool pulseCounted = false;
unsigned long startHeartMillis = 0;
unsigned long startMillis = 0;
unsigned long currentMillis = 0;
float threshold = 12.5;  
float xval[50] = {0};
float yval[50] = {0};
float zval[50] = {0};
float xavg, yavg, zavg;
int steps, flag = 0;

void setup() {
  // calibrate pedometer
  Serial.begin(115200);
  Serial.println("Starting setup");
  delay(2000);
  pinMode(LED_BUILTIN, OUTPUT);

  // BLE initialization
  Serial.println("Setting up BLE");
  if (!BLE.begin()) {
    Serial.println("Failed to initialize BLE module!");
    while (1);
  }
  Serial.println("BLE successful");

  // set advertised local name and service UUID
  BLE.setLocalName("iOSArduinoBoard");
  BLE.setAdvertisedService(ledService);

  // add the characteristics to the services
  ledService.addCharacteristic(ledstatusCharacteristic);
  sensorService.addCharacteristic(temperatureCharacteristic);
  stepService.addCharacteristic(stepCharacteristic);
  distanceService.addCharacteristic(distanceCharacteristic);
  heartbeatService.addCharacteristic(heartbeatCharacteristic);

  // add services to BLE stack
  BLE.addService(ledService);
  BLE.addService(sensorService);
  BLE.addService(stepService);
  BLE.addService(distanceService);
  BLE.addService(heartbeatService);

  // set read request handler for temperature characteristic
  temperatureCharacteristic.setEventHandler(BLERead, temperatureCharacteristicRead);
  stepCharacteristic.setEventHandler(BLERead, stepCharacteristicRead);
  distanceCharacteristic.setEventHandler(BLERead, distanceCharacteristicRead);
  heartbeatCharacteristic.setEventHandler(BLERead, heartbeatCharacteristicRead);

  // start advertising
  Serial.println("Starting advertising...");
  BLE.advertise();
  startMillis = millis();
  Serial.println("Advertising now");
}

void loop() {  
  // listen for BLE centrals to connect
  BLEDevice central = BLE.central();

  // if a central is connected to peripheral
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {
      delay(1);
      currentMillis = millis();
      // if (currentMillis - startHeartMillis >= 15000) {
      //   bpm = count * 4 / 25.0;
      //   count = 0;
      //   startHeartMillis = currentMillis;
      // }
      // heart_signal = analogRead(heartratepin);
      // if (heart_signal > heart_threshold && !pulseCounted) {
      //   pulseCounted = true;
      //   count = count + 1;
      // } else if (heart_signal < heart_threshold) {
      //   pulseCounted = false;
      // }
      
      if (currentMillis - startMillis >= 1000) {
        delay(1);
        // read temp/steps values every 1 second
        temperature = return_temp();
        step_increment = return_steps();
        step_count = step_count + step_increment;
        total_distance = (((63.0) * (0.413) * step_count))/12.0;

        Serial.print("Temperature: ");
        Serial.println(temperature);
        Serial.print("Step Count: ");
        Serial.println(step_count);
        Serial.print("Total Distance: ");
        Serial.println(total_distance);
        Serial.print("Heartrate: ");
        Serial.println(random(160, 221));

        // update sensor values in sensor characteristics
        temperatureCharacteristic.writeValue(temperature);
        stepCharacteristic.writeValue(step_count);
        distanceCharacteristic.writeValue(total_distance);
        heartbeatCharacteristic.writeValue(bpm);

        startMillis = currentMillis;
        delay(1);
      }
      
      // check LedStatus characteristic write
      if (ledstatusCharacteristic.written()) {
        delay(1);
        if (ledstatusCharacteristic.value()) {
          digitalWrite(LED_BUILTIN, HIGH);
        } else {
          digitalWrite(LED_BUILTIN, LOW);
        }
      }
    }
  }
}

// read request handler for sensor haracteristics
void temperatureCharacteristicRead(BLEDevice central, BLECharacteristic characteristic) {
  temperatureCharacteristic.writeValue(temperature);
}
void stepCharacteristicRead(BLEDevice central, BLECharacteristic characteristic) {
  stepCharacteristic.writeValue(step_count);
}
void distanceCharacteristicRead(BLEDevice central, BLECharacteristic characteristic) {
  distanceCharacteristic.writeValue(total_distance);
}
void heartbeatCharacteristicRead(BLEDevice central, BLECharacteristic characteristic) {
  heartbeatCharacteristic.writeValue(bpm);
}







// calibrate pedometer
void calibrate()
{
  Serial.println("Calibrating pedometer");
  float sum = 0;
  float sum1 = 0;
  float sum2 = 0;
  
  for (int i = 0; i < 100; i++) {
      xval[i] = float(analogRead(xpin));
      sum = xval[i] + sum;
  }
  delay(1);
  xavg = sum / 100.0;
  //Serial.println(xavg);
  
  for (int j = 0; j < 100; j++)
  {
      yval[j] = float(analogRead(ypin));
      sum1 = yval[j] + sum1;
  }
  yavg = sum1 / 100.0;
  //Serial.println(yavg);
  delay(1);
  
  for (int q = 0; q < 100; q++)
  {
      zval[q] = float(analogRead(zpin));
      sum2 = zval[q] + sum2;
  }
  zavg = sum2 / 100.0;
  delay(1);
  Serial.println("Calibration complete");
}

// get steps
float return_steps()
{
  int acc = 0;
  float totvect[50] = {0};
  float totave[50] = {0};
  float xaccl[50] = {0};
  float yaccl[50] = {0};
  float zaccl[50] = {0};
  
  for (int a = 0; a < 50; a++)
  {
      xaccl[a] = float(analogRead(xpin));
      delay(1);
      yaccl[a] = float(analogRead(ypin));
      delay(1);
      zaccl[a] = float(analogRead(zpin));
      delay(1);
      totvect[a] = sqrt(((xaccl[a] - xavg) * (xaccl[a] - xavg)) + ((yaccl[a] - yavg) * (yaccl[a] - yavg))+ ((zaccl[a] - zavg) * (zaccl[a] - zavg)));
      totave[a] = (totvect[a] + totvect[a - 1]) / 2 ;
      // Serial.println("totave[a]");
      // Serial.println(totave[a]);
      delay(50);
      
      if (totave[a] > threshold && flag == 0)
      {
          steps = steps + 1;
          flag = 1;

          // steps to distance conversion
          // assuming 5'6" male --> step length = height in inches * 0.415
          float totDistance = (((63.0) * (0.413) * steps))/12.0;
          
          // Serial.println('\n');
          // Serial.print("steps: ");
          // Serial.println(steps);
          // Serial.print("Total Distance: ");
          // Serial.println(totDistance);
          // Serial.println("totave[a]");
          // Serial.println(totave[a]);
          
      }
      else if (totave[a] > threshold && flag == 1)
      {
          // Don't Count
      }
      if (totave[a] < threshold && flag == 1)
      {
          flag = 0;
      }
      if (steps < 0) {
          steps = 0;
      }      
  }
  delay(100);
  return steps;
}

// get temp
float return_temp()
{
  int reading = analogRead(sensorPin);  
  float voltage = reading * 3.3;
  voltage /= 1024.0; 
  float temperatureC = (voltage - 0.5) * 100 ;  //converting from 10 mv per degree wit 500 mV offset
                                               //to degrees ((voltage - 500mV) times 100)
  float temperatureF = (temperatureC * 9.0 / 5.0) + 32.0;
  return temperatureF;
}