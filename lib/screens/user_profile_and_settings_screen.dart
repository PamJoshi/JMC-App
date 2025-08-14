// user_profile_and_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserProfileAndSettingsScreen extends StatefulWidget {
  @override
  _UserProfileAndSettingsScreenState createState() => _UserProfileAndSettingsScreenState();
}

class _UserProfileAndSettingsScreenState extends State<UserProfileAndSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  
  // User Profile Data with default values
  final Map<String, String> _userData = {
    'name': '',
    'email': '',
    'phone': '',
    'address': '',
    'ward': '',
  };

  // Settings
  bool _notifyBills = true;
  bool _notifyComplaints = true;
  bool _notifyUpdates = true;
  bool _notifyEmergency = true;
  String _language = 'English';
  String _theme = 'Light';
  bool _useBiometric = false;
  bool _showProfileInfo = true;

  // Personal Contacts
  List<Map<String, dynamic>> _personalContacts = [];

  // Activity Data
  final List<Map<String, dynamic>> _recentActivity = [
    {
      'type': 'payment',
      'title': 'Property Tax Payment',
      'amount': '₹5,000',
      'date': '2024-02-20',
      'status': 'Completed',
    },
    {
      'type': 'complaint',
      'title': 'Street Light Issue',
      'id': 'COM123456',
      'date': '2024-02-18',
      'status': 'In Progress',
    },
    {
      'type': 'application',
      'title': 'Birth Certificate',
      'id': 'CERT789012',
      'date': '2024-02-15',
      'status': 'Approved',
    },
    {
      'type': 'feedback',
      'title': 'App Feedback',
      'date': '2024-02-10',
      'status': 'Submitted',
    },
  ];

  final List<String> _languages = [
    'English',
    'हिंदी',
    'ગુજરાતી',
    'मराठी',
    'తెలుగు',
    'தமிழ்',
  ];

  final List<String> _themes = [
    'Light',
    'Dark',
    'System',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData(); // Load data when screen initializes
  }

  @override
  void dispose() {
    _saveUserData(); // Add this line
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load all user data
      final userMap = {
        'name': prefs.getString('user_name'),
        'email': prefs.getString('user_email'),
        'phone': prefs.getString('user_phone'),
        'address': prefs.getString('user_address'),
        'ward': prefs.getString('user_ward'),
      };

      // Only update state if data exists
      if (!mounted) return;
      
      setState(() {
        _userData.clear(); // Clear existing data
        userMap.forEach((key, value) {
          if (value != null) {
            _userData[key] = value;
          }
        });
      });

      // Load settings
      if (!mounted) return;
      setState(() {
        _notifyBills = prefs.getBool('notify_bills') ?? true;
        _notifyComplaints = prefs.getBool('notify_complaints') ?? true;
        _notifyUpdates = prefs.getBool('notify_updates') ?? true;
        _notifyEmergency = prefs.getBool('notify_emergency') ?? true;
        _language = prefs.getString('language') ?? 'English';
        _theme = prefs.getString('theme') ?? 'Light';
        _useBiometric = prefs.getBool('use_biometric') ?? false;
        _showProfileInfo = prefs.getBool('show_profile_info') ?? true;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadPersonalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getStringList('personal_contacts') ?? [];
    setState(() {
      _personalContacts = contactsJson.map((contact) => Map<String, dynamic>.from(json.decode(contact))).toList();
    });
  }

  Future<void> _savePersonalContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = _personalContacts.map((contact) => json.encode(contact)).toList();
    await prefs.setStringList('personal_contacts', contactsJson);
  }

  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save all user data immediately when modified
      await Future.wait([
        prefs.setString('user_name', _userData['name'] ?? ''),
        prefs.setString('user_email', _userData['email'] ?? ''),
        prefs.setString('user_phone', _userData['phone'] ?? ''),
        prefs.setString('user_address', _userData['address'] ?? ''),
        prefs.setString('user_ward', _userData['ward'] ?? ''),
      ]);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState?.save(); // Add this line to save form data
    
    setState(() => _isLoading = true);
    
    try {
      await _saveUserData();
      setState(() => _isEditing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSettings(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      switch (key) {
        case 'notify_bills':
          _notifyBills = value;
          prefs.setBool('notify_bills', value);
          break;
        case 'notify_complaints':
          _notifyComplaints = value;
          prefs.setBool('notify_complaints', value);
          break;
        case 'notify_updates':
          _notifyUpdates = value;
          prefs.setBool('notify_updates', value);
          break;
        case 'notify_emergency':
          _notifyEmergency = value;
          prefs.setBool('notify_emergency', value);
          break;
        case 'language':
          _language = value;
          prefs.setString('language', value);
          break;
        case 'theme':
          _theme = value;
          prefs.setString('theme', value);
          break;
        case 'use_biometric':
          _useBiometric = value;
          prefs.setBool('use_biometric', value);
          break;
        case 'show_profile_info':
          _showProfileInfo = value;
          prefs.setBool('show_profile_info', value);
          break;
      }
    });
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            Text(
              'Note: All your data, including:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Payment history'),
            Text('• Complaints and feedback'),
            Text('• Documents and certificates'),
            Text('• Personal information'),
            Text('will be permanently deleted.'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion initiated'),
                  backgroundColor: Colors.red,
            ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveUserData(); // Save data before leaving
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile & Settings'),
          backgroundColor: Colors.blue.shade700,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
              Tab(icon: Icon(Icons.history), text: 'Activity'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildSettingsTab(),
            _buildActivityTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: NetworkImage('https://example.com/profile.jpg'),
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  if (_isEditing)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        radius: 18,
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          onPressed: () {
                            // TODO: Implement image upload
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Image upload coming soon')),
                            );
                          },
                        ),
                      ),
                    ),
                ],
            ),
          ),
            SizedBox(height: 24),
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
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _isEditing ? Icons.save : Icons.edit,
                  color: Colors.blue.shade700,
                ),
                          onPressed: () {
                            if (_isEditing) {
                              _updateProfile();
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField('name', 'Full Name', Icons.person),
                    SizedBox(height: 16),
                    _buildTextFormField('email', 'Email', Icons.email),
                    SizedBox(height: 16),
                    _buildTextFormField('phone', 'Phone', Icons.phone),
                    SizedBox(height: 16),
                    _buildTextFormField('address', 'Address', Icons.location_on, maxLines: 2),
                    SizedBox(height: 16),
                    _buildTextFormField('ward', 'Ward Number', Icons.apartment),
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
                      'Identity Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: '1234 5678 9012',
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Aadhaar Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                    ),
                    SizedBox(height: 24),
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.white),
                                    SizedBox(width: 16),
                                    Text('Updating...'),
                                  ],
                                )
                              : Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                  ],
              ),
            ),
        )],
        ),
      ),
    );
  }

  Widget _buildTextFormField(String key, String label, IconData icon, {int maxLines = 1}) {
    final TextEditingController _controller = TextEditingController(text: _userData[key]);
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    
    return TextFormField(
      controller: _controller,
      enabled: _isEditing,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (key == 'email' && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _userData[key] = value;
        });
      },
      onEditingComplete: () {
        _saveUserData();
      },
    );
  }

  Widget _buildSettingsTab() {
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
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                  ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Bill Payment Reminders'),
                    subtitle: Text('Get notified about upcoming bills'),
                    value: _notifyBills,
                    onChanged: (value) => _updateSettings('notify_bills', value),
                  ),
                  SwitchListTile(
                    title: Text('Complaint Updates'),
                    subtitle: Text('Get notified about complaint status'),
                    value: _notifyComplaints,
                    onChanged: (value) => _updateSettings('notify_complaints', value),
                  ),
                  SwitchListTile(
                    title: Text('App Updates'),
                    subtitle: Text('Get notified about new features'),
                    value: _notifyUpdates,
                    onChanged: (value) => _updateSettings('notify_updates', value),
                  ),
                  SwitchListTile(
                    title: Text('Emergency Alerts'),
                    subtitle: Text('Get notified about emergencies'),
                    value: _notifyEmergency,
                    onChanged: (value) => _updateSettings('notify_emergency', value),
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
                    'Appearance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _language,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                    items: _languages.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        _updateSettings('language', value);
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _theme,
                    decoration: InputDecoration(
                      labelText: 'Theme',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.palette),
                    ),
                    items: _themes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        _updateSettings('theme', value);
                      }
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
                    'Security',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.lock),
                    title: Text('Change Password'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Implement password change
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password change coming soon')),
              );
            },
          ),
                  SwitchListTile(
                    title: Text('Biometric Authentication'),
                    subtitle: Text('Use fingerprint or face ID'),
                    value: _useBiometric,
                    onChanged: (value) => _updateSettings('use_biometric', value),
                  ),
                  SwitchListTile(
                    title: Text('Show Profile Info'),
                    subtitle: Text('Display personal information'),
                    value: _showProfileInfo,
                    onChanged: (value) => _updateSettings('show_profile_info', value),
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
                    'Account',
                style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.orange),
                    title: Text('Logout'),
                    onTap: () {
                      // TODO: Implement logout
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout coming soon')),
                      );
                    },
              ),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _showDeleteAccountDialog,
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _recentActivity.length,
      itemBuilder: (context, index) {
        final activity = _recentActivity[index];
    return Card(
          elevation: 4,
          margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
            leading: _buildActivityIcon(activity['type']),
            title: Text(activity['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Date: ${activity['date']}'),
                if (activity['amount'] != null)
                  Text('Amount: ${activity['amount']}'),
                if (activity['id'] != null)
                  Text('ID: ${activity['id']}'),
              ],
            ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(activity['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            activity['status'],
            style: TextStyle(
              color: _getStatusColor(activity['status']),
                  fontSize: 12,
            ),
          ),
        ),
            onTap: () {
              // TODO: Implement activity detail view
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Activity details coming soon')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActivityIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'payment':
        icon = Icons.payment;
        color = Colors.green;
        break;
      case 'complaint':
        icon = Icons.report_problem;
        color = Colors.orange;
        break;
      case 'application':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'feedback':
        icon = Icons.feedback;
        color = Colors.purple;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

