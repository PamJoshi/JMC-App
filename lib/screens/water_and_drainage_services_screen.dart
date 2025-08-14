import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class WaterAndDrainageServicesScreen extends StatefulWidget {
  @override
  _WaterAndDrainageServicesScreenState createState() => _WaterAndDrainageServicesScreenState();
}

class _WaterAndDrainageServicesScreenState extends State<WaterAndDrainageServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form Controllers
  final TextEditingController _consumerIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Water Bill Data
  Map<String, dynamic> _currentBill = {
    'amount': 750.00,
    'dueDate': DateTime.now().add(Duration(days: 15)),
    'consumption': 15000, // in liters
    'period': 'March 2024',
    'status': 'Unpaid',
    'lastPayment': 680.00,
    'lastPaymentDate': '15 Feb 2024'
  };

  // Consumption Data for Chart
  final List<FlSpot> _consumptionData = [
    FlSpot(0, 12),
    FlSpot(1, 15),
    FlSpot(2, 14),
    FlSpot(3, 16),
    FlSpot(4, 15),
    FlSpot(5, 13),
  ];

  // Service Request Status
  final List<Map<String, dynamic>> _serviceRequests = [
    {
      'id': 'SR001',
      'type': 'New Connection',
      'status': 'In Progress',
      'date': '2024-03-10',
      'details': 'Site inspection scheduled'
    },
    {
      'id': 'SR002',
      'type': 'Repair',
      'status': 'Completed',
      'date': '2024-03-05',
      'details': 'Leakage fixed'
    }
  ];

  bool _isEmergency = false;
  Position? _currentPosition;
  String _currentAddress = "";
  final String emergencyNumber = '+911800XXXXXX'; // Replace with actual emergency number
  final String whatsappNumber = '+91XXXXXXXXXX'; // Replace with actual WhatsApp number

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _consumerIdController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      // First check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location services are disabled. Please enable them in settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () async {
                await Geolocator.openLocationSettings();
              },
            ),
          ),
        );
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permissions are required to use this feature'),
              action: SnackBarAction(
                label: 'Grant',
                onPressed: _getCurrentLocation,
              ),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are permanently denied'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      // Get the location with a timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 30), // Increased timeout for slower devices
        onTimeout: () {
          throw TimeoutException('Location request timed out. Please try again.');
        },
      );

      if (!mounted) return;

      try {
        // Get address from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Address lookup timed out');
          },
        );

        if (!mounted) return;

        setState(() {
          _currentPosition = position;
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            List<String> addressParts = [
              if (place.street?.isNotEmpty ?? false) place.street!,
              if (place.subLocality?.isNotEmpty ?? false) place.subLocality!,
              if (place.locality?.isNotEmpty ?? false) place.locality!,
              if (place.administrativeArea?.isNotEmpty ?? false) place.administrativeArea!,
            ];
            
            _currentAddress = addressParts.join(', ');
            _locationController.text = _currentAddress.isNotEmpty 
                ? _currentAddress 
                : '${position.latitude}, ${position.longitude}';
          } else {
            _locationController.text = '${position.latitude}, ${position.longitude}';
          }
          _isLoading = false;
        });
      } on TimeoutException {
        // If address lookup fails, just use coordinates
        setState(() {
          _currentPosition = position;
          _locationController.text = '${position.latitude}, ${position.longitude}';
          _isLoading = false;
        });
      } catch (e) {
        // If geocoding fails, fallback to coordinates
        setState(() {
          _currentPosition = position;
          _locationController.text = '${position.latitude}, ${position.longitude}';
          _isLoading = false;
        });
      }
      
    } on TimeoutException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Location request timed out')),
      );
    } on PlatformException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location. Please try again.')),
      );
    }
  }

  Widget _buildBillPaymentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Consumption Chart
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text(
                    'Water Consumption Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _consumptionData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
              ),
            ],
          ),
                    ),
            ),
          ],
        ),
            ),
          ),
          SizedBox(height: 16),
          // Current Bill Card
          Card(
            elevation: 4,
            child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Bill Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(
                          _currentBill['status'],
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _currentBill['status'] == 'Unpaid' 
                          ? Colors.red 
                          : Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildBillDetail('Amount Due', '₹${_currentBill['amount']}'),
                  _buildBillDetail('Due Date', 
                    '${_currentBill['dueDate'].day}/${_currentBill['dueDate'].month}/${_currentBill['dueDate'].year}'),
                  _buildBillDetail('Billing Period', _currentBill['period']),
                  _buildBillDetail('Water Consumption', '${_currentBill['consumption']} L'),
                  Divider(),
                  _buildBillDetail('Last Payment', '₹${_currentBill['lastPayment']}'),
                  _buildBillDetail('Last Payment Date', _currentBill['lastPaymentDate']),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showPaymentOptions(),
                          icon: Icon(Icons.payment),
                          label: Text('Pay Now'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      IconButton(
                        onPressed: () => _downloadBill(),
                        icon: Icon(Icons.download),
                        tooltip: 'Download Bill',
                      ),
                    ],
                  ),
            ],
          ),
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewConnectionTab() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply for New Connection',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _consumerIdController,
              decoration: InputDecoration(
                labelText: 'Property ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Property ID';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Installation Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mobile number';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showApplicationSubmitted();
                      }
                    },
                    icon: Icon(Icons.send),
                    label: Text('Submit Application'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _formKey.currentState?.reset(),
                  icon: Icon(Icons.refresh),
                  label: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report Issues',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _isEmergency,
                onChanged: (value) {
                  setState(() {
                    _isEmergency = value;
                  });
                },
                activeColor: Colors.red,
                activeTrackColor: Colors.red.withOpacity(0.5),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withOpacity(0.5),
              ),
            ],
          ),
          if (_isEmergency)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 16),
          Expanded(
                      child: Text(
                        'Emergency mode activated. Your complaint will be treated with highest priority.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 16),
          _buildComplaintCard(
            title: 'Water Supply Issues',
            icon: Icons.water_drop,
            onTap: () => _showComplaintForm('Water Supply Issues'),
            subtitle: 'No water, low pressure, contamination',
          ),
          _buildComplaintCard(
            title: 'Blocked Drainage',
            icon: Icons.block,
            onTap: () => _showComplaintForm('Blocked Drainage'),
            subtitle: 'Clogged drains, slow drainage',
          ),
          _buildComplaintCard(
            title: 'Sewage Overflow',
            icon: Icons.warning_outlined,
            onTap: () => _showComplaintForm('Sewage Overflow'),
            subtitle: 'Overflowing manholes, backflow',
          ),
          _buildComplaintCard(
            title: 'Pipe Damage',
            icon: Icons.broken_image_outlined,
            onTap: () => _showComplaintForm('Pipe Damage'),
            subtitle: 'Leakage, burst pipes, damaged connections',
          ),
          _buildComplaintCard(
            title: 'Water Quality',
            icon: Icons.opacity,
            onTap: () => _showComplaintForm('Water Quality'),
            subtitle: 'Color, taste, odor issues',
          ),
          _buildComplaintCard(
            title: 'Billing Issues',
            icon: Icons.receipt_long,
            onTap: () => _showComplaintForm('Billing Issues'),
            subtitle: 'Wrong readings, excessive charges',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
            'Service Requests',
                  style: TextStyle(
              fontSize: 20,
                    fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _serviceRequests.length,
            itemBuilder: (context, index) {
              final request = _serviceRequests[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: Icon(
                    request['status'] == 'Completed' 
                      ? Icons.check_circle
                      : Icons.pending,
                    color: request['status'] == 'Completed'
                      ? Colors.green
                      : Colors.orange,
                  ),
                  title: Text(request['type']),
                  subtitle: Text('ID: ${request['id']} • ${request['date']}'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${request['status']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Details: ${request['details']}'),
                          if (request['status'] != 'Completed')
                            TextButton.icon(
                              onPressed: () => _trackRequest(request['id']),
                              icon: Icon(Icons.track_changes),
                              label: Text('Track Progress'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStatusDetail('Connection Type', 'Residential'),
                  _buildStatusDetail('Connection ID', 'WC123456'),
                  _buildStatusDetail('Installation Date', '15/01/2024'),
                  _buildStatusDetail('Meter Number', 'M789012'),
                  _buildStatusDetail('Last Reading', '15000 L'),
                  _buildStatusDetail('Connection Status', 'Active'),
                  SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _downloadCertificate(),
                    icon: Icon(Icons.download),
                    label: Text('Download Connection Certificate'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
        padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.emergency, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Emergency Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'For immediate assistance with water and drainage emergencies',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.phone_in_talk, color: Colors.red),
            title: Text('Emergency Helpline'),
            subtitle: Text('24x7 Support'),
            trailing: ElevatedButton(
              onPressed: () => _makeEmergencyCall(),
              child: Text('Call Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.message, color: Colors.orange),
            title: Text('WhatsApp Support'),
            subtitle: Text('Chat with our team'),
            trailing: ElevatedButton(
              onPressed: () => _openWhatsApp(),
              child: Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
          SizedBox(height: 24),
              Text(
            'Common Emergencies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
          _buildEmergencyCard(
            title: 'Burst Pipeline',
            description: 'Major water leakage or burst pipes requiring immediate attention',
            icon: Icons.broken_image,
          ),
          _buildEmergencyCard(
            title: 'Sewage Overflow',
            description: 'Immediate assistance for sewage backflow or overflow',
            icon: Icons.warning,
          ),
          _buildEmergencyCard(
            title: 'Contamination',
            description: 'Water contamination or quality issues affecting public health',
            icon: Icons.local_drink,
          ),
          _buildEmergencyCard(
            title: 'No Water Supply',
            description: 'Complete water supply disruption in your area',
            icon: Icons.water_drop,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title),
        subtitle: Text(description),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () => _showEmergencyForm(title),
        ),
      ),
    );
  }

  Widget _buildComplaintCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required String subtitle,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showEmergencyForm(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Report Emergency: $type'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  suffixIcon: _isLoading 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                        ),
                ),
                readOnly: _isLoading,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Row(
                  children: [
                  Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Expanded(
                    child: Text(
                      'Our emergency team will contact you immediately.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
                    ),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _submitEmergency(type);
            },
            icon: Icon(Icons.warning),
            label: Text('Submit Emergency'),
                style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _submitEmergency(String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Reported'),
        content: Text(
          'Your emergency has been reported.\n\n'
          'Emergency ID: E${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}\n\n'
          'Our team will contact you within 30 minutes.',
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

  void _downloadBill() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading bill...')),
    );
  }

  void _downloadCertificate() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading connection certificate...')),
    );
  }

  void _trackRequest(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Track Request: $id'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrackingStep('Application Received', true, '10 Mar 2024'),
            _buildTrackingStep('Document Verification', true, '11 Mar 2024'),
            _buildTrackingStep('Site Inspection', true, '12 Mar 2024'),
            _buildTrackingStep('Work in Progress', false, 'Pending'),
            _buildTrackingStep('Completion', false, 'Pending'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String step, bool completed, String date) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed ? Colors.green : Colors.grey,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _makeEmergencyCall() async {
    final Uri callUri = Uri(scheme: 'tel', path: emergencyNumber);
    try {
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making call: $e')),
      );
    }
  }

  void _openWhatsApp() async {
    // Standard message for WhatsApp
    final message = 'Hello, I need support regarding water services.';
    
    // Create WhatsApp URL
    final whatsappUrl = "whatsapp://send?phone=$whatsappNumber&text=${Uri.encodeComponent(message)}";
    final whatsappWebUrl = "https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}";
    
    try {
      // Try mobile WhatsApp first
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } 
      // Fallback to web WhatsApp
      else if (await canLaunchUrl(Uri.parse(whatsappWebUrl))) {
        await launchUrl(Uri.parse(whatsappWebUrl));
      } 
      else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening WhatsApp: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water & Drainage Services'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _showHelp(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.payment), text: 'Bill Payment'),
            Tab(icon: Icon(Icons.add_circle_outline), text: 'New Connection'),
            Tab(icon: Icon(Icons.report_problem_outlined), text: 'Complaints'),
            Tab(icon: Icon(Icons.info_outline), text: 'Status'),
            Tab(icon: Icon(Icons.water_damage), text: 'Drainage'),
            Tab(icon: Icon(Icons.emergency), text: 'Emergency'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBillPaymentTab(),
          _buildNewConnectionTab(),
          _buildComplaintsTab(),
          _buildStatusTab(),
          _buildDrainageServicesTab(),
          _buildEmergencyTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActions(),
        label: Text('Quick Actions'),
        icon: Icon(Icons.flash_on),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Helpline'),
              subtitle: Text('1800-XXX-XXXX'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Support'),
              subtitle: Text('support@waterservices.com'),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Live Chat'),
              subtitle: Text('Available 24x7'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionButton(
                  icon: Icons.payment,
                  label: 'Pay Bill',
                  onTap: () {
                    Navigator.pop(context);
                    _showPaymentOptions();
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.report_problem,
                  label: 'Report Issue',
                  onTap: () {
                    Navigator.pop(context);
                    _tabController.animateTo(2);
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.history,
                  label: 'History',
                  onTap: () {
                    Navigator.pop(context);
                    _tabController.animateTo(3);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildBillDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('Credit/Debit Card'),
              onTap: () {
                Navigator.pop(context);
                // Implement card payment
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Net Banking'),
              onTap: () {
                Navigator.pop(context);
                // Implement net banking
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('UPI'),
              onTap: () {
                Navigator.pop(context);
                // Implement UPI payment
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showApplicationSubmitted() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application Submitted'),
        content: Text(
          'Your application for new water connection has been submitted successfully.\n\n'
          'Application ID: WA${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}\n\n'
          'We will contact you shortly for further process.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _formKey.currentState?.reset();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComplaintForm(String complaintType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report $complaintType'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  suffixIcon: _isLoading 
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                        ),
                ),
                readOnly: _isLoading,
              ),
              if (_currentPosition != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'GPS: ${_currentPosition?.latitude.toStringAsFixed(6)}, ${_currentPosition?.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please add a location')),
                );
                return;
              }
              Navigator.pop(context);
              _showComplaintSubmitted();
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showComplaintSubmitted() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complaint Registered'),
        content: Text(
          'Your complaint has been registered successfully.\n\n'
          'Complaint ID: C${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}\n\n'
          'We will address your complaint within 24 hours.',
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

  Widget _buildDrainageServicesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drainage Services',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildComplaintCard(
            title: 'Blocked Drainage',
            icon: Icons.block,
            onTap: () => _showComplaintForm('Blocked Drainage'),
            subtitle: 'Clogged drains, slow drainage',
          ),
          _buildComplaintCard(
            title: 'Sewage Overflow',
            icon: Icons.warning_outlined,
            onTap: () => _showComplaintForm('Sewage Overflow'),
            subtitle: 'Overflowing manholes, backflow',
          ),
          _buildComplaintCard(
            title: 'Bad Odor',
            icon: Icons.sick_outlined,
            onTap: () => _showComplaintForm('Bad Odor'),
            subtitle: 'Unpleasant smell from drains',
          ),
          _buildComplaintCard(
            title: 'Drainage Pipe Damage',
            icon: Icons.broken_image_outlined,
            onTap: () => _showComplaintForm('Drainage Pipe Damage'),
            subtitle: 'Leaking or broken drainage pipes',
          ),
        ],
      ),
    );
  }
}