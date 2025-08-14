// water_and_drainage_services_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'base_service_screen.dart';

class WaterAndDrainageServicesScreen extends StatefulWidget {
  @override
  _WaterAndDrainageServicesScreenState createState() => _WaterAndDrainageServicesScreenState();
}

class _WaterAndDrainageServicesScreenState extends State<WaterAndDrainageServicesScreen> {
  Position? _currentPosition;
  String _locationStatus = "Fetching location...";
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();
  String _selectedIssueType = 'Water Supply';

  final List<String> _issueTypes = [
    'Water Supply',
    'Water Quality',
    'Pipeline Leakage',
    'Drainage Blockage',
    'Sewage Overflow',
    'Water Meter Issues',
    'New Connection',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Location permissions are denied';
          });
          return;
        }
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _currentPosition = position;
        _locationStatus = 'Location: ${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
      });
    }
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Complaint Registered'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issue Type: $_selectedIssueType'),
              SizedBox(height: 8),
              Text('Location: $_locationStatus'),
              SizedBox(height: 8),
              Text('Address: ${_addressController.text}'),
              SizedBox(height: 8),
              Text('Details: ${_complaintController.text}'),
              SizedBox(height: 16),
              Text(
                'Complaint ID: WD${DateTime.now().millisecondsSinceEpoch}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water & Drainage Services'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade50],
            stops: [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceCard(),
              SizedBox(height: 20),
              _buildComplaintForm(),
              SizedBox(height: 20),
              _buildEmergencyContact(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water & Drainage Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildServiceItem(
              icon: Icons.water_drop,
              title: 'Water Supply Timings',
              content: 'Morning: 6:00 AM - 9:00 AM\nEvening: 6:00 PM - 9:00 PM',
            ),
            Divider(),
            _buildServiceItem(
              icon: Icons.payment,
              title: 'Water Charges',
              content: 'Residential: ₹200/month\nCommercial: ₹500/month',
            ),
            Divider(),
            _buildServiceItem(
              icon: Icons.plumbing,
              title: 'New Connection',
              content: 'Processing time: 7-10 working days\nVisit our office with required documents',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register Complaint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedIssueType,
                decoration: InputDecoration(
                  labelText: 'Issue Type',
                  border: OutlineInputBorder(),
                ),
                items: _issueTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedIssueType = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _complaintController,
                decoration: InputDecoration(
                  labelText: 'Complaint Details',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter complaint details';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(_locationStatus),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyContact() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildContactItem(
              title: 'Water Supply Emergency',
              contact: '0288-2550231',
            ),
            Divider(),
            _buildContactItem(
              title: 'Drainage Issues',
              contact: '0288-2550232',
            ),
            Divider(),
            _buildContactItem(
              title: 'Water Quality Complaints',
              contact: '0288-2550233',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({required String title, required String contact}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          TextButton.icon(
            onPressed: () {
              // Add phone call functionality
            },
            icon: Icon(Icons.phone),
            label: Text(contact),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _complaintController.dispose();
    super.dispose();
  }
}