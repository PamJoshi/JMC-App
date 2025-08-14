import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';
import 'chatbot_screen.dart';
import 'contact_screen.dart';
import 'about_screen.dart';

class EmergencyHelplinesScreen extends StatefulWidget {
  @override
  _EmergencyHelplinesScreenState createState() => _EmergencyHelplinesScreenState();
}

class _EmergencyHelplinesScreenState extends State<EmergencyHelplinesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _personalContacts = [
    {
      'name': 'Param Joshi',
      'relation': 'Android Developer',
      'number': '+91 9979875973',
      'address': 'Swaminarayan Hostel, Mehsana'
    },
    {
      'name': 'John Doe',
      'relation': 'Emergency Contact',
      'number': '+9876543210',
      'address': '456 Safety Avenue'
    },
  ];

  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'title': 'Police',
      'number': '100',
      'icon': Icons.local_police,
      'backgroundColor': Colors.blue.shade700,
      'description': '24/7 Police Emergency Services'
    },
    {
      'title': 'Ambulance',
      'number': '108',
      'icon': Icons.local_hospital,
      'backgroundColor': Colors.red.shade700,
      'description': 'Medical Emergency Services'
    },
    {
      'title': 'Fire',
      'number': '101',
      'icon': Icons.local_fire_department,
      'backgroundColor': Colors.orange.shade700,
      'description': 'Fire Emergency Services'
    },
    {
      'title': 'Women Helpline',
      'number': '1091',
      'icon': Icons.woman,
      'backgroundColor': Colors.purple.shade700,
      'description': 'Women Safety & Emergency Support'
    },
    {
      'title': 'Child Helpline',
      'number': '1098',
      'icon': Icons.child_care,
      'backgroundColor': Colors.green.shade700,
      'description': 'Child Safety & Support Services'
    },
    {
      'title': 'Senior Citizen Helpline',
      'number': '14567',
      'icon': Icons.elderly,
      'backgroundColor': Colors.teal.shade700,
      'description': 'Elder Care & Emergency Support'
    },
    {
      'title': 'Disaster Management',
      'number': '1070',
      'icon': Icons.warning_amber,
      'backgroundColor': Colors.amber.shade700,
      'description': 'Natural & Man-made Disaster Support'
    },
    {
      'title': 'Anti-Corruption',
      'number': '1031',
      'icon': Icons.gavel,
      'backgroundColor': Colors.brown.shade700,
      'description': 'Report Corruption & Malpractices'
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'title': 'Share Location',
      'icon': Icons.share_location,
      'action': 'share_location'
    },
    {
      'title': 'Emergency SMS',
      'icon': Icons.message,
      'action': 'send_sms'
    },
    {
      'title': 'First Aid Guide',
      'icon': Icons.medical_services,
      'action': 'first_aid'
    },
    {
      'title': 'Emergency Contacts',
      'icon': Icons.contacts,
      'action': 'contacts'
    },
  ];

  bool _isLoading = false;
  Position? _currentPosition;
  String _currentAddress = "";
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'share_location':
        _showLocationSharingDialog();
        break;
      case 'send_sms':
        _showEmergencySMSDialog();
        break;
      case 'first_aid':
        _showFirstAidGuide();
        break;
      case 'contacts':
        _showEmergencyContactsList();
        break;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch phone dialer'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

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

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location permissions are required'),
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

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Location request timed out'),
        );
      } catch (e) {
        throw Exception('Could not get location: ${e.toString()}');
      }

      if (position == null) {
        throw Exception('Could not get location: Position is null');
      }

      if (!mounted) return;

      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Address lookup timed out'),
        );

        if (!mounted) return;

        setState(() {
          _currentPosition = position;
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks.first;
            List<String> addressParts = [
              if (place.street?.isNotEmpty ?? false) place.street!,
              if (place.subLocality?.isNotEmpty ?? false) place.subLocality!,
              if (place.locality?.isNotEmpty ?? false) place.locality!,
              if (place.administrativeArea?.isNotEmpty ?? false) place.administrativeArea!,
            ].where((part) => part.isNotEmpty).toList();
            
            _currentAddress = addressParts.isNotEmpty 
                ? addressParts.join(', ')
                : '${position?.latitude}, ${position?.longitude}';
            _locationController.text = _currentAddress;
          } else {
            _locationController.text = '${position?.latitude}, ${position?.longitude}';
          }
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _currentPosition = position;
          _locationController.text = '${position?.latitude}, ${position?.longitude}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _getCurrentLocation,
          ),
        ),
      );
    }
  }

  void _showLocationSharingDialog() async {
    await _getCurrentLocation(); // Get location first

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 8),
            Text('Share Location'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share your current location with emergency services?'),
            SizedBox(height: 16),
            if (_currentPosition != null) Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Location:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
                  Text('Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                  if (_currentAddress.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'Address:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_currentAddress),
                  ],
                ],
              ),
            ) else
              CircularProgressIndicator(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _currentPosition == null ? null : () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Location shared with emergency services'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            icon: Icon(Icons.share),
            label: Text('Share Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencySMSDialog() async {
    await _getCurrentLocation(); // Get location first
    final messageController = TextEditingController();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.message, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency SMS'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter emergency message',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            if (_currentPosition != null) Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location will be shared:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('GPS: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                  if (_currentAddress.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text('Address: $_currentAddress'),
                  ],
                ],
              ),
            ) else
              CircularProgressIndicator(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: _currentPosition == null ? null : () async {
              final message = messageController.text.isEmpty 
                  ? 'Emergency! I need help!' 
                  : messageController.text;
              
              final locationText = _currentAddress.isNotEmpty
                  ? '\n\nLocation: $_currentAddress'
                  : '\n\nGPS: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}';
              
              final smsUri = Uri.parse(
                'sms:${_personalContacts.map((c) => c['number']).join(';')}?body=${Uri.encodeComponent(message + locationText)}'
              );

              try {
                await launchUrl(smsUri);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Emergency SMS sent with location'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not send SMS: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: Icon(Icons.send),
            label: Text('Send Emergency SMS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showFirstAidGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'First Aid Guide',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildFirstAidItem(
                'CPR Steps',
                'Basic life support steps for adults',
                Icons.favorite,
              ),
              _buildFirstAidItem(
                'Bleeding Control',
                'Steps to control severe bleeding',
                Icons.healing,
              ),
              _buildFirstAidItem(
                'Burns Treatment',
                'First aid for different types of burns',
                Icons.whatshot,
              ),
              _buildFirstAidItem(
                'Choking Response',
                'How to help someone who is choking',
                Icons.air,
              ),
              _buildFirstAidItem(
                'Fracture Care',
                'Initial care for suspected fractures',
                Icons.accessibility_new,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFirstAidItem(String title, String description, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _showFirstAidDetails(title),
      ),
    );
  }

  void _showFirstAidDetails(String title) {
    final Map<String, List<String>> firstAidSteps = {
      'CPR Steps': [
        '1. Check the scene is safe',
        '2. Check the person\'s responsiveness',
        '3. Call for help (dial emergency number)',
        '4. Check breathing',
        '5. Begin chest compressions',
        '6. Give rescue breaths',
        '7. Continue CPR until help arrives'
      ],
      'Bleeding Control': [
        '1. Apply direct pressure with clean cloth',
        '2. Keep the injured area elevated',
        '3. Apply pressure bandage',
        '4. Monitor for signs of shock',
        '5. Seek immediate medical attention'
      ],
      'Burns Treatment': [
        '1. Cool the burn under running water',
        '2. Remove jewelry and tight clothing',
        '3. Cover with sterile gauze',
        '4. Don\'t break blisters',
        '5. Seek medical attention for serious burns'
      ],
      'Choking Response': [
        '1. Encourage coughing',
        '2. Give 5 back blows',
        '3. Perform 5 abdominal thrusts',
        '4. Alternate between back blows and thrusts',
        '5. Call emergency if person becomes unconscious'
      ],
      'Fracture Care': [
        '1. Don\'t move the injured area',
        '2. Apply ice pack to reduce swelling',
        '3. Immobilize the injured area',
        '4. Check circulation beyond the injury',
        '5. Seek immediate medical attention'
      ],
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...firstAidSteps[title]!.map((step) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text(step)),
                  ],
                ),
              )),
              SizedBox(height: 16),
              Text(
                'Note: This is a basic guide. Always seek professional medical help in emergencies.',
                style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
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

  void _showEmergencyContactsList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Emergency Contacts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showAddContactDialog(),
                icon: Icon(Icons.add),
                label: Text('Add New Contact'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _personalContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _personalContacts[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: Text(
                            contact['name'][0],
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          contact['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact['relation']),
                            Text(contact['address'], style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.phone, color: Colors.green),
                              onPressed: () => _makePhoneCall(contact['number']),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddContactDialog(contact: contact),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContactDialog({Map<String, dynamic>? contact}) {
    final nameController = TextEditingController(text: contact?['name'] ?? '');
    final relationController = TextEditingController(text: contact?['relation'] ?? '');
    final numberController = TextEditingController(text: contact?['number'] ?? '');
    final addressController = TextEditingController(text: contact?['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contact == null ? 'Add Emergency Contact' : 'Edit Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: relationController,
                decoration: InputDecoration(
                  labelText: 'Relation',
                  prefixIcon: Icon(Icons.people),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: numberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
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
              // Add or update contact logic here
              Navigator.pop(context);
              setState(() {
                if (contact == null) {
                  _personalContacts.add({
                    'name': nameController.text,
                    'relation': relationController.text,
                    'number': numberController.text,
                    'address': addressController.text,
                  });
                } else {
                  final index = _personalContacts.indexOf(contact);
                  _personalContacts[index] = {
                    'name': nameController.text,
                    'relation': relationController.text,
                    'number': numberController.text,
                    'address': addressController.text,
                  };
                }
              });
            },
            child: Text(contact == null ? 'Add Contact' : 'Update'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: InputDecoration(
        labelText: 'Your Location',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
        suffixIcon: _isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: Icon(Icons.my_location),
                onPressed: _getCurrentLocation,
              ),
      ),
      readOnly: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade800,
                      Colors.blue.shade500,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, color: Colors.blue.shade700, size: 40),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'JMC Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Your City, Your Services',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.blue.shade700),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/');  // Navigate to home
                },
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue.shade700),
                title: Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_mail, color: Colors.blue.shade700),
                title: Text('Contact'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.chat, color: Colors.blue.shade700),
                title: Text('Chatbot'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatbotScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Emergency Helplines'),
        backgroundColor: Colors.red,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Emergency'),
            Tab(text: 'First Aid'),
            Tab(text: 'Contacts'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Emergency Services'),
                  content: Text(
                    'These are official emergency helpline numbers. In case of emergency, tap on the number to directly call the service.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Emergency Tab
          SingleChildScrollView(
        child: Column(
          children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.red.shade50,
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Tap on any emergency number to directly call the service',
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: _quickActions.map((action) => Card(
                          elevation: 4,
                          child: InkWell(
                            onTap: () => _handleQuickAction(action['action']),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  action['icon'],
                                  size: 32,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  action['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Emergency Numbers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _emergencyContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _emergencyContacts[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: contact['backgroundColor'],
                                child: Icon(contact['icon'], color: Colors.white),
                              ),
                              title: Text(
                                contact['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(contact['description']),
                              trailing: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  contact['number'],
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () => _makePhoneCall(contact['number']),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
            ),
          ],
        ),
          ),
          // First Aid Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Aid Guide',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildFirstAidItem(
                  'CPR Steps',
                  'Basic life support steps for adults',
                  Icons.favorite,
                ),
                _buildFirstAidItem(
                  'Bleeding Control',
                  'Steps to control severe bleeding',
                  Icons.healing,
                ),
                _buildFirstAidItem(
                  'Burns Treatment',
                  'First aid for different types of burns',
                  Icons.whatshot,
                ),
                _buildFirstAidItem(
                  'Choking Response',
                  'How to help someone who is choking',
                  Icons.air,
                ),
                _buildFirstAidItem(
                  'Fracture Care',
                  'Initial care for suspected fractures',
                  Icons.accessibility_new,
                ),
              ],
            ),
          ),
          // Contacts Tab
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Emergency Contacts',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _showAddContactDialog(),
                  icon: Icon(Icons.add),
                  label: Text('Add New Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _personalContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _personalContacts[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          child: Text(
                            contact['name'][0],
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          contact['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(contact['relation']),
                            Text(contact['address'], style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.phone, color: Colors.green),
                              onPressed: () => _makePhoneCall(contact['number']),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddContactDialog(contact: contact),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLocationSharingDialog(),
        icon: Icon(Icons.share_location),
        label: Text('Share Location'),
        backgroundColor: Colors.red,
      ),
    );
  }
}