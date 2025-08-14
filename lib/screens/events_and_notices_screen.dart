import 'package:flutter/material.dart';

class EventsAndNoticesScreen extends StatefulWidget {
  @override
  _EventsAndNoticesScreenState createState() => _EventsAndNoticesScreenState();
}

class _EventsAndNoticesScreenState extends State<EventsAndNoticesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _events = [
    {
      'title': 'City Cleanliness Drive',
      'date': '2024-03-25',
      'time': '9:00 AM',
      'location': 'Lal Bangla Circle',
      'description': 'Join us for a city-wide cleanliness campaign. Bring your enthusiasm and help make our city cleaner!',
      'type': 'Community',
    },
    {
      'title': 'Public Meeting - Development Plan',
      'date': '2024-03-28',
      'time': '11:00 AM',
      'location': 'Town Hall',
      'description': 'Discussion on upcoming infrastructure projects and city development plans.',
      'type': 'Administrative',
    },
    // Add more events...
  ];

  final List<Map<String, dynamic>> _notices = [
    {
      'title': 'Water Supply Interruption',
      'date': '2024-03-24',
      'area': 'Patel Colony',
      'description': 'Due to maintenance work, water supply will be affected from 10 AM to 4 PM.',
      'priority': 'High',
    },
    {
      'title': 'Property Tax Last Date',
      'date': '2024-03-31',
      'area': 'All Areas',
      'description': 'Last date for property tax payment without penalty is March 31, 2024.',
      'priority': 'High',
    },
    // Add more notices...
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
        title: Text('Events & Notices'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Events'),
            Tab(text: 'Notices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildNoticesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add notification subscription logic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notifications enabled')),
          );
        },
        child: Icon(Icons.notifications_active),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Widget _buildEventsTab() {
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
        itemCount: _events.length,
        padding: EdgeInsets.all(16),
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
            child: _buildEventCard(_events[index]),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['type'],
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.calendar_today, size: 20, color: Colors.blue.shade700),
                  SizedBox(width: 8),
                  Text(event['date']),
                ],
              ),
              SizedBox(height: 12),
              Text(
                event['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(event['location']),
                  Spacer(),
                  Icon(Icons.access_time, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(event['time']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticesTab() {
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
        itemCount: _notices.length,
        padding: EdgeInsets.all(16),
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
            child: _buildNoticeCard(_notices[index]),
          );
        },
      ),
    );
  }

  Widget _buildNoticeCard(Map<String, dynamic> notice) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () => _showNoticeDetails(notice),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: notice['priority'] == 'High' 
                          ? Colors.red.shade100 
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      notice['priority'],
                      style: TextStyle(
                        color: notice['priority'] == 'High' 
                            ? Colors.red.shade700 
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.calendar_today, size: 20, color: Colors.blue.shade700),
                  SizedBox(width: 8),
                  Text(notice['date']),
                ],
              ),
              SizedBox(height: 12),
              Text(
                notice['title'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(notice['area']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event['title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['type'],
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildDetailRow(Icons.calendar_today, 'Date', event['date']),
              _buildDetailRow(Icons.access_time, 'Time', event['time']),
              _buildDetailRow(Icons.location_on, 'Location', event['location']),
              SizedBox(height: 20),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                event['description'],
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Add to calendar functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Event added to calendar')),
                  );
                },
                icon: Icon(Icons.calendar_today),
                label: Text('Add to Calendar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showNoticeDetails(Map<String, dynamic> notice) {
    // Similar to _showEventDetails
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}