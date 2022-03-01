# ZhangScope
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
  * Navigate to ```zhangscope-app-master``` through a terminal
  * [Build](https://docs.flutter.dev/deployment/android#building-the-app-for-release)