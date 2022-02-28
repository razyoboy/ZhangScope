import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ZhangScope/dates_list.dart';
import 'package:ZhangScope/theme/colors/light_colors.dart';
import 'package:ZhangScope/widgets/back_button.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ConnectionScreen extends StatefulWidget {
  // I shall use this space to put some meaningless code.

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  String ConnectionStatus = 'Pair';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          MyBackButton(),
          SizedBox(height: 30.0),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Connection\nCenter',
                  style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w700),
                ),
                Container(
                  height: 40.0,
                  width: 120,
                  decoration: BoxDecoration(
                    color: LightColors.kGreen,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: () {
                      FlutterBluetoothSerial.instance.openSettings();
                    },
                    child: Center(
                      child: Text(
                        '$ConnectionStatus',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ]),
          /*
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    ':  connected',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              */
          SizedBox(height: 10),
          /*
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pairing',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
          ),*/
          SwitchListTile(
            title: const Text('Enable Bluetooth'),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value)
                  await FlutterBluetoothSerial.instance.requestEnable();
                else
                  await FlutterBluetoothSerial.instance.requestDisable();
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
        ]),
      )),
    );
  }
}
