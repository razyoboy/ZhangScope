//  Mock Recording Page
//
//  To activate this page, you merely have to tap on the menu (the 3 vertical bars icon)
//  Default this would be set to 100% SpO2 saturation.
//  You can change this by changing; var rawLevel = 100; (Line 37)

import 'package:flutter/material.dart';
import 'package:ZhangScope/theme/colors/light_colors.dart';
import 'package:ZhangScope/widgets/back_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:core';

class MockScreen extends StatefulWidget {
  const MockScreen();

  @override
  State<MockScreen> createState() => _MockScreen();
}

class _MockScreen extends State<MockScreen> {
  BluetoothConnection? connection;

  Text subheading(String title) {
    return Text(
      title,
      style: TextStyle(
          color: LightColors.kDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  Change here
    var rawLevel = 100;

    interpretData(SPO2Level) {
      if (SPO2Level >= 95 && SPO2Level <= 100) {
        return 'Within Normal Limits';
      } else if (SPO2Level < 95 && SPO2Level >= 70) {
        return 'Poor';
      } else {
        return 'N/A - Ensure your Finger is Firmly Placed';
      }
    }

    var interpreted = interpretData(rawLevel);

    _DispLevels(MegaPow) {
      if (MegaPow > 70 && MegaPow <= 100) {
        return MegaPow;
      } else {
        return '--';
      }
    }

    var _SPO2Level = _DispLevels(rawLevel);

    return new Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            0,
          ),
          child: Column(children: <Widget>[
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                MyBackButton(),
                GestureDetector(
                  onTap: () {
                    ;
                  },
                  child: Icon(Icons.replay, color: LightColors.kDarkBlue),
                ),
              ],
            )),
            SizedBox(height: 30.0),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'SpO2 level',
                    style:
                        TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),
                  ),
                ]),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$_SPO2Level',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 100,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('$interpreted'),
              ],
            )),
            SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                subheading('Insights'),
              ],
            ),
            SizedBox(height: 10),
            Container(
                child: Row(
              children: <Widget>[
                if (rawLevel >= 95 && rawLevel <= 100)
                  Flexible(
                      child: Text(
                          'You have the normal concentration of blood oxygen level (95% to 100%).'))
                else if (rawLevel < 95 && rawLevel >= 70)
                  Flexible(
                      child: Text(
                          'You have abnormally low concentration of blood oxygen level (>95%).'))
                else
                  Flexible(
                      child: Text(
                          "N/A - Please do not hold too tightly, and don't stare at it so much")),
              ],
            )),
            SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                subheading('What does this mean?'),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                child: Row(
              children: <Widget>[
                if (rawLevel >= 95 && rawLevel <= 100)
                  Flexible(
                      child: Text(
                          'It means that your respiratory and circulation system are working regularly, no need for concern or worry!'))
                else if (rawLevel < 95 && rawLevel >= 70)
                  Flexible(
                      child: Text(
                          'If you are persistently getting low readings, you are at risk of hypoxemia, please capture this screen and consult a Physician as soon as possible.'))
                else
                  Flexible(
                      child: Text(
                          "N/A - Please do not hold too tightly, and don't stare at it so much")),
              ],
            )),
            SizedBox(height: 45),
            Container(
              height: 60.0,
              width: MediaQuery.of(context).size.width,
              child: Container(
                decoration: BoxDecoration(
                  color: LightColors.kDarkYellow,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
