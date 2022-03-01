# Introduction
<img src="https://raw.githubusercontent.com/razyoboy/unishared/main/img/ProductCardSlim.png" width=100%>

<br>

ZhangScope is an easy to replicate Oximeter with a substantial accuracy increase compared to the lower part of the home-use oximeter market.

This is inspired by the current event of the COVID-19 pandemic, which saw the rise of interest in Oximeter products in the market, ZhangScope aims to offer a cheaper, but accurate platform to measure SpO2 concentration - together with a mobile application as a proof-of-concept.

<sub>_DISCLAIMER: This is part of an academic project, thus - it may not be perfect, but we hope that this repository and its content would at the very least provide a working example of an Arduino-based Pulse Oximeter with a complimentary mobile application._
  
This repository contains two codebases:
  1. ZhangScope Oximeter (C++ / Arduino)
  2. ZhangScope Application (Dart / Flutter)
  
  ## Installation
  
  ### Arduino
  *_Requires PlatformIO (VSCode) and its prerequisites,
   wirings and part lists can be found [here](ww)_*
  
  * Clone this repository 
    ```
    git clone https://github.com/razyoboy/ZhangScope.git
    ```
  * In PlatformIO Home, go to the Projects tab
  * Add Existing Project
  * Navigate to ``` zhangscope-arduino ```
  * Open and Upload through PIO
  
  ### Mobile Application
  
  Currently, the application only supports Android, as iOS uses BLE technologies and are not backward compatible with Classic Bluetooth.
  
  #### Pre-packaged
  * Download the release package [here](d)
  * [Deploy](https://developer.android.com/studio/command-line/bundletool#deploy_with_bundletool) to your devices
  
  #### Build from Source
  *_Requires Flutter and its prerequisites._*
  * Clone this repository 
    ```
    git clone https://github.com/razyoboy/ZhangScope.git
    ```
  * Navigate to ```zhangscope-app-master``` through the terminal
  * [Build](https://docs.flutter.dev/deployment/android#building-the-app-for-release)

  #### Build from Source
  *_Requires Flutter and its prerequisites._*
  * Clone this repository 
    ```
    git clone https://github.com/razyoboy/ZhangScope.git
    ```
  * Navigate to ```zhangscope-app-master``` through a terminal
  * [Build](https://docs.flutter.dev/deployment/android#building-the-app-for-release)
  
  ## Usage: Arduino
  
  ### Circuits
  
  Once uploaded to the Arduino, assemble a circuit as shown below - this can be changed up to your standards and /or considerations. One imporant thing is that **A4 and A5 must be the SCA and SCL port**, respectively - and that the **TX/RX of the Arduino and the Bluetooth Module must be connected properly**.
  
<img src="https://raw.githubusercontent.com/razyoboy/unishared/main/img/ZhangScope_bb.png" width=100%><br>
Bigger version [here](https://raw.githubusercontent.com/razyoboy/unishared/main/img/ZhangScope_bb.png)

#### Part List
* I2C 128x96 OLED Screen
* MAX30102 Pulse Oximetry Sensor
* Bluetooth HC-05 Module
* NCP1400 Voltage Step-Up Module
* Arduino Nano (Rev 3.0) (ISCP)
* Generic On/Off Button
* TP4056 Li/Po Charging Module
* Li/Po-1000 mAh Battery

_Note that these parts are interchangable, except for the MAX30102 and the Bluetooth HC-05 Module_
  

  ## Usage: Mobile Application