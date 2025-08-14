// complaints_and_grievances_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ComplaintsAndGrievancesScreen extends StatefulWidget {
  @override
  _ComplaintsAndGrievancesScreenState createState() =>
      _ComplaintsAndGrievancesScreenState();
}

class _ComplaintsAndGrievancesScreenState
    extends State<ComplaintsAndGrievancesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Road Issues';
  String _selectedPriority = 'Medium';
  bool _isSubmitting = false;
  bool _isImageAttached = false;
  final _locationController = TextEditingController();
  dynamic _imageFile; // File for mobile, Uint8List for web
  String? _imageUrl; // For web preview
  bool _isLoading = false;
  Position? _currentPosition;
  String _currentAddress = "";

  final List<String> _categories = [
    'Road Issues',
    'Streetlight Issues',
    'Water Supply',
    'Drainage Problems',
    'Garbage Collection',
    'Public Sanitation',
    'Noise Pollution',
    'Illegal Construction',
    'Park Maintenance',
    'Others'
  ];

  final List<String> _priorities = ['High', 'Medium', 'Low'];

  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 'C2024001',
      'category': 'Road Issues',
      'subject': 'Pothole on Main Street',
      'description': 'Large pothole causing traffic issues',
      'location': '123 Main Street, Jamnagar',
      'status': 'In Progress',
      'priority': 'High',
      'date': '2024-03-15',
      'updates': [
        {
          'date': '2024-03-15',
          'status': 'Submitted',
          'comment': 'Complaint registered'
        },
        {
          'date': '2024-03-16',
          'status': 'Under Review',
          'comment': 'Site inspection scheduled'
        },
        {
          'date': '2024-03-17',
          'status': 'In Progress',
          'comment': 'Repair work initiated'
        }
      ]
    },
    {
      'id': 'C2024002',
      'category': 'Streetlight Issues',
      'subject': 'Street Light Not Working',
      'description': 'Street light near park not working for 2 days',
      'location': '45 Park Road, Jamnagar',
      'status': 'Resolved',
      'priority': 'Medium',
      'date': '2024-03-10',
      'updates': [
        {
          'date': '2024-03-10',
          'status': 'Submitted',
          'comment': 'Complaint registered'
        },
        {
          'date': '2024-03-11',
          'status': 'Resolved',
          'comment': 'Light bulb replaced and tested'
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaints & Grievances'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'File Complaint'),
            Tab(text: 'Track Status'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFileComplaintTab(),
          _buildTrackStatusTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFileComplaintTab() {
    return Container(
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComplaintForm(),
            ],
          ),
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File New Complaint',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.subject),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a subject';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            _buildLocationField(),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.flag),
              ),
              items: _priorities.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _showImagePickerOptions,
                  icon: Icon(Icons.attach_file),
                  label:
                      Text(_isImageAttached ? 'Change Image' : 'Attach Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                _buildImagePreview(),
              ],
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Submit Complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
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
              image: FileImage(_imageFile as File),
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

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (!_isImageAttached) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No Image Attached'),
            content: Text('Are you sure you want to submit without an image?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _submitComplaintData();
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      } else {
        _submitComplaintData();
      }
    }
  }

  Future<void> _submitComplaintData() async {
    setState(() => _isSubmitting = true);

    try {
      // Here you would upload the image and get its URL
      String? imageUrl;
      if (_isImageAttached) {
        // Implement your image upload logic here
        // For web: _imageUrl contains the base64 data
        // For mobile: _imageFile contains the File object
      }

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() => _isSubmitting = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Success'),
            ],
          ),
          content: Text(
            'Your complaint has been submitted successfully. You can track its status in the Track Status tab.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState?.reset();
                _locationController.clear();
                setState(() {
                  _imageFile = null;
                  _isImageAttached = false;
                });
                _tabController.animateTo(1); // Switch to Track Status tab
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting complaint: $e')),
      );
    }
  }

  Widget _buildTrackStatusTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade700, Colors.blue.shade50],
          stops: [0.0, 0.3],
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _complaints.where((c) => c['status'] != 'Resolved').length,
        itemBuilder: (context, index) {
          final activeComplaints =
              _complaints.where((c) => c['status'] != 'Resolved').toList();
          return _buildComplaintCard(activeComplaints[index]);
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade700, Colors.blue.shade50],
          stops: [0.0, 0.3],
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _complaints.where((c) => c['status'] == 'Resolved').length,
        itemBuilder: (context, index) {
          final resolvedComplaints =
              _complaints.where((c) => c['status'] == 'Resolved').toList();
          return _buildComplaintCard(resolvedComplaints[index]);
        },
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    Color statusColor;
    switch (complaint['status']) {
      case 'Submitted':
        statusColor = Colors.blue;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Resolved':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showComplaintDetails(complaint),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      complaint['status'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'ID: ${complaint['id']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                complaint['subject'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    complaint['category'],
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    complaint['date'],
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      complaint['location'],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComplaintDetails(Map<String, dynamic> complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                complaint['subject'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildDetailItem('Complaint ID', complaint['id']),
              _buildDetailItem('Category', complaint['category']),
              _buildDetailItem('Status', complaint['status']),
              _buildDetailItem('Priority', complaint['priority']),
              _buildDetailItem('Date', complaint['date']),
              _buildDetailItem('Location', complaint['location']),
              SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(complaint['description']),
              SizedBox(height: 24),
              Text(
                'Status Updates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              ...(complaint['updates'] as List).map((update) {
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              update['date'],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                update['status'],
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(update['comment']),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
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
        const Duration(seconds: 30),
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
        setState(() {
          _currentPosition = position;
          _locationController.text = '${position.latitude}, ${position.longitude}';
          _isLoading = false;
        });
      } catch (e) {
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

  Widget _buildLocationField() {
    return TextField(
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
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
