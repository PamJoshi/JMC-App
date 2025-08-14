import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _authKey = 'auth_user';
  static const String _identifierKey = 'identifier';
  static const String _identifierTypeKey = 'identifier_type';

  // Default admin credentials
  static const String defaultAadhaar = '123456789999';
  static const String defaultPassword = '112233';

  static Future<void> login(String identifier, String password) async {
    // Validate identifier format first
    if (identifier.length != 12 && identifier.length != 10) {
      throw Exception('Invalid identifier length');
    }

    // Check for default admin credentials
    if (identifier == defaultAadhaar && password == defaultPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authKey, 'admin');
      await prefs.setString(_identifierKey, identifier);
      await prefs.setString(_identifierTypeKey, 'aadhaar');
      return;
    }

    // Validate identifier format
    if (identifier.length == 12) {
      // Aadhaar validation
      if (!_isValidAadhaar(identifier)) {
        throw Exception('Invalid Aadhaar number format');
      }
    } else if (identifier.length == 10) {
      // Phone validation
      if (!_isValidPhone(identifier)) {
        throw Exception('Invalid phone number format');
      }
    }

    // For testing purposes, allow login with password "123456"
    if (password == "123456") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authKey, 'user');
      await prefs.setString(_identifierKey, identifier);
      await prefs.setString(
          _identifierTypeKey, identifier.length == 12 ? 'aadhaar' : 'phone');
      return;
    }

    // If none of the above conditions are met
    throw Exception(
        'Invalid credentials. Please check your Aadhaar/Phone and password.');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_identifierKey);
    await prefs.remove(_identifierTypeKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authKey) != null;
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'identifier': prefs.getString(_identifierKey),
      'type': prefs.getString(_identifierTypeKey),
      'isAdmin': prefs.getString(_authKey) == 'admin' ? 'true' : 'false',
    };
  }

  static Future<bool> sendOtp(String identifier) async {
    // For admin account, always return true
    if (identifier == defaultAadhaar) {
      return true;
    }

    // Validate identifier
    if (identifier.length != 10 && identifier.length != 12) {
      throw Exception('Invalid identifier');
    }

    if (identifier.length == 12 && !_isValidAadhaar(identifier)) {
      throw Exception('Invalid Aadhaar number');
    }

    if (identifier.length == 10 && !_isValidPhone(identifier)) {
      throw Exception('Invalid phone number');
    }

    // TODO: Replace with actual OTP sending API call
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  static Future<bool> verifyOtp(String identifier, String otp) async {
    // For admin account, accept any 6-digit OTP
    if (identifier == defaultAadhaar && otp.length == 6) {
      return true;
    }

    // TODO: Replace with actual OTP verification API call
    await Future.delayed(Duration(seconds: 2));
    return otp == '123456'; // For testing purposes
  }

  static Future<bool> resetPassword(
      String identifier, String newPassword) async {
    // For admin account
    if (identifier == defaultAadhaar) {
      // Don't allow changing admin password through reset
      throw Exception('Cannot reset admin password');
    }

    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // TODO: Replace with actual password reset API call
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  // Validation helpers
  static bool _isValidAadhaar(String aadhaar) {
    // Basic Aadhaar validation
    return aadhaar.length == 12 && int.tryParse(aadhaar) != null;
  }

  static bool _isValidPhone(String phone) {
    // Basic Indian phone number validation
    return phone.length == 10 &&
        int.tryParse(phone) != null &&
        (phone.startsWith('6') ||
            phone.startsWith('7') ||
            phone.startsWith('8') ||
            phone.startsWith('9'));
  }
}
