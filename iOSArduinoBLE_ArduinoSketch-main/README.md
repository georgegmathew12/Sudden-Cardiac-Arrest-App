# iOSArduinoBLE Arduino Sketch

![Arduino](https://img.shields.io/badge/Arduino-1.8.13-blue.svg)

## Description

This repository contains an Arduino sketch for controlling the built-in LED and reading the temperature from the humidity and temperature sensor on the Arduino Nano 33 BLE Sense board.
The sketch uses Bluetooth connectivity to enable remote control of the built-in LED and monitoring of the temperature readings.

For a detailed description and explanation, please refer to the external article [here](https://medium.com/@leonardocavagnis/from-arduino-programming-to-ios-app-development-8b5da1783e1e).

## Hardware Requirements

- [Arduino Nano 33 BLE Sense board](https://docs.arduino.cc/hardware/nano-33-ble-sense)
- Built-in LED on the Arduino Nano 33 BLE Sense board
- Humidity and temperature sensor (built-in on the Arduino Nano 33 BLE Sense board)

## Usage

1. Connect the Arduino Nano 33 BLE Sense board to your computer.
2. Open the sketch in the [Arduino IDE](https://www.arduino.cc/en/software) (version 1.8.13 or later).
3. Select the appropriate board and port in the Arduino IDE.
4. Upload the sketch to the Arduino Nano 33 BLE Sense board.
5. Install the companion mobile app from the [iOSArduinoBLE iOS App repository](https://github.com/leonardocavagnis/iOSArduinoBLE_iOSApp) for controlling and monitoring the built-in LED and temperature readings.
6. Establish a Bluetooth connection between the Arduino Nano 33 BLE Sense board and the mobile app.
7. Use the mobile app to control the built-in LED and view the temperature readings.

## Dependencies

This sketch relies on the following libraries:

- [ArduinoBLE](https://www.arduino.cc/en/Reference/ArduinoBLE) for Bluetooth connectivity
- [Arduino_HTS221](https://reference.arduino.cc/reference/en/libraries/arduino_hts221) for humidity and temperature sensor support

Please install these libraries through the Arduino Library Manager before uploading the sketch.

## Authors

This project was developed by [Leonardo Cavagnis](https://github.com/leonardocavagnis).
