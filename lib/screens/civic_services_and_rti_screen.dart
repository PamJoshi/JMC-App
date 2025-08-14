// civic_services_and_rti_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CivicServicesAndRTIScreen extends StatefulWidget {
  @override
  _CivicServicesAndRTIScreenState createState() =>
      _CivicServicesAndRTIScreenState();
}

class _CivicServicesAndRTIScreenState extends State<CivicServicesAndRTIScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  String _selectedService = 'RTI Application';
  String? _selectedFileName;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _applications = [
    {
      'id': 'RTI2024001',
      'type': 'RTI',
      'subject': 'Road Development Project',
      'date': '2024-03-15',
      'status': 'Under Process',
      'department': 'Engineering',
    },
    {
      'id': 'NOC2024002',
      'type': 'NOC',
      'subject': 'Building Construction',
      'date': '2024-03-18',
      'status': 'Completed',
      'department': 'Town Planning',
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'RTI Application',
      'icon': FontAwesomeIcons.fileAlt,
      'description': 'File Right to Information requests',
      'fee': '₹10',
    },
    {
      'title': 'NOC Application',
      'icon': FontAwesomeIcons.certificate,
      'description': 'Apply for No Objection Certificates',
      'fee': '₹500',
    },
    {
      'title': 'Document Verification',
      'icon': FontAwesomeIcons.checkDouble,
      'description': 'Verify municipal documents',
      'fee': '₹100',
    },
    {
      'title': 'Property Documents',
      'icon': FontAwesomeIcons.home,
      'description': 'Request property-related documents',
      'fee': '₹200',
    },
    {
      'title': 'Water Connection',
      'icon': FontAwesomeIcons.water,
      'description': 'Apply for new water connection',
      'fee': '₹300',
      'processingTime': '7 days',
    },
  ];

  // Add new fields for tracking
  final Map<String, List<String>> _applicationSteps = {
    'RTI Application': [
      'Application Submitted',
      'Initial Review',
      'Department Assignment',
      'Information Collection',
      'Final Review',
      'Response Preparation',
      'Completed',
    ],
    'NOC Application': [
      'Application Submitted',
      'Document Verification',
      'Site Inspection',
      'Technical Review',
      'NOC Generation',
      'Completed',
    ],
    'Document Verification': [
      'Document Received',
      'Authenticity Check',
      'Database Verification',
      'Digital Signature',
      'Completed',
    ],
    'Property Documents': [
      'Application Received',
      'Record Search',
      'Document Preparation',
      'Verification',
      'Authentication',
      'Completed',
    ],
    'Water Connection': [
      'Application Submitted',
      'Site Survey',
      'Technical Feasibility',
      'Payment Verification',
      'Connection Setup',
      'Completed',
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Civic Services & RTI'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: 'Services'), Tab(text: 'My Applications')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildServicesTab(), _buildApplicationsTab()],
      ),
    );
  }

  Widget _buildServicesTab() {
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
            _buildServicesGrid(),
            SizedBox(height: 20),
            _buildApplicationForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95, // Made more square
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 500 + (index * 100)),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildServiceCard(_services[index]),
        );
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  service['icon'],
                  size: 32,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                service['title'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                service['description'],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Divider(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.currency_rupee, size: 14),
                  Text(
                    service['fee'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  if (service['processingTime'] != null) ...[
                    Text(' • ', style: TextStyle(fontSize: 14)),
                    Icon(Icons.timer_outlined, size: 14),
                    SizedBox(width: 2),
                    Text(
                      service['processingTime'],
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
                'Application Form',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 20),
              _buildAnimatedDropdown(),
              SizedBox(height: 16),
              _buildServiceSpecificFields(),
              SizedBox(height: 24),
              _buildDocumentUploadSection(),
              SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSpecificFields() {
    switch (_selectedService) {
      case 'RTI Application':
        return Column(
          children: [
            _buildAnimatedTextField(
              label: 'Information Requested',
              icon: Icons.subject,
              maxLines: 3,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Purpose of Information',
              icon: Icons.help_outline,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Time Period',
              icon: Icons.calendar_today,
              hint: 'e.g., Jan 2023 to Dec 2023',
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(label: 'Department', icon: Icons.business),
          ],
        );

      case 'NOC Application':
        return Column(
          children: [
            _buildAnimatedTextField(
              label: 'Property Address',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Purpose of NOC',
              icon: Icons.description,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            _buildAnimatedDropdownField(
              label: 'NOC Type',
              icon: Icons.category,
              items: [
                'Fire Safety',
                'Building Construction',
                'Business Operation',
                'Environmental Clearance',
              ],
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Property Size (sq ft)',
              icon: Icons.square_foot,
              keyboardType: TextInputType.number,
            ),
          ],
        );

      case 'Document Verification':
        return Column(
          children: [
            _buildAnimatedDropdownField(
              label: 'Document Type',
              icon: Icons.description,
              items: [
                'Birth Certificate',
                'Death Certificate',
                'Marriage Certificate',
                'Property Documents',
                'Educational Documents',
              ],
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Document Number',
              icon: Icons.numbers,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Issue Date',
              icon: Icons.calendar_today,
              hint: 'DD/MM/YYYY',
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Issuing Authority',
              icon: Icons.account_balance,
            ),
          ],
        );

      case 'Property Documents':
        return Column(
          children: [
            _buildAnimatedTextField(
              label: 'Property Address',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            _buildAnimatedDropdownField(
              label: 'Document Type',
              icon: Icons.description,
              items: [
                'Property Card',
                'Tax Assessment',
                'Building Permission',
                'Occupancy Certificate',
                'Property Registration',
              ],
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Property ID/Survey Number',
              icon: Icons.pin,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(label: 'Owner Name', icon: Icons.person),
          ],
        );

      case 'Water Connection':
        return Column(
          children: [
            _buildAnimatedTextField(
              label: 'Property Address',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            SizedBox(height: 16),
            _buildAnimatedDropdownField(
              label: 'Connection Type',
              icon: Icons.water_drop,
              items: ['Residential', 'Commercial', 'Industrial', 'Temporary'],
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Plot Size (sq ft)',
              icon: Icons.square_foot,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            _buildAnimatedTextField(
              label: 'Number of Units/Floors',
              icon: Icons.apartment,
              keyboardType: TextInputType.number,
            ),
          ],
        );

      default:
        return Container();
    }
  }

  Widget _buildAnimatedDropdown() {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: DropdownButtonFormField<String>(
        value: _selectedService,
        decoration: InputDecoration(
          labelText: 'Service Type',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items:
            _services.map((service) {
              return DropdownMenuItem<String>(
                value: service['title'],
                child: Text(service['title']),
              );
            }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selectedService = value!;
          });
        },
      ),
    );
  }

  Widget _buildAnimatedDropdownField({
    required String label,
    required IconData icon,
    required List<String> items,
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
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: (String? value) {
          setState(() {});
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
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
    String? hint,
    TextInputType? keyboardType,
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
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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

  Widget _buildDocumentUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supporting Documents',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.upload_file, color: Colors.blue.shade700),
              SizedBox(width: 12),
              Expanded(
                child: Text(_selectedFileName ?? 'Upload relevant documents'),
              ),
              TextButton(
                onPressed: () {
                  // Simulate file picker
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Select Document Type'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.picture_as_pdf),
                                title: Text('Sample_Document.pdf'),
                                onTap: () {
                                  setState(
                                    () =>
                                        _selectedFileName =
                                            'Sample_Document.pdf',
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Document selected successfully',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.image),
                                title: Text('ID_Proof.jpg'),
                                onTap: () {
                                  setState(
                                    () => _selectedFileName = 'ID_Proof.jpg',
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Document selected successfully',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                  );
                },
                child: Text('Browse'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            _isSubmitting
                ? null
                : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isSubmitting = true);

                    // Simulate API call
                    await Future.delayed(Duration(seconds: 2));

                    setState(() => _isSubmitting = false);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Application submitted successfully!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );

                    // Clear form
                    _formKey.currentState!.reset();
                    setState(() => _selectedFileName = null);

                    // Switch to applications tab
                    _tabController.animateTo(1);
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child:
            _isSubmitting
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Submit Application', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildApplicationsTab() {
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
        onTap: () => _showApplicationStatus(application),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Application ID: ${application['id']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          application['status'] == 'Completed'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      application['status'],
                      style: TextStyle(
                        color:
                            application['status'] == 'Completed'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(application['subject'], style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text(
                'Type: ${application['type']}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                'Department: ${application['department']}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                'Submitted: ${application['date']}',
                style: TextStyle(color: Colors.grey.shade600),
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
      case 'under process':
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
                        application['subject'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildDetailItem('Application ID', application['id']),
                      _buildDetailItem('Type', application['type']),
                      _buildDetailItem('Department', application['department']),
                      _buildDetailItem('Status', application['status']),
                      _buildDetailItem('Date', application['date']),
                      SizedBox(height: 20),
                      if (application['status'] == 'Completed')
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Document downloaded successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          icon: Icon(Icons.download),
                          label: Text('Download Document'),
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

  // Add method to show service details
  void _showServiceDetails(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(service['icon'], color: Colors.blue.shade700),
                SizedBox(width: 10),
                Text(service['title']),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Service Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(service['description']),
                  SizedBox(height: 16),
                  Text(
                    'Required Documents',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ..._getRequiredDocuments(service['title']).map(
                    (doc) => Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16),
                          SizedBox(width: 8),
                          Text(doc),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Process Steps',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ..._applicationSteps[service['title']]!.map(
                    (step) => Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_right, size: 16),
                          SizedBox(width: 8),
                          Text(step),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Fee Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Application Fee: ${service['fee']}'),
                  if (service['processingTime'] != null)
                    Text('Processing Time: ${service['processingTime']}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _selectedService = service['title']);
                  _tabController.animateTo(0);
                },
                child: Text('Apply Now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }

  List<String> _getRequiredDocuments(String serviceType) {
    switch (serviceType) {
      case 'RTI Application':
        return ['Valid ID Proof', 'Address Proof', 'Application Letter'];
      case 'NOC Application':
        return [
          'Property Documents',
          'ID Proof',
          'Site Plan',
          'Previous NOCs (if any)',
        ];
      case 'Document Verification':
        return ['Original Document', 'ID Proof', 'Application Form'];
      case 'Property Documents':
        return [
          'Property Ownership Proof',
          'Tax Receipts',
          'ID Proof',
          'Address Proof',
        ];
      case 'Water Connection':
        return [
          'Property Documents',
          'ID Proof',
          'Site Plan',
          'NOC from Society',
        ];
      default:
        return ['ID Proof', 'Address Proof'];
    }
  }

  // Add method to show application status
  void _showApplicationStatus(Map<String, dynamic> application) {
    final steps = _applicationSteps[application['type']] ?? [];
    final currentStepIndex = steps.indexOf(application['status']);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Application Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Application ID: ${application['id']}'),
                Text('Type: ${application['type']}'),
                Text('Subject: ${application['subject']}'),
                Text('Department: ${application['department']}'),
                Text('Submitted: ${application['date']}'),
                SizedBox(height: 16),
                Text(
                  'Progress',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                ...steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Icon(
                          index <= currentStepIndex
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              index <= currentStepIndex
                                  ? Colors.green
                                  : Colors.grey,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          step,
                          style: TextStyle(
                            color:
                                index <= currentStepIndex
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
