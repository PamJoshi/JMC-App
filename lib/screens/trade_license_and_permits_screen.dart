// trade_license_and_permits_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TradeLicenseAndPermitsScreen extends StatefulWidget {
  @override
  _TradeLicenseAndPermitsScreenState createState() =>
      _TradeLicenseAndPermitsScreenState();
}

class _TradeLicenseAndPermitsScreenState
    extends State<TradeLicenseAndPermitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String _selectedLicenseType = 'New Business';
  bool _isRenewal = false;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _licenses = [
    {
      'id': 'TL2024001',
      'type': 'Shop & Establishment',
      'businessName': 'City Mart',
      'owner': 'John Smith',
      'status': 'Active',
      'validUntil': '2025-03-31',
      'address': '123 Market Road, Jamnagar',
    },
    {
      'id': 'TL2024002',
      'type': 'Restaurant',
      'businessName': 'Spice Garden',
      'owner': 'Sarah Johnson',
      'status': 'Pending Renewal',
      'validUntil': '2024-04-15',
      'address': '45 Food Street, Jamnagar',
    },
  ];

  final List<String> _licenseTypes = [
    'Shop & Establishment',
    'Restaurant',
    'Hotel',
    'Factory',
    'Warehouse',
    'Professional Services',
    'Others'
  ];

  Map<String, List<Map<String, dynamic>>> _documentRequirements = {
    'Shop & Establishment': [
      {
        'name': 'Identity Proof',
        'description': 'Aadhar Card/PAN Card/Voter ID',
        'required': true,
        'status': 'pending',
        'formats': ['pdf', 'jpg', 'png'],
        'maxSize': 5,
        'file': null,
      },
      {
        'name': 'Address Proof',
        'description': 'Electricity Bill/Water Bill (not older than 3 months)',
        'required': true,
        'status': 'pending',
        'formats': ['pdf', 'jpg', 'png'],
        'maxSize': 5,
        'file': null,
      },
      {
        'name': 'Property Documents',
        'description': 'Ownership Deed/Rent Agreement with NOC from Owner',
        'required': true,
        'status': 'pending',
        'formats': ['pdf'],
        'maxSize': 10,
        'file': null,
      },
      {
        'name': 'Business Registration',
        'description': 'GST Registration/MSME Registration/Partnership Deed',
        'required': true,
        'status': 'pending',
        'formats': ['pdf'],
        'maxSize': 5,
        'file': null,
      },
      {
        'name': 'Fire Safety NOC',
        'description':
            'NOC from Fire Department (for establishments > 100 sq ft)',
        'required': false,
        'status': 'pending',
        'formats': ['pdf'],
        'maxSize': 5,
        'file': null,
      }
    ],
    'Restaurant': [
      {
        'name': 'Identity Proof',
        'description': 'Aadhar Card/PAN Card/Voter ID',
        'required': true,
        'status': 'pending',
        'formats': ['pdf', 'jpg', 'png'],
        'maxSize': 5,
        'file': null,
      },
      {
        'name': 'Address Proof',
        'description': 'Electricity Bill/Water Bill (not older than 3 months)',
        'required': true,
        'status': 'pending',
        'formats': ['pdf', 'jpg', 'png'],
        'maxSize': 5,
        'file': null,
      },
      {
        'name': 'Property Documents',
        'description': 'Ownership Deed/Rent Agreement with NOC from Owner',
        'required': true,
        'status': 'pending',
        'formats': ['pdf'],
        'maxSize': 10,
        'file': null,
      },
      {
        'name': 'FSSAI License',
        'description': 'Food Safety License',
        'required': true,
        'status': 'pending',
        'formats': ['pdf'],
        'maxSize': 5,
        'file': null,
      },
      {
        'name': 'Fire Safety NOC',
        'description': 'NOC from Fire Department',
        'required': true,
        'status': 'pending',
        'formats': ['pdf'],
        'maxSize': 5,
        'file': null,
      },
      {
        'name': 'Health Certificates',
        'description': 'Medical Certificates of Food Handlers',
        'required': true,
        'status': 'pending',
        'formats': ['pdf', 'jpg', 'png'],
        'maxSize': 5,
        'file': null,
      }
    ],
    // Add more license types and their document requirements...
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedLicenseType = _licenseTypes[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trade License & Permits'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Apply'),
            Tab(text: 'My Licenses'),
            Tab(text: 'Renewals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplyTab(),
          _buildMyLicensesTab(),
          _buildRenewalsTab(),
        ],
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
            _buildApplicationTypeCard(),
            SizedBox(height: 16),
            _buildApplicationForm(),
            SizedBox(height: 16),
            _buildDocumentsCard(),
            SizedBox(height: 16),
            _buildFeesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationTypeCard() {
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
              'Select Application Type',
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
                    title: 'New License',
                    icon: FontAwesomeIcons.fileSignature,
                    isSelected: !_isRenewal,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildTypeButton(
                    title: 'Renewal',
                    icon: FontAwesomeIcons.arrowRotateRight,
                    isSelected: _isRenewal,
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
          _isRenewal = title == 'Renewal';
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
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
                'Business Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 16),
              _buildAnimatedDropdown(),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Business Name',
                icon: Icons.business,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Owner Name',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Business Address',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Contact Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              _buildAnimatedTextField(
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDropdown() {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: DropdownButtonFormField<String>(
        value: _selectedLicenseType,
        decoration: InputDecoration(
          labelText: 'License Type',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: _licenseTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              _selectedLicenseType = value;
            });
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a license type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAnimatedTextField({
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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

  Widget _buildDocumentsCard() {
    final documents = _documentRequirements[_selectedLicenseType] ?? [];

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
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue.shade700),
                SizedBox(width: 8),
                Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Please upload the following documents in specified formats',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: documents.length,
              itemBuilder: (context, index) =>
                  _buildDocumentUploadItem(documents[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadItem(Map<String, dynamic> document) {
    Color statusColor;
    IconData statusIcon;

    switch (document['status']) {
      case 'uploaded':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'error':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.upload_file;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
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
                Text(
                  document['description'],
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Text(
                      'Accepted formats: ${document['formats'].join(', ')}',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.storage, size: 16, color: Colors.blue.shade700),
                    SizedBox(width: 4),
                    Text(
                      'Max size: ${document['maxSize']}MB',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (document['file'] != null) ...[
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file,
                            color: Colors.blue.shade700),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            document['file'].path.split('/').last,
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              document['file'] = null;
                              document['status'] = 'pending';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.upload_file),
                        label: Text(document['file'] == null
                            ? 'Upload Document'
                            : 'Change Document'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _uploadDocument(document),
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
      
      // Show bottom sheet with options
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
                    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
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
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      _handlePickedFile(document, File(image.path));
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.file_copy),
                  title: Text('Choose Document'),
                  onTap: () async {
                    Navigator.pop(context);
                    // Note: For actual file picking, you would need to add file_picker package
                    // This is just a placeholder for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Document picking will be implemented soon')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
    }
  }

  void _handlePickedFile(Map<String, dynamic> document, File file) {
    final extension = file.path.split('.').last.toLowerCase();
    
    // Validate file format
    if (!document['formats'].contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid file format. Allowed formats: ${document['formats'].join(', ')}')),
      );
      return;
    }
    
    // Check file size (in MB)
    final fileSize = file.lengthSync() / (1024 * 1024);
    if (fileSize > document['maxSize']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File size exceeds ${document['maxSize']}MB limit')),
      );
      return;
    }
    
    setState(() {
      document['file'] = file;
      document['status'] = 'uploaded';
    });
  }

  void _previewDocument(Map<String, dynamic> document) {
    // Implement document preview based on file type
    if (document['file'] == null) return;

    final extension = document['file'].path.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png'].contains(extension)) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
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
      // For PDF files, you might want to use a PDF viewer package
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF preview not implemented'),
        ),
      );
    }
  }

  Widget _buildFeesCard() {
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
              'License Fees',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 16),
            _buildFeeItem('Application Fee', '₹1,000'),
            _buildFeeItem('Processing Fee', '₹500'),
            _buildFeeItem('License Fee', '₹5,000'),
            Divider(),
            _buildFeeItem('Total', '₹6,500', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeItem(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.blue.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitComplaintData,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isRenewal ? 'Submit Renewal' : 'Submit Application',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _submitComplaintData() async {
    final documents = _documentRequirements[_selectedLicenseType] ?? [];
    final missingRequiredDocs = documents
        .where((doc) => doc['required'] && doc['file'] == null)
        .toList();

    if (missingRequiredDocs.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Missing Documents'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please upload the following required documents:'),
              SizedBox(height: 8),
              ...missingRequiredDocs.map(
                (doc) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text(doc['name']),
                    ],
                  ),
                ),
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
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isSubmitting = false;
      });

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
            'Your application has been submitted successfully. You can track its status in the My Licenses tab.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState?.reset();
                setState(() {
                  // Reset document states
                  final docs =
                      _documentRequirements[_selectedLicenseType] ?? [];
                  for (var doc in docs) {
                    doc['file'] = null;
                    doc['status'] = 'pending';
                  }
                });
                _tabController.animateTo(1); // Switch to My Licenses tab
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting application: $e')),
      );
    }
  }

  Widget _buildMyLicensesTab() {
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
        itemCount: _licenses.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 500 + (index * 100)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: _buildLicenseCard(_licenses[index]),
          );
        },
      ),
    );
  }

  Widget _buildRenewalsTab() {
    final renewalDueLicenses = _licenses
        .where((license) => license['status'] == 'Pending Renewal')
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade700, Colors.blue.shade50],
          stops: [0.0, 0.3],
        ),
      ),
      child: renewalDueLicenses.isEmpty
          ? Center(
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
                    'No Renewals Due',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All your licenses are up to date',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: renewalDueLicenses.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 500 + (index * 100)),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: _buildLicenseCard(
                    renewalDueLicenses[index],
                    showRenewButton: true,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLicenseCard(Map<String, dynamic> license,
      {bool showRenewButton = false}) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showLicenseDetails(license),
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
                      color:
                          _getStatusColor(license['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      license['status'],
                      style: TextStyle(
                        color: _getStatusColor(license['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    'ID: ${license['id']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                license['businessName'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.store, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    license['type'],
                    style: TextStyle(color: Colors.grey),
                  ),
                  Spacer(),
                  Icon(Icons.event, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Valid until: ${license['validUntil']}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (showRenewButton) ...[
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isRenewal = true;
                        _selectedLicenseType = license['type'];
                      });
                      _tabController.animateTo(0);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Renew License'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLicenseDetails(Map<String, dynamic> license) {
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
                license['businessName'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildDetailItem('License ID', license['id']),
              _buildDetailItem('Type', license['type']),
              _buildDetailItem('Owner', license['owner']),
              _buildDetailItem('Status', license['status']),
              _buildDetailItem('Valid Until', license['validUntil']),
              _buildDetailItem('Address', license['address']),
              SizedBox(height: 20),
              if (license['status'] == 'Active')
                ElevatedButton.icon(
                  onPressed: () {
                    // Add download logic
                  },
                  icon: Icon(Icons.download),
                  label: Text('Download License'),
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

  Color _getStatusColor(String status) {
    if (status == 'Active') {
      return Colors.green;
    } else if (status == 'Pending Renewal') {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Text(value),
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
