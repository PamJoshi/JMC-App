// birth_and_death_certificates_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BirthAndDeathCertificateScreen extends StatefulWidget {
  @override
  _BirthAndDeathCertificateScreenState createState() =>
      _BirthAndDeathCertificateScreenState();
}

class _BirthAndDeathCertificateScreenState
    extends State<BirthAndDeathCertificateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String _selectedCertificateType = 'Birth';
  bool _isNewRegistration = true;

  final List<Map<String, dynamic>> _applications = [
    {
      'id': 'B2024001',
      'type': 'Birth',
      'name': 'ParamJoshi',
      'date': '2025-03-31',
      'status': 'Processing',
      'hospital': 'City General Hospital',
    },
    {
      'id': 'D2024003',
      'type': 'Death',
      'name': 'John Doe',
      'date': '2024-03-18',
      'status': 'Completed',
      'hospital': 'Medicare Hospital',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Birth & Death Certificates'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Apply'), Tab(text: 'Track Status')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildApplyTab(), _buildTrackStatusTab()],
      ),
    );
  }

  Widget _buildApplyTab() {
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
        child: Column(
          children: [
            _buildCertificateTypeSelector(),
            SizedBox(height: 16),
            _buildApplicationForm(),
            SizedBox(height: 16),
            _buildRequirementsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateTypeSelector() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Certificate Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    title: 'Birth',
                    icon: FontAwesomeIcons.baby,
                    isSelected: _selectedCertificateType == 'Birth',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTypeButton(
                    title: 'Death',
                    icon: FontAwesomeIcons.cross,
                    isSelected: _selectedCertificateType == 'Death',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCertificateType = title;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.blue.shade200,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                  : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.blue.shade700,
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label:
                    _selectedCertificateType == 'Birth'
                        ? 'Child\'s Name'
                        : 'Deceased\'s Name',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Date of ${_selectedCertificateType}',
                icon: Icons.calendar_today,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Place of ${_selectedCertificateType}',
                icon: Icons.location_on,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Father\'s Name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Mother\'s Name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required String label,
    required IconData icon,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Submit application logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Application submitted successfully')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text('Submit Application', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildRequirementsCard() {
    final List<Map<String, dynamic>> requirements =
        _selectedCertificateType == 'Birth'
            ? [
              {
                'name': 'Hospital discharge summary',
                'required': true,
                'file': null,
                'status': 'pending',
                'formats': ['pdf', 'jpg', 'png'],
                'maxSize': 5,
              },
              {
                'name': 'Parents\' ID proofs',
                'required': true,
                'file': null,
                'status': 'pending',
                'formats': ['pdf', 'jpg', 'png'],
                'maxSize': 5,
              },
              {
                'name': 'Address proof',
                'required': true,
                'file': null,
                'status': 'pending',
                'formats': ['pdf', 'jpg', 'png'],
                'maxSize': 5,
              },
              {
                'name': 'Marriage certificate (if available)',
                'required': false,
                'file': null,
                'status': 'pending',
                'formats': ['pdf'],
                'maxSize': 5,
              },
            ]
            : [
              {
                'name': 'Death summary from hospital',
                'required': true,
                'file': null,
                'status': 'pending',
                'formats': ['pdf', 'jpg', 'png'],
                'maxSize': 5,
              },
              {
                'name': 'Deceased\'s ID proof',
                'required': true,
                'file': null,
                'status': 'pending',
                'formats': ['pdf', 'jpg', 'png'],
                'maxSize': 5,
              },
              {
                'name': 'Applicant\'s ID proof',
                'required': true,
                'file': null,
                'status': 'pending',
                'formats': ['pdf', 'jpg', 'png'],
                'maxSize': 5,
              },
              {
                'name': 'Address proof',
                'required': true,
                'file': null,
                'status': 'pending',
                'formats': ['pdf', 'jpg', 'png'],
                'maxSize': 5,
              },
            ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            ...requirements.map((req) => _buildDocumentUploadItem(req)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadItem(Map<String, dynamic> document) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(
              document['file'] != null ? Icons.check_circle : Icons.upload_file,
              color: document['file'] != null ? Colors.green : Colors.grey,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document['name'], style: TextStyle(fontSize: 16)),
                  if (document['required'])
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Required',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Accepted formats: ${document['formats'].join(', ')}',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.storage, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 8),
                    Text(
                      'Max size: ${document['maxSize']}MB',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
                if (document['file'] != null) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file,
                          color: Colors.blue.shade700,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            document['file'].path.split('/').last,
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed:
                              () => setState(() => document['file'] = null),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text(
                          document['file'] == null
                              ? 'Upload Document'
                              : 'Change Document',
                        ),
                        onPressed: () => _uploadDocument(document),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    if (document['file'] != null) ...[
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.remove_red_eye),
                        onPressed: () => _previewDocument(document),
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument(Map<String, dynamic> document) async {
    try {
      final ImagePicker picker = ImagePicker();

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? photo = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                      maxWidth: 1200,
                      maxHeight: 1200,
                    );
                    if (photo != null) {
                      _handlePickedFile(document, File(photo.path));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 1200,
                      maxHeight: 1200,
                    );
                    if (image != null) {
                      _handlePickedFile(document, File(image.path));
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading document: $e')));
    }
  }

  void _handlePickedFile(Map<String, dynamic> document, File file) {
    final extension = file.path.split('.').last.toLowerCase();

    // Validate file format
    if (!document['formats'].contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid file format. Allowed formats: ${document['formats'].join(', ')}',
          ),
        ),
      );
      return;
    }

    // Check file size (in MB)
    final fileSize = file.lengthSync() / (1024 * 1024);
    if (fileSize > document['maxSize']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File size exceeds ${document['maxSize']}MB limit'),
        ),
      );
      return;
    }

    setState(() {
      document['file'] = file;
      document['status'] = 'uploaded';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _previewDocument(Map<String, dynamic> document) {
    if (document['file'] == null) return;

    final extension = document['file'].path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text('Document Preview'),
                    backgroundColor: Colors.blue.shade700,
                    leading: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Image.file(document['file']),
                ],
              ),
            ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF preview not implemented')));
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
        itemCount: _applications.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 500 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: _buildApplicationCard(_applications[index]),
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showApplicationDetails(application),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    application['type'] == 'Birth'
                        ? FontAwesomeIcons.baby
                        : FontAwesomeIcons.cross,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(width: 8),
                  Text(
                    application['type'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        application['status'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      application['status'],
                      style: TextStyle(
                        color: _getStatusColor(application['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(application['name'], style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      application['hospital'],
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    application['date'],
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Text(
                    'ID: ${application['id']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showApplicationDetails(Map<String, dynamic> application) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        '${application['type']} Certificate Application',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildDetailItem('Application ID', application['id']),
                      _buildDetailItem('Name', application['name']),
                      _buildDetailItem('Hospital', application['hospital']),
                      _buildDetailItem('Date', application['date']),
                      _buildDetailItem('Status', application['status']),
                      SizedBox(height: 20),
                      if (application['status'] == 'Completed')
                        ElevatedButton.icon(
                          onPressed: () {
                            // Add download logic
                          },
                          icon: Icon(Icons.download),
                          label: Text('Download Certificate'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 14)),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
