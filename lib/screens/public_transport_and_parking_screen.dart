// public_transport_and_parking_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PublicTransportAndParkingScreen extends StatefulWidget {
  @override
  _PublicTransportAndParkingScreenState createState() => _PublicTransportAndParkingScreenState();
}

class _PublicTransportAndParkingScreenState extends State<PublicTransportAndParkingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<BusRoute> busRoutes = [
    BusRoute(
      routeNumber: "101",
      source: "Lal Bangla",
      destination: "Crystal Mall",
      stops: ["Ranjit Road", "Patel Colony", "City Bus Station", "Hospital"],
      timings: ["6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM"],
    ),
    BusRoute(
      routeNumber: "102",
      source: "Railway Station",
      destination: "Aerodrome Circle",
      stops: ["Bus Station", "Civic Center", "Amber Cinema", "Airport Road"],
      timings: ["7:00 AM", "8:30 AM", "10:00 AM", "11:30 AM"],
    ),
    // Add more routes as needed
  ];

  final List<ParkingSpot> parkingSpots = [
    ParkingSpot(
      name: "Central Mall Parking",
      location: "Near Crystal Mall",
      totalSpots: 100,
      availableSpots: 45,
      ratePerHour: 20,
    ),
    ParkingSpot(
      name: "Railway Station Parking",
      location: "Railway Station Complex",
      totalSpots: 200,
      availableSpots: 80,
      ratePerHour: 15,
    ),
    // Add more parking spots as needed
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Public Transport & Parking'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(FontAwesomeIcons.bus), text: 'Bus Routes'),
            Tab(icon: Icon(FontAwesomeIcons.parking), text: 'Parking'),
            Tab(icon: Icon(FontAwesomeIcons.locationDot), text: 'Live Tracking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBusRoutesTab(),
          _buildParkingTab(),
          _buildLiveTrackingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showBookingDialog(context);
        },
        label: Text('Book Now'),
        icon: Icon(Icons.bookmark_add),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildBusRoutesTab() {
    return ListView.builder(
      itemCount: busRoutes.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final route = busRoutes[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                route.routeNumber,
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
            title: Text('${route.source} → ${route.destination}'),
            subtitle: Text('Next bus in: 10 mins'),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stops:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _buildStopsList(route.stops),
                    SizedBox(height: 16),
                    Text(
                      'Timings:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    _buildTimingsList(route.timings),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStopsList(List<String> stops) {
    return Column(
      children: stops.map((stop) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: Colors.blue),
              SizedBox(width: 8),
              Text(stop),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimingsList(List<String> timings) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: timings.map((time) {
        return Chip(
          label: Text(time),
          backgroundColor: Colors.blue.shade50,
        );
      }).toList(),
    );
  }

  Widget _buildParkingTab() {
    return ListView.builder(
      itemCount: parkingSpots.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final spot = parkingSpots[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      spot.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: spot.availableSpots > 0 ? Colors.green.shade100 : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        spot.availableSpots > 0 ? 'Available' : 'Full',
                        style: TextStyle(
                          color: spot.availableSpots > 0 ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(spot.location),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildParkingInfo(
                      'Available',
                      '${spot.availableSpots}/${spot.totalSpots}',
                      FontAwesomeIcons.car,
                    ),
                    _buildParkingInfo(
                      'Rate/Hour',
                      '₹${spot.ratePerHour}',
                      FontAwesomeIcons.indianRupeeSign,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showParkingBookingDialog(context, spot),
                  child: Text('Book Parking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    minimumSize: Size(double.infinity, 40),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParkingInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveTrackingTab() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Custom map-like interface
              Container(
                color: Colors.grey.shade200,
                child: CustomPaint(
                  painter: GridPainter(),
                  child: Stack(
                    children: [
                      // Bus stops markers
                      Positioned(
                        top: 100,
                        left: 100,
                        child: _buildBusStopMarker("Lal Bangla"),
                      ),
                      Positioned(
                        top: 150,
                        right: 120,
                        child: _buildBusStopMarker("Crystal Mall"),
                      ),
                      Positioned(
                        bottom: 120,
                        left: 150,
                        child: _buildBusStopMarker("Railway Station"),
                      ),
                      // Add more bus stop markers as needed
                      
                      // Live bus markers
                      Positioned(
                        top: 120,
                        left: 140,
                        child: _buildBusMarker("101"),
                      ),
                      Positioned(
                        bottom: 150,
                        right: 150,
                        child: _buildBusMarker("102"),
                      ),
                    ],
                  ),
                ),
              ),
              // Zoom controls
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      onPressed: () {
                        // Implement zoom in
                      },
                      child: Icon(Icons.add),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 8),
                    FloatingActionButton.small(
                      onPressed: () {
                        // Implement zoom out
                      },
                      child: Icon(Icons.remove),
                      backgroundColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter bus route number',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Nearby Buses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: busRoutes.map((route) {
                    return Container(
                      margin: EdgeInsets.only(right: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route ${route.routeNumber}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text('${route.source} → ${route.destination}'),
                          SizedBox(height: 4),
                          Text('Arriving in: 5 mins'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusStopMarker(String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            name,
            style: TextStyle(fontSize: 12),
          ),
        ),
        Icon(
          Icons.location_on,
          color: Colors.red,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildBusMarker(String routeNumber) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        FontAwesomeIcons.bus,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Transportation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(FontAwesomeIcons.bus),
              title: Text('Book Bus Ticket'),
              onTap: () {
                Navigator.pop(context);
                // Implement bus booking
              },
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.parking),
              title: Text('Book Parking'),
              onTap: () {
                Navigator.pop(context);
                // Implement parking booking
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showParkingBookingDialog(BuildContext context, ParkingSpot spot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Book Parking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${spot.name}'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Duration (hours)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement booking logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Parking booked successfully!')),
              );
            },
            child: Text('Book'),
          ),
        ],
      ),
    );
  }
}

class BusRoute {
  final String routeNumber;
  final String source;
  final String destination;
  final List<String> stops;
  final List<String> timings;

  BusRoute({
    required this.routeNumber,
    required this.source,
    required this.destination,
    required this.stops,
    required this.timings,
  });
}

class ParkingSpot {
  final String name;
  final String location;
  final int totalSpots;
  final int availableSpots;
  final int ratePerHour;

  ParkingSpot({
    required this.name,
    required this.location,
    required this.totalSpots,
    required this.availableSpots,
    required this.ratePerHour,
  });
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw main roads
    final roadPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.3),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.9),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
