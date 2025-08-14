// service_details_screen.dart
import 'package:flutter/material.dart';
import 'base_service_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceName;
  final List<String> serviceContent;
  final IconData icon;

  ServiceDetailsScreen({
    required this.serviceName,
    required this.serviceContent,
    this.icon = Icons.info,
  });

  @override
  Widget build(BuildContext context) {
    return BaseServiceScreen(
      title: serviceName,
      content: serviceContent,
      icon: icon,
    );
  }
}