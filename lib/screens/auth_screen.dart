import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isAadhaar = true; // Toggle between Aadhaar and Phone
  String _identifier = ''; // Aadhaar or Phone number
  String _password = '';
  bool _isLoading = false;
  bool _showPassword = false;
  
  // For OTP verification
  bool _isOtpScreen = false;
  String _otp = '';
  
  void _toggleIdentifierType() {
    setState(() {
      _isAadhaar = !_isAadhaar;
      _identifier = '';
    });
  }

  Future<void> _sendOtp() async {
    if (_identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your ${_isAadhaar ? 'Aadhaar number' : 'phone number'}')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final success = await AuthService.sendOtp(_identifier);
      if (success) {
        setState(() {
          _isOtpScreen = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent successfully')),
        );
      } else {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtpAndResetPassword() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final success = await AuthService.verifyOtp(_identifier, _otp);
      if (success) {
        setState(() {
          _isOtpScreen = false;
          _isLoading = false;
        });
        _showResetPasswordDialog();
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _showResetPasswordDialog() {
    String newPassword = '';
    String confirmPassword = '';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => newPassword = value,
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => confirmPassword = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isOtpScreen = false);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPassword.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwords do not match')),
                );
                return;
              }
              
              try {
                final success = await AuthService.resetPassword(_identifier, newPassword);
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password reset successfully')),
                  );
                } else {
                  throw Exception('Failed to reset password');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to reset password. Please try again.')),
                );
              }
            },
            child: Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    
    try {
      await AuthService.login(_identifier, _password);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isOtpScreen) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Verify OTP'),
          backgroundColor: Colors.blue.shade700,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the OTP sent to your ${_isAadhaar ? 'registered mobile number' : 'phone number'}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (value) => _otp = value,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtpAndResetPassword,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Verify OTP'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: Text('Resend OTP'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login with: '),
                  TextButton(
                    onPressed: _toggleIdentifierType,
                    child: Text(
                      _isAadhaar ? 'Switch to Phone' : 'Switch to Aadhaar',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: _isAadhaar ? 'Aadhaar Number' : 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(_isAadhaar ? Icons.credit_card : Icons.phone),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_isAadhaar ? 12 : 10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  if (_isAadhaar && value.length != 12) {
                    return 'Aadhaar number must be 12 digits';
                  }
                  if (!_isAadhaar && value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
                onSaved: (value) => _identifier = value ?? '',
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                ),
                obscureText: !_showPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
                onSaved: (value) => _password = value ?? '',
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 