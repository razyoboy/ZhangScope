import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:ZhangScope/screens/SelectBondedDevicePage.dart';
import 'package:ZhangScope/screens/mock_record.dart';
import 'package:ZhangScope/screens/recording_page.dart';
import 'package:ZhangScope/theme/colors/light_colors.dart';
import 'package:ZhangScope/widgets/task_column.dart';
import 'package:ZhangScope/widgets/top_container.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ConnectionModalScreen extends StatefulWidget {
  _ConnectionModalScreenState createState() => _ConnectionModalScreenState();
}

class _ConnectionModalScreenState extends State<ConnectionModalScreen> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  Widget build(BuildContext context) {
    return Container(
      height: 1,
      child: Column(children: <Widget>[
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
                      'hello',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ),
                ),
              ),
            ]),
        SizedBox(height: 10),
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
    );
  }
}

class HomePage extends StatefulWidget {
  static CircleAvatar calendarIcon() {
    return CircleAvatar(
      radius: 25.0,
      backgroundColor: LightColors.kGreen,
      child: Icon(
        Icons.trending_up_sharp,
        size: 20.0,
        color: Colors.white,
      ),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  File? _image;

  Future _imgFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);

    File file = File(image!.path);
    setState(() {
      _image = file;
    });
  }

  _imgFromCamera() async {
    var image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    File file = File(image!.path);
    setState(() {
      _image = file;
    });
  }

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? blue_connection;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

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

    FlutterBluetoothSerial.instance
        .setPairingRequestHandler((BluetoothPairingRequest request) {
      if (request.pairingVariant == PairingVariant.Pin) {
        return Future.value("1234");
      }
      return Future.value(null);
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(now);

    String greeting() {
      var hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Morning';
      }
      if (hour < 17) {
        return 'Afternoon';
      }
      return 'Evening';
    }

    Duration last_check() {
      DateTime checknow = DateTime.now();
      Duration Diff = now.difference(checknow);
      return Diff;
    }

    var lastchecked = last_check();
    print(lastchecked);
    String MoAfEv = greeting();

    //String _username = 'Wendy';

    String connectionStatus() {
      if (_bluetoothState.isEnabled == true) {
        return 'enabled';
      } else if (_bluetoothState.isEnabled == true &&
          blue_connection!.isConnected == true) {
        return 'enabled, connected';
      } else {
        return 'not enabled';
      }
    }

    bluconnect_icon() {
      if (_bluetoothState.isEnabled == true) {
        return Icons.bluetooth;
      } else {
        return Icons.bluetooth_disabled;
      }
    }

    String batt_health = 'healthy';

    String lastcheckedduration = 'not for a while';

    return Scaffold(
      backgroundColor: LightColors.kLightYellow,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TopContainer(
              height: 200,
              width: width,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MockScreen()),
                            );
                          },
                          child: Icon(Icons.menu,
                              color: LightColors.kDarkBlue, size: 30.0),
                        ),
                        Icon(Icons.search,
                            color: LightColors.kDarkBlue, size: 25.0),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _showPicker(context);
                            },
                            child: CircleAvatar(
                              radius: 50.0,
                              backgroundColor: Colors.white,
                              child: _image != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.file(
                                        _image!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                      width: 100,
                                      height: 100,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Good\n$MoAfEv',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    color: LightColors.kDarkBlue,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Container(
                                child: Text(
                                  '$formattedDate',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              subheading('Device Status'),
                            ],
                          ),
                          SizedBox(height: 15.0),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  backgroundColor: LightColors.kLightYellow,
                                  builder: (context) {
                                    return StatefulBuilder(builder:
                                        (BuildContext context,
                                            StateSetter setStateModal) {
                                      return Container(
                                          child: SafeArea(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 20, 20, 20),
                                          child: Wrap(children: <Widget>[
                                            SizedBox(height: 30.0),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Bluetooth\nStatus',
                                                    style: TextStyle(
                                                        fontSize: 30.0,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  Container(
                                                    height: 40.0,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: LightColors.kGreen,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        FlutterBluetoothSerial
                                                            .instance
                                                            .openSettings();
                                                      },
                                                      child: Center(
                                                        child: Text(
                                                          'Pair',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 14),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ]),
                                            SizedBox(height: 10),
                                            SwitchListTile(
                                              title: const Text(
                                                  'Enable Bluetooth'),
                                              value: _bluetoothState.isEnabled,
                                              onChanged: (bool value) {
                                                // Do the request and update with the true value then
                                                future() async {
                                                  // async lambda seems to not working
                                                  if (value)
                                                    await FlutterBluetoothSerial
                                                        .instance
                                                        .requestEnable();
                                                  else
                                                    await FlutterBluetoothSerial
                                                        .instance
                                                        .requestDisable();
                                                }

                                                future().then((_) {
                                                  setStateModal(() {});
                                                });
                                              },
                                            ),
                                          ]),
                                        ),
                                      ));
                                    });
                                  });
                            },
                            child: TaskColumn(
                              icon: bluconnect_icon(),
                              iconBackgroundColor: LightColors.kRed,
                              title: 'Bluetooth Status',
                              subtitle: connectionStatus(),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TaskColumn(
                            icon: Icons.battery_full,
                            iconBackgroundColor: LightColors.kDarkYellow,
                            title: 'Device Battery Health',
                            subtitle: '$batt_health',
                          ),
                          SizedBox(height: 15.0),
                          TaskColumn(
                            icon: Icons.history,
                            iconBackgroundColor: LightColors.kBlue,
                            title: 'Last Checked',
                            subtitle: '$lastcheckedduration',
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              subheading('Record & Pairing'),
                            ],
                          ),
                          Container(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text('Ensure the device name is ZSM-X',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w100,
                                          fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            height: 60.0,
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              decoration: BoxDecoration(
                                color: LightColors.kGreen,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  FlutterBluetoothSerial.instance
                                      .openSettings();
                                },
                                child: Center(
                                  child: Text(
                                    'Pair with Device',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 60.0,
                            width: MediaQuery.of(context).size.width,
                            child: Container(
                              decoration: BoxDecoration(
                                color: LightColors.kRed,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  final BluetoothDevice? selectedDevice =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SelectBondedDevicePage(
                                            checkAvailability: false);
                                      },
                                    ),
                                  );

                                  if (selectedDevice != null) {
                                    print('Connect -> selected ' +
                                        selectedDevice.address);
                                    _startRecord(context, selectedDevice);
                                  } else {
                                    print('Connect -> no device selected');
                                  }
                                },
                                child: Center(
                                  child: Text(
                                    'Record Now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    /*
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      color: Colors.transparent,
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          subheading('Record & Insights'),
                          SizedBox(height: 5.0),
                        ],
                      ),
                    ),
                    */
                    /*
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: <Widget>[
                          ActiveProjectsCard(
                            cardColor: LightColors.kDarkYellow,
                            title: 'And a histogram here',
                            subtitle: 'how to do this',
                          ),
                        ],
                      ),
                    ),
                    */
                    /*
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                      height: 60.0,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        decoration: BoxDecoration(
                          color: LightColors.kGreen,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            if (_collectingTask?.inProgress ?? false) {
                              await _collectingTask!.cancel();
                              setState(() {
                                /* Update for `_collectingTask.inProgress` */
                              });
                            } else {
                              final BluetoothDevice? selectedDevice =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SelectBondedDevicePage(
                                        checkAvailability: false);
                                  },
                                ),
                              );

                              if (selectedDevice != null) {
                                await _startBackgroundTask(
                                    context, selectedDevice);
                                setState(() {
                                  /* Update for `_collectingTask.inProgress` */
                                });
                              }
                            }
                          },
                          child: Center(
                            child: ((_collectingTask?.inProgress ?? false)
                                ? const Text('Disconnect from Device',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14))
                                : const Text('Connect to Device',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14))),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: ElevatedButton(
                        child: Text('FUck'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SimpleLineChart([])),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: ElevatedButton(
                        child: const Text('View background collected data'),
                        onPressed: (_collectingTask != null)
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ScopedModel<
                                          BackgroundCollectingTask>(
                                        model: _collectingTask!,
                                        child: BackgroundCollectedPage(),
                                      );
                                    },
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                    */
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRecord(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return RecordingScreen(server: server);
        },
      ),
    );
  }
}
