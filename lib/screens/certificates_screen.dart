import 'package:flutter/material.dart';

class CertificatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificates'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Certificates',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildCertificateCard(
              context,
              'Birth Certificate',
              Icons.child_care,
              'Apply for birth certificate',
            ),
            _buildCertificateCard(
              context,
              'Death Certificate',
              Icons.person_off_outlined,
              'Apply for death certificate',
            ),
            _buildCertificateCard(
              context,
              'Property Tax Certificate',
              Icons.home_outlined,
              'Get property tax paid certificate',
            ),
            _buildCertificateCard(
              context,
              'Building Permission',
              Icons.business,
              'Apply for building permission',
            ),
            _buildCertificateCard(
              context,
              'Trade License',
              Icons.store_outlined,
              'Apply for trade license',
            ),
            _buildCertificateCard(
              context,
              'NOC Certificate',
              Icons.verified_outlined,
              'Apply for NOC',
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildCertificateCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Processing time: 3-5 working days',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _CertificateApplicationScreen(
                certificateType: title,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CertificateApplicationScreen extends StatefulWidget {
  final String certificateType;

  const _CertificateApplicationScreen({required this.certificateType});

  @override
  _CertificateApplicationScreenState createState() =>
      _CertificateApplicationScreenState();
}

class _CertificateApplicationScreenState
    extends State<_CertificateApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _purposeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for ${widget.certificateType}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
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
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildRequirementItem('Valid ID Proof'),
                      _buildRequirementItem('Address Proof'),
                      _buildRequirementItem('Passport Size Photo'),
                      if (widget.certificateType == 'Birth Certificate')
                        _buildRequirementItem('Hospital Certificate'),
                      if (widget.certificateType == 'Death Certificate')
                        _buildRequirementItem('Medical Certificate'),
                      if (widget.certificateType == 'Trade License')
                        _buildRequirementItem('Business Registration'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: InputDecoration(
                  labelText: 'Purpose of Certificate',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purpose';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Implement document upload
                      },
                      icon: Icon(Icons.upload_file),
                      label: Text('Upload Documents'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showApplicationSubmitted(context);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Submit Application'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _showApplicationSubmitted(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Application Submitted'),
        content: Text(
          'Your application for ${widget.certificateType} has been submitted successfully.\n\n'
          'Application ID: CERT${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}\n\n'
          'You will receive updates about your application status via SMS and email.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                ..pop() // Close dialog
                ..pop(); // Return to certificates list
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
} 