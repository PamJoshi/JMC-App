// feedback_and_surveys_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class FeedbackAndSurveysScreen extends StatefulWidget {
  @override
  _FeedbackAndSurveysScreenState createState() => _FeedbackAndSurveysScreenState();
}

class _FeedbackAndSurveysScreenState extends State<FeedbackAndSurveysScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Feedback form fields
  double _serviceRating = 3.0;
  double _appRating = 3.0;
  String _feedbackText = '';
  String _selectedDepartment = 'General';
  bool _isAnonymous = false;
  bool _isSubmitting = false;
  String _subject = '';
  String _category = 'Suggestion';
  String? _selectedLocation;
  String? _imageUrl;

  // Survey fields
  int _currentSurveyIndex = 0;
  List<Map<String, dynamic>> _surveyResponses = [];

  final List<String> departments = [
    'General',
    'Water Supply',
    'Sanitation',
    'Roads',
    'Street Lighting',
    'Parks & Recreation',
    'Property Tax',
    'Building Permissions',
    'Others'
  ];

  final List<String> categories = [
    'Suggestion',
    'Complaint',
    'Appreciation',
    'Service Request',
    'Others'
  ];

  final List<Map<String, dynamic>> activeSurveys = [
    {
      'title': 'Municipal Services Satisfaction Survey 2024',
      'description': 'Help us improve our services',
      'deadline': '2024-03-31',
      'questions': [
        {
          'question': 'How satisfied are you with municipal services in your area?',
          'type': 'rating',
          'options': []
        },
        {
          'question': 'Which service needs the most improvement?',
          'type': 'choice',
          'options': ['Water Supply', 'Sanitation', 'Roads', 'Street Lighting', 'Parks', 'Others']
        },
        {
          'question': 'How would you rate the responsiveness to citizen requests?',
          'type': 'rating',
          'options': []
        },
        {
          'question': 'What improvements would you suggest for municipal services?',
          'type': 'text',
          'options': []
        }
      ]
    },
    {
      'title': 'City Development Survey 2024',
      'description': 'Share your vision for city development',
      'deadline': '2024-03-31',
      'questions': [
        {
          'question': 'Rate the current infrastructure development in your area',
          'type': 'rating',
          'options': []
        },
        {
          'question': 'Which areas need immediate development attention?',
          'type': 'choice',
          'options': ['Roads & Transport', 'Water & Drainage', 'Parks & Recreation', 'Public Facilities', 'Others']
        },
        {
          'question': 'Suggest improvements for city development:',
          'type': 'text',
          'options': []
        }
      ]
    },
    {
      'title': 'Digital Services Survey',
      'description': 'Help us improve our digital services',
      'deadline': '2024-03-15',
      'questions': [
        {
          'question': 'How often do you use our digital services?',
          'type': 'choice',
          'options': ['Daily', 'Weekly', 'Monthly', 'Rarely', 'Never']
        },
        {
          'question': 'Rate the user-friendliness of our digital services',
          'type': 'rating',
          'options': []
        },
        {
          'question': 'What digital services would you like to see added?',
          'type': 'text',
          'options': []
        }
      ]
    }
  ];

  bool _isLoading = false;
  Position? _currentPosition;
  String _currentAddress = "";
  final TextEditingController _locationController = TextEditingController();
  File? _imageFile;
  bool _isImageAttached = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeSurveyResponses();
  }

  void _initializeSurveyResponses() {
    _surveyResponses = List.generate(
      activeSurveys.length,
      (index) => {
        'responses': List.filled(
          activeSurveys[index]['questions'].length,
          null
        ),
        'completed': false
      }
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _tabController.dispose();
    super.dispose();
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

      // Get current position with null safety
      Position position;
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

      if (!mounted) return;

      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Address lookup timed out'),
        );

        setState(() {
          _currentPosition = position;
          if (placemarks.isNotEmpty) {
            Placemark place = placemarks[0];
            List<String> addressParts = [
              if (place.street?.isNotEmpty ?? false) place.street!,
              if (place.subLocality?.isNotEmpty ?? false) place.subLocality!,
              if (place.locality?.isNotEmpty ?? false) place.locality!,
              if (place.administrativeArea?.isNotEmpty ?? false) place.administrativeArea!,
            ].where((e) => e.isNotEmpty).toList();
            
            _currentAddress = addressParts.join(', ');
            _locationController.text = _currentAddress.isNotEmpty 
                ? _currentAddress 
                : '${position.latitude}, ${position.longitude}';
          } else {
            _locationController.text = '${position.latitude}, ${position.longitude}';
          }
          _isLoading = false;
        });
      } catch (e) {
        // Fallback to coordinates if geocoding fails
        setState(() {
          _currentPosition = position;
          _locationController.text = '${position.latitude}, ${position.longitude}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _getCurrentLocation,
          ),
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // TODO: Implement actual feedback submission
      await Future.delayed(Duration(seconds: 2)); // Simulating API call
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Thank you for submitting your feedback. We will review it shortly.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Reset form
      setState(() {
        _serviceRating = 3.0;
        _appRating = 3.0;
        _feedbackText = '';
        _subject = '';
        _category = 'Suggestion';
        _isAnonymous = false;
        _selectedLocation = null;
        _imageUrl = null;
      });
      _formKey.currentState?.reset();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit feedback. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitSurvey() async {
    final currentSurvey = activeSurveys[_currentSurveyIndex];
    final responses = _surveyResponses[_currentSurveyIndex]['responses'];
    
    // Check if all questions are answered
    if (responses.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    try {
      // TODO: Implement actual survey submission
      await Future.delayed(Duration(seconds: 2)); // Simulating API call
      
      setState(() {
        _surveyResponses[_currentSurveyIndex]['completed'] = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Survey submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit survey. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback & Surveys'),
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.feedback), text: 'Feedback'),
            Tab(icon: Icon(Icons.poll), text: 'Surveys'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackTab(),
          _buildSurveysTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFeedbackTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
                      'Service Feedback',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Help us improve our services',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: InputDecoration(
                        labelText: 'Department*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: departments.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() => _selectedDepartment = value ?? 'General');
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a department';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                decoration: InputDecoration(
                        labelText: 'Category*',
                  border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() => _category = value ?? 'Suggestion');
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
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
                      'Your Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Subject*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subject),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                  }
                  return null;
                },
                      onChanged: (value) => _subject = value,
                    ),
                    SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Rating',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        RatingBar.builder(
                          initialRating: _serviceRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 40,
                          itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() => _serviceRating = rating);
                          },
                  ),
                ],
              ),
                    SizedBox(height: 16),
              TextFormField(
                      maxLines: 4,
                decoration: InputDecoration(
                        labelText: 'Feedback Details*',
                        hintText: 'Please provide detailed feedback...',
                  border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                          return 'Please provide feedback details';
                  }
                  return null;
                },
                      onChanged: (value) => _feedbackText = value,
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
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildAdditionalInformation(),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Submit Anonymously'),
                      subtitle: Text('Your identity will not be shared'),
                      value: _isAnonymous,
                      onChanged: (bool? value) {
                        setState(() => _isAnonymous = value ?? false);
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitFeedback,
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
                                  Text('Submit Feedback'),
                                ],
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: Icon(
                      Icons.videocam,
                      color: Colors.white, // Make icon visible
                ),
                label: Text(
                  _isImageAttached ? 'Change Photo' : 'Add Photo',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(
                      Icons.location_on,
                      color: Colors.white, // Make icon visible
                ),
                label: Text('Add Location', style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (_isImageAttached && _imageFile != null) ...[
          SizedBox(height: 16),
          Stack(
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
                  onTap: () => setState(() {
                    _imageFile = null;
                    _isImageAttached = false;
                  }),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        ),
      ],
    );
  }

  Widget _buildSurveysTab() {
    if (_surveyResponses[_currentSurveyIndex]['completed']) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Survey Completed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Thank you for participating!',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            if (_currentSurveyIndex < activeSurveys.length - 1)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentSurveyIndex++;
                  });
                },
                child: Text('Next Survey'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
              ),
          ],
        ),
      );
    }

    final currentSurvey = activeSurveys[_currentSurveyIndex];
    
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
                    currentSurvey['title'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    currentSurvey['description'],
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Deadline: ${currentSurvey['deadline']}',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ...List.generate(
            currentSurvey['questions'].length,
            (index) => Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${index + 1}',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentSurvey['questions'][index]['question'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildQuestionWidget(
                      currentSurvey['questions'][index],
                      index,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitSurvey,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Submit Survey'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question, int questionIndex) {
    switch (question['type']) {
      case 'rating':
        return RatingBar.builder(
          initialRating: _surveyResponses[_currentSurveyIndex]['responses'][questionIndex] ?? 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 40,
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _surveyResponses[_currentSurveyIndex]['responses'][questionIndex] = rating;
            });
          },
        );
      
      case 'choice':
        return Column(
          children: question['options'].asMap().entries.map<Widget>((entry) {
            return RadioListTile<int>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _surveyResponses[_currentSurveyIndex]['responses'][questionIndex],
              onChanged: (int? value) {
                setState(() {
                  _surveyResponses[_currentSurveyIndex]['responses'][questionIndex] = value;
                });
              },
            );
          }).toList(),
        );
      
      case 'text':
        return TextFormField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter your answer...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _surveyResponses[_currentSurveyIndex]['responses'][questionIndex] = value;
            });
          },
        );
      
      default:
        return Container();
    }
  }

  Widget _buildHistoryTab() {
    final List<Map<String, dynamic>> historyItems = [
      {
        'type': 'feedback',
        'title': 'Street Light Maintenance',
        'date': '2024-02-20',
        'location': 'Main Street, Block A',
        'status': 'In Progress',
        'details': 'Light not working - Pole SL-456',
      },
      {
        'type': 'survey',
        'title': 'Street Light Survey 2024',
        'date': '2024-02-18',
        'status': 'Completed',
      },
      {
        'type': 'feedback',
        'title': 'General Feedback',
        'date': '2024-02-15',
        'rating': 4.5,
        'status': 'Resolved',
      },
      {
        'type': 'survey',
        'title': 'Water Supply Survey 2024',
        'date': '2024-02-10',
        'status': 'Completed',
      },
      {
        'type': 'feedback',
        'title': 'Street Lighting Feedback',
        'date': '2024-02-05',
        'rating': 3.0,
        'status': 'Under Review',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(
              item['type'] == 'feedback' ? Icons.feedback : Icons.poll,
              color: Colors.blue.shade700,
            ),
            title: Text(item['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Date: ${item['date']}'),
                if (item['rating'] != null)
                  Row(
                    children: [
                      Text('Rating: '),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      Text('${item['rating']}'),
                    ],
                  ),
              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item['status'] == 'Resolved' || item['status'] == 'Completed'
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item['status'],
                style: TextStyle(
                  color: item['status'] == 'Resolved' || item['status'] == 'Completed'
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {
              // TODO: Implement history item detail view
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Details coming soon')),
              );
            },
          ),
        );
      },
    );
  }
}