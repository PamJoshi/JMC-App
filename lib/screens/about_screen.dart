import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 24),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue.shade50,
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.location_city,
                    size: 80,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Jamnagar Municipal Corporation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Digital Services Platform',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Key Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildFeatureCard(
              Icons.home,
              'Property Management',
              'Easy access to property tax payments, registration services, and related documentation.',
            ),
            _buildFeatureCard(
              Icons.water_drop,
              'Water Services',
              'Manage water connections, pay bills, and report issues related to water supply.',
            ),
            _buildFeatureCard(
              Icons.document_scanner,
              'Certificates & Licenses',
              'Apply and track various certificates, permits, and licenses issued by JMC.',
            ),
            _buildFeatureCard(
              Icons.recent_actors,
              'Citizen Services',
              'Access various citizen-centric services and track applications status.',
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About JMC',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Jamnagar Municipal Corporation is committed to providing efficient and transparent civic services to its citizens. This digital platform aims to bring municipal services closer to the citizens, making governance more accessible and citizen-friendly.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Office Address:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                      Text(
                        'Jubilee Garden, Jamnagar,\nGujarat 361001',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                '© 2024 Jamnagar Municipal Corporation\nAll Rights Reserved',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}