import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

import 'service_details_screen.dart';
import 'trade_license_and_permits_screen.dart';
import 'user_profile_and_settings_screen.dart';
import 'complaints_and_grievances_screen.dart';
import 'civic_services_and_rti_screen.dart';
import 'emergency_helplines_screen.dart';
import 'events_and_notices_screen.dart';
import 'feedback_and_surveys_screen.dart';
import 'public_transport_and_parking_screen.dart';
import 'street_light_maintenance_screen.dart';
import 'waste_management_screen.dart';
// import 'water_services_screen.dart';
import 'birth_and_death_certificate_screen.dart';
import 'chatbot_screen.dart';
import 'contact_screen.dart';
import 'about_screen.dart';
import '../services/auth_service.dart';
import 'auth/auth_screen.dart';
import 'water_and_drainage_services_screen.dart';

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
    : super(
        transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutCubic;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
}

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> services = [
    {
      "name": "Property Tax",
      "icon": FontAwesomeIcons.home,
      "content": [
        "View property details",
        "Pay property tax online",
        "Download tax receipts",
        "Check payment history",
      ],
    },
    {
      "name": "Water & Drainage Services",
      "icon": FontAwesomeIcons.water,
      "content": [
        "Apply for new connection",
        "Pay water bills",
        "Report water supply issues",
        "Request drainage cleaning",
      ],
    },
    {
      "name": "Complaints & Grievances",
      "icon": FontAwesomeIcons.commentDots,
      "content": [
        "File new complaint",
        "Track complaint status",
        "View complaint history",
      ],
    },
    {
      "name": "Birth & Death Certificates",
      "icon": FontAwesomeIcons.certificate,
      "content": [
        "Apply for certificates",
        "Track application status",
        "Download e-certificates",
      ],
    },
    {
      "name": "Trade License & Permits",
      "icon": FontAwesomeIcons.fileContract,
      "content": [
        "Apply for new license",
        "Renew existing license",
        "Check application status",
      ],
    },
    {
      "name": "Waste Management",
      "icon": FontAwesomeIcons.recycle,
      "content": [
        "View collection schedule",
        "Request special pickup",
        "Report issues",
      ],
    },
    {
      "name": "Street Light Maintenance",
      "icon": FontAwesomeIcons.lightbulb,
      "content": [
        "Report faulty streetlights",
        "Track repair status",
        "View maintenance schedule",
      ],
    },
    {
      "name": "Public Transport & Parking",
      "icon": FontAwesomeIcons.bus,
      "content": ["View bus routes", "Book parking spots", "Pay parking fines"],
    },
    {
      "name": "Emergency Helplines",
      "icon": FontAwesomeIcons.phone,
      "content": [
        "Emergency contacts",
        "Report emergencies",
        "Find nearest facilities",
      ],
    },
    {
      "name": "Events & Notices",
      "icon": FontAwesomeIcons.calendar,
      "content": [
        "Upcoming events",
        "Public notices",
        "Important announcements",
      ],
    },
    {
      "name": "Feedback & Surveys",
      "icon": FontAwesomeIcons.comment,
      "content": [
        "Submit feedback",
        "Participate in surveys",
        "View improvements",
      ],
    },
    {
      "name": "Civic Services & RTI",
      "icon": FontAwesomeIcons.landmark,
      "content": [
        "File RTI applications",
        "Track RTI status",
        "Access public documents",
      ],
    },
    {
      "name": "User Profile & Settings",
      "icon": FontAwesomeIcons.userCog,
      "content": [
        "Update profile",
        "Manage notifications",
        "View activity history",
      ],
    },
  ];

  final Map<String, Widget> _services = {
    'Water & Drainage Services': WaterAndDrainageServicesScreen(),
    // ... other services ...
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Jamnagar Municipal Corporation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder(
                      duration: Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          color: Colors.blue.shade700,
                          size: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'JMC Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Your City, Your Services',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _buildAnimatedListTile(
                icon: Icons.home,
                title: 'Home',
                onTap: () => Navigator.pop(context),
                delay: 100,
              ),
              _buildAnimatedListTile(
                icon: Icons.info,
                title: 'About',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CustomPageRoute(child: AboutScreen()),
                  );
                },
                delay: 200,
              ),
              _buildAnimatedListTile(
                icon: Icons.contact_mail,
                title: 'Contact',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    CustomPageRoute(child: ContactScreen()),
                  );
                },
                delay: 300,
              ),
              _buildAnimatedListTile(
                icon: Icons.chat,
                title: 'Chatbot',
                onTap: () {
                  Navigator.push(
                    context,
                    CustomPageRoute(child: ChatbotScreen()),
                  );
                },
                delay: 400,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.blue.shade50],
            stops: [0.0, 0.3],
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            return _buildServiceCard(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _handleServiceTap(context, index),
        child: Hero(
          tag: 'service_${services[index]['name']}',
          child: Material(
            color: Colors.transparent,
            child: Card(
              elevation: 4,
              shadowColor: Colors.blue.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.blue.shade50],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildServiceIcon(index),
                    SizedBox(height: 12),
                    _buildServiceName(index),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceIcon(int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade100.withOpacity(0.3),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade100.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          services[index]['icon'],
          size: 32,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildServiceName(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        services[index]['name'],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _handleServiceTap(BuildContext context, int index) {
    final screens = {
      'Trade License & Permits': TradeLicenseAndPermitsScreen(),
      'User Profile & Settings': UserProfileAndSettingsScreen(),
      'Birth & Death Certificates': BirthAndDeathCertificateScreen(),
      'Complaints & Grievances': ComplaintsAndGrievancesScreen(),
      'Civic Services & RTI': CivicServicesAndRTIScreen(),
      'Emergency Helplines': EmergencyHelplinesScreen(),
      'Events & Notices': EventsAndNoticesScreen(),
      'Feedback & Surveys': FeedbackAndSurveysScreen(),
      'Public Transport & Parking': PublicTransportAndParkingScreen(),
      'Street Light Maintenance': StreetLightMaintenanceScreen(),
      'Waste Management': WasteManagementScreen(),
      'Water & Drainage Services': WaterAndDrainageServicesScreen(),
    };

    final serviceName = services[index]['name'];
    final screen =
        screens[serviceName] ??
        ServiceDetailsScreen(
          serviceName: serviceName,
          serviceContent: services[index]['content'],
        );

    Navigator.push(context, CustomPageRoute(child: screen));
  }

  Widget _buildAnimatedListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(-100 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.transparent,
        hoverColor: Colors.blue.shade50,
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
    );
  }
}
