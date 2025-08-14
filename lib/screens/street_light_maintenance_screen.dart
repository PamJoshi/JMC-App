import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async'; // Add this import for TimeoutException

class StreetLightMaintenanceScreen extends StatefulWidget {
  @override
  _StreetLightMaintenanceScreenState createState() => _StreetLightMaintenanceScreenState();
}

class _StreetLightMaintenanceScreenState extends State<StreetLightMaintenanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String _streetName = '';
  String _poleNumber = '';
  String _issueType = 'Light not working';
  bool _isUrgent = false;
  String _description = '';
  String? _selectedLocation;
  String? _imageUrl;
  bool _isSubmitting = false;
  bool _isAnonymous = false;

  File? _imageFile;
  File? _videoFile;
  VideoPlayerController? _videoController;
  bool _isRecording = false;
  bool _isImageAttached = false;
  final ImagePicker _picker = ImagePicker();

  // Maintenance Status
  final List<Map<String, dynamic>> _maintenanceStatus = [
    {
      'id': 'SL-001',
      'location': 'Main Street, Block A',
      'status': 'Under Repair',
      'lastUpdate': '2024-02-25 10:30 AM',
      'estimatedCompletion': '2024-02-26',
      'type': 'Light not working',
      'priority': 'High',
    },
    {
      'id': 'SL-002',
      'location': 'Park Road, Sector 5',
      'status': 'Scheduled',
      'lastUpdate': '2024-02-24 03:15 PM',
      'estimatedCompletion': '2024-02-27',
      'type': 'Flickering light',
      'priority': 'Medium',
    },
  ];

  // Statistics
  final Map<String, int> _statistics = {
    'total': 150,
    'working': 135,
    'maintenance': 10,
    'reported': 5,
  };

  // Add these variables
  bool _isLoading = false;
  Position? _currentPosition;
  String _currentAddress = "";
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _videoController?.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Street Light Maintenance'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: Icon(Icons.report_problem), text: 'Report Issue'),
            Tab(icon: Icon(Icons.map), text: 'Map View'),
            Tab(icon: Icon(Icons.pending_actions), text: 'Status'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportTab(),
          _buildMapTab(),
          _buildStatusTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement emergency reporting
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Emergency reporting coming soon')),
          );
        },
        icon: Icon(Icons.emergency),
        label: Text('Emergency'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            SizedBox(height: 16),
            _buildLocationSection(),
            SizedBox(height: 16),
            _buildIssueSection(),
            SizedBox(height: 16),
            _buildMediaSection(),
            SizedBox(height: 16),
            _buildSubmitSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 32),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Status',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        'Total Lights: ${_statistics['total']} | Working: ${_statistics['working']}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: _statistics['working']! / _statistics['total']!,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Street/Area Name*',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter street/area name';
                }
                return null;
              },
              onChanged: (value) => _streetName = value,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Pole Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                      hintText: 'e.g., SL-123',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) => _poleNumber = value,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement QR scanning
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('QR Scanner coming soon')),
                        );
                      },
                      icon: Icon(Icons.qr_code_scanner),
                      label: Text('Scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement NFC scanning
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('NFC Scanner coming soon')),
                        );
                      },
                      icon: Icon(Icons.nfc),
                      label: Text('NFC'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Issue Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _issueType,
              decoration: InputDecoration(
                labelText: 'Issue Type*',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.error_outline),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: [
                'Light not working',
                'Flickering light',
                'Dim light',
                'Damaged pole',
                'Exposed wires',
                'Timer malfunction',
                'Other'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() => _issueType = value ?? 'Light not working');
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description*',
                hintText: 'Please provide additional details...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide issue description';
                }
                return null;
              },
              onChanged: (value) => _description = value,
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Urgent Issue',
                style: TextStyle(
                  color: _isUrgent ? Colors.red : Colors.black,
                  fontWeight: _isUrgent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text('Mark as urgent if the issue poses safety risks'),
              value: _isUrgent,
              onChanged: (bool value) {
                setState(() => _isUrgent = value);
              },
              activeColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Media & Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 16),
            _buildMediaButtons(),
            SizedBox(height: 16),
            _buildImagePreview(),
            _buildVideoPreview(),
            SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please add a location';
                }
                return null;
              },
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
    );
  }

  Widget _buildSubmitSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              title: Text('Submit Anonymously'),
              subtitle: Text('Your identity will not be shared'),
              value: _isAnonymous,
              onChanged: (bool? value) {
                setState(() => _isAnonymous = value ?? false);
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 16),
                          Text('Submitting...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('Submit Report'),
                        ],
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isUrgent ? Colors.red : Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 64, color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'Interactive Map Coming Soon',
            style: TextStyle(fontSize: 20),
          ),
          Text(
            'View all street lights and their status',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _maintenanceStatus.length,
      itemBuilder: (context, index) {
        final status = _maintenanceStatus[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: Icon(
              _getStatusIcon(status['status']),
              color: _getStatusColor(status['status']),
            ),
            title: Text(status['location']),
            subtitle: Text('ID: ${status['id']} | ${status['type']}'),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status['status'],
                style: TextStyle(
                  color: _getStatusColor(status['status']),
                  fontSize: 12,
                ),
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusDetail('Last Update', status['lastUpdate']),
                    _buildStatusDetail('Estimated Completion', status['estimatedCompletion']),
                    _buildStatusDetail('Priority', status['priority']),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement status tracking
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detailed tracking coming soon')),
                        );
                      },
                      icon: Icon(Icons.track_changes),
                      label: Text('Track Progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Statistics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStatisticTile(
                    'Total Street Lights',
                    _statistics['total'].toString(),
                    Icons.lightbulb_outline,
                    Colors.blue,
                  ),
                  _buildStatisticTile(
                    'Working Lights',
                    _statistics['working'].toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                  _buildStatisticTile(
                    'Under Maintenance',
                    _statistics['maintenance'].toString(),
                    Icons.build,
                    Colors.orange,
                  ),
                  _buildStatisticTile(
                    'Reported Issues',
                    _statistics['reported'].toString(),
                    Icons.report_problem_outlined,
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: Center(
                      child: Text('Performance chart coming soon'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticTile(String title, String value, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 32),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'under repair':
        return Icons.build;
      case 'scheduled':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'under repair':
        return Colors.orange;
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // TODO: Implement actual report submission
      await Future.delayed(Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isUrgent 
            ? 'Urgent issue reported! Our team will address it immediately.'
            : 'Thank you for reporting the issue. We will look into it.'),
          backgroundColor: _isUrgent ? Colors.red : Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Reset form
      setState(() {
        _streetName = '';
        _poleNumber = '';
        _issueType = 'Light not working';
        _isUrgent = false;
        _description = '';
        _isAnonymous = false;
        _selectedLocation = null;
        _imageUrl = null;
      });
      _formKey.currentState?.reset();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isImageAttached = true;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: Please check camera permissions')),
      );
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      final XFile? videoFile = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30), // Limit video to 30 seconds
      );

      if (videoFile != null) {
        _videoFile = File(videoFile.path);
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
          });
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e) {
      print('Error recording video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording video: Please check camera permissions')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (!_isImageAttached || _imageFile == null) return SizedBox.shrink();

    return Stack(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: FileImage(_imageFile!),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                _imageFile = null;
                _isImageAttached = false;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    if (_videoFile == null || _videoController == null) return SizedBox.shrink();

    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _videoController?.dispose();
                    _videoController = null;
                    _videoFile = null;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showImagePickerOptions,
            icon: Icon(
              Icons.videocam,
              color: Colors.white, // Make icon visible
            ),
            label: Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.white, // Make text visible
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _startVideoRecording,
            icon: Icon(
              Icons.videocam,
              color: Colors.white, // Make icon visible
            ),
            label: Text(
              'Record Video',
              style: TextStyle(
                color: Colors.white, // Make text visible
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
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
}