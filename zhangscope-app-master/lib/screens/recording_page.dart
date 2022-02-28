import 'package:flutter/material.dart';
import 'package:ZhangScope/theme/colors/light_colors.dart';
import 'package:ZhangScope/widgets/back_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:core';

class RecordingScreen extends StatefulWidget {
  final BluetoothDevice server;

  const RecordingScreen({required this.server});

  @override
  State<RecordingScreen> createState() => _RecordingScreen();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _RecordingScreen extends State<RecordingScreen> {
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

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting Locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, an exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var readings = messages.map((_message) {
      return _message.text.trim();
    }).toList();

    if (readings.contains(-999)) {
      readings.remove(-999);
    }

    //print(readings);

    /*
    _AvgSafe(readings) {
      if (readings.isNotEmpty) {
        List<int> readingsRawInt =
            readings.map<int>((data) => int.parse(data)).toList();
        return readingsRawInt.average.round();
      } else {
        return 0;
      }
    }
    */

    _RawReadings(readings) {
      if (readings.isNotEmpty) {
        List<int> readingsRawInt =
            readings.map<int>((data) => int.parse(data)).toList();
        return readingsRawInt.last;
      } else {
        return 0;
      }
    }

    //var avgLevel = _AvgSafe(readings);
    var rawLevel = _RawReadings(readings);
    //var rawLevel = 98;

    IntepretData(SPO2Level) {
      if (SPO2Level >= 95 && SPO2Level <= 100) {
        return 'Within Normal Limits';
      } else if (SPO2Level < 95 && SPO2Level >= 70) {
        return 'Poor';
      } else {
        return 'N/A - Ensure your Finger is Firmly Placed';
      }
    }

    var interpreted = IntepretData(rawLevel);

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
                    readings.clear();
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

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }
}
