import 'dart:core';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:frontend/models/advance_book.dart';
import 'package:frontend/models/hubs.dart';
import 'package:frontend/pages/booking_page.dart';
import 'package:frontend/pages/history_page.dart';
import 'package:frontend/pages/qr_scanner.dart';
import 'package:frontend/pages/wallet_home_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

late int activeHubId;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _MapPageState();
}

class _MapPageState extends State<Dashboard> {
  DateTime? selectedDate = DateTime.now();
  TimeOfDay? selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  late String placeOfMarker;
  bool showInfoContainer = false;
  late int cycleNumber;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    placeOfMarker = '';
    _generateMarkers();
  }

  void debugger() {
    developer.log("YEH LO");
  }

  void infoForMarker(
      String markerId, LatLng markerPosition, int cycles, int hubId) {
    debugger();
    setState(() {
      placeOfMarker = markerId;
      cycleNumber = cycles;
      activeHubId = hubId;
      showInfoContainer = true;
    });
  }

  List<LatLng> coordinates = [];

  void populateCoordinates(List<LatLng> coordinates) {
    for (int i = 0; i < latitudeList.length; i++) {
      coordinates.add(LatLng(latitudeList[i], longitudeList[i]));
    }
  }

  void _generateMarkers() {
    print("GENERATING MARKERS");
    getHubs().whenComplete(() {
      populateCoordinates(coordinates);
      for (int i = 1; i <= hubIdList.length; i++) {
        markers.add(
          Marker(
            markerId: MarkerId(hubNameList[i - 1]),
            position: coordinates[i - 1],
            onTap: () {
              infoForMarker(hubNameList[i - 1], coordinates[i - 1],
                  availableList[i - 1], hubIdList[i - 1]);
            },
          ),
        );
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hello, !',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              margin: EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 600,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(26.5113, 80.2329),
                        zoom: 13,
                      ),
                      markers: markers,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showInfoContainer)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showInfoContainer = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        // Adjust corner radius
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(1),
                            // spreadRadius: 5.0, // Adjust shadow spread
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 30,
                                  // Height adjusted to be a tenth of the container's height
                                  child: Center(child: Text('SELECTED HUB')),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 30,
                                  // Height adjusted to be a tenth of the container's height
                                  child:
                                      Center(child: Text('CYCLES AVAILABLE')),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  child: Center(child: Text(placeOfMarker)),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  child: Center(child: Text('$cycleNumber')),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  child: Center(
                                      child: Text(
                                    'Advanced Booking',
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () => _selectDate(context),
                                        child: Text('Select Date'),
                                      ),
                                      Text(
                                        '${selectedDate?.year}-${selectedDate?.month}-${selectedDate?.day}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () => _selectTime(context),
                                        child: Text('Select Time'),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        '${selectedTime?.hour}:${selectedTime?.minute}',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          const QRViewExample(),
                                    ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .blue, // Change the background color as per your requirement
                                  ),
                                  child: Text(
                                    'Ride Now',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Change the text color as per your requirement
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.0),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    bookForLater(selectedDate, selectedTime);
                                    setState(() {
                                      showInfoContainer = false;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: Text(
                                    'Book Now',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Change the text color as per your requirement
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      // Navigation bar
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/your_image.png'),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Raghav',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: Text('Wallet'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalletHomePage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('History'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => (HistoryPage())),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('My Bookings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => (BookingPage())),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Log Out'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      // Log out action
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
