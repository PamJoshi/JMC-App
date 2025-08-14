// chatbot_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'property_tax_screen.dart';
import 'water_and_drainage_services_screen.dart';
import 'complaints_and_grievances_screen.dart';
import 'certificates_screen.dart';
import 'emergency_helplines_screen.dart';
import 'payment_screen.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final String? attachmentType; // 'image', 'link', 'document'
  final String? attachmentUrl;
  final Map<String, dynamic>? actionData; // For deep linking
  final String? suggestionType; // 'service', 'form', 'contact', etc.

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.quickReplies,
    this.attachmentType,
    this.attachmentUrl,
    this.actionData,
    this.suggestionType,
  });
}

class BotResponse {
  static final Map<String, dynamic> responses = {
    'greeting': {
      'patterns': ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening'],
      'responses': [
        'Hello! How can I assist you with JMC services today?',
        'Hi there! What can I help you with?',
        'Welcome! How may I help you?'
      ],
      'quickReplies': [
        'Property Tax',
        'Water Services',
        'File Complaint',
        'Apply for Certificate'
      ]
    },
    'property_tax': {
      'patterns': ['property tax', 'house tax', 'tax payment', 'tax due', 'property bill'],
      'responses': [
        'Here are the Property Tax services available:\n\n'
        '📊 Current Status:\n'
        '• View tax assessment\n'
        '• Check payment history\n'
        '• Download tax receipts\n'
        '• View due dates\n\n'
        '💳 Payment Options:\n'
        '• Online payment\n'
        '• Mobile payment\n'
        '• Bank transfer\n'
        '• Cash payment at JMC office\n\n'
        '📝 Other Services:\n'
        '• Apply for reassessment\n'
        '• Update property details\n'
        '• Register new property\n'
        '• File objections',
      ],
      'quickReplies': [
        '💰 Pay Now',
        '📱 View Bill',
        '📄 Download Receipt',
        '📋 View History',
        '🏠 Update Details',
        '❓ Calculate Tax'
      ],
      'attachmentType': 'link',
      'attachmentUrl': 'https://jmc.gujarat.gov.in/property-tax',
      'actionData': {
        'type': 'service',
        'screen': 'PropertyTaxScreen',
        'helpline': '0288-2550231',
        'dueDates': {
          'first': 'June 30',
          'second': 'December 31'
        },
        'paymentModes': [
          'Online Banking',
          'Credit/Debit Card',
          'UPI',
          'Net Banking',
          'Cash at JMC Office'
        ]
      }
    },
    'property_tax_calculation': {
      'patterns': ['calculate tax', 'tax rate', 'property value', 'assessment'],
      'responses': [
        'Property Tax calculation is based on:\n\n'
        '🏠 Property Factors:\n'
        '• Built-up area\n'
        '• Property type\n'
        '• Location zone\n'
        '• Usage type\n\n'
        '💰 Rate Structure:\n'
        '• Residential: 0.5% to 1%\n'
        '• Commercial: 1% to 2%\n'
        '• Industrial: 1.5% to 2.5%\n\n'
        'Would you like to use our tax calculator?',
      ],
      'quickReplies': [
        '🧮 Use Calculator',
        '📊 View Rate Card',
        '🗺️ Check Zone',
        '📞 Get Assistance'
      ]
    },
    'property_tax_payment': {
      'patterns': ['pay tax', 'payment options', 'tax payment', 'online payment'],
      'responses': [
        'Choose your preferred payment method:\n\n'
        '🌐 Online Payment:\n'
        '• Credit/Debit Card\n'
        '• Net Banking\n'
        '• UPI\n'
        '• Digital Wallets\n\n'
        '🏢 Offline Payment:\n'
        '• JMC Office\n'
        '• Authorized Banks\n'
        '• Citizen Service Centers\n\n'
        '💡 Early Payment Discount: 5%\n'
        '⚠️ Late Payment Penalty: 2% per month',
      ],
      'quickReplies': [
        '💳 Pay Online',
        '🏢 Find Centers',
        '📅 Due Dates',
        '🏷️ View Discounts'
      ],
      'actionData': {
        'type': 'payment',
        'screen': 'PaymentScreen',
        'category': 'property_tax'
      }
    },
    'water_services': {
      'patterns': ['water', 'water bill', 'connection', 'drainage'],
      'responses': [
        'Our Water Services include:\n\n'
        '• New water connection\n'
        '• Water bill payment\n'
        '• Report water issues\n'
        '• Check supply timing',
      ],
      'quickReplies': [
        'New Connection',
        'Pay Water Bill',
        'Report Issue',
        'Supply Schedule'
      ]
    },
    'certificates': {
      'patterns': ['birth', 'death', 'certificate'],
      'responses': [
        'For Birth/Death Certificates:\n\n'
        '• Apply online\n'
        '• Track application\n'
        '• Download e-certificate\n'
        '• Check requirements',
      ],
      'quickReplies': [
        'Apply for Certificate',
        'Track Application',
        'Requirements',
        'Contact Support'
      ]
    },
    'complaints': {
      'patterns': ['complaint', 'issue', 'problem', 'grievance'],
      'responses': [
        'To file a complaint:\n\n'
        '• Choose complaint category\n'
        '• Provide details and location\n'
        '• Attach photos (if any)\n'
        '• Track resolution status',
      ],
      'quickReplies': [
        'File New Complaint',
        'Track Complaint',
        'Emergency Contact',
        'View Guidelines'
      ]
    },
    'help': {
      'patterns': ['help', 'support', 'contact', 'emergency'],
      'responses': [
        'Contact JMC:\n\n'
        '• Main Office: 0288-2550231\n'
        '• Emergency: 0288-2551231\n'
        '• Email: info@jmc.gov.in\n'
        '• Visit: Race Course Road, Jamnagar',
      ],
      'quickReplies': [
        'Call Helpline',
        'Send Email',
        'View Location',
        'Working Hours'
      ]
    },
    'default': {
      'responses': [
        'I understand you\'re asking about "{query}". How can I help you with that?',
        'Could you please provide more details about your query regarding "{query}"?',
        'Let me help you with information about "{query}". What specific details do you need?'
      ],
      'quickReplies': [
        'View All Services',
        'Contact Support',
        'FAQs',
        'Speak to Agent'
      ]
    },
    'payments': {
      'patterns': ['pay', 'payment', 'bill', 'fee'],
      'responses': [
        'You can make payments for:\n\n'
        '• Property Tax\n'
        '• Water Bills\n'
        '• Trade License\n'
        '• Other Municipal Fees',
      ],
      'quickReplies': [
        'Pay Property Tax',
        'Pay Water Bill',
        'Pay License Fee',
        'View Payment History'
      ],
      'actionData': {
        'type': 'payment',
        'screen': 'PaymentScreen',
      }
    },
    'emergency': {
      'patterns': ['emergency', 'urgent', 'immediate'],
      'responses': [
        '🚨 For emergencies, contact:\n\n'
        '• Fire: 101\n'
        '• Ambulance: 108\n'
        '• Police: 100\n'
        '• Municipal Helpline: 0288-2550231',
      ],
      'quickReplies': [
        'Call Fire',
        'Call Ambulance',
        'Call Police',
        'View All Contacts'
      ],
      'actionData': {
        'type': 'emergency',
        'numbers': {
          'fire': '101',
          'ambulance': '108',
          'police': '100',
        }
      }
    },
  };

  static double _analyzeSentiment(String message) {
    final positiveWords = ['good', 'great', 'excellent', 'thanks', 'helpful'];
    final negativeWords = ['bad', 'poor', 'terrible', 'worst', 'unhappy'];
    
    message = message.toLowerCase();
    double score = 0;
    
    for (var word in positiveWords) {
      if (message.contains(word)) score += 0.2;
    }
    for (var word in negativeWords) {
      if (message.contains(word)) score -= 0.2;
    }
    
    return score.clamp(-1.0, 1.0);
  }

  static Map<String, dynamic> getResponse(String message, List<ChatMessage> history) {
    message = message.toLowerCase();
    
    double sentiment = _analyzeSentiment(message);
    
    String? context = _getContextFromHistory(history);
    
    var response = _getBaseResponse(message, context);
    
    if (sentiment < -0.5) {
      response['text'] = 'I understand you\'re frustrated. ' + response['text'];
      response['quickReplies']?.insert(0, 'Speak to Agent');
    }
    
    return response;
  }

  static String? _getContextFromHistory(List<ChatMessage> history) {
    if (history.isEmpty) return null;
    
    for (var i = history.length - 1; i >= 0; i--) {
      if (!history[i].isUser) {
        return history[i].suggestionType;
      }
    }
    return null;
  }

  static Map<String, dynamic> _getBaseResponse(String message, String? context) {
    // Check each category's patterns
    for (var category in responses.entries) {
      if (category.key != 'default' && 
          category.value['patterns'] != null &&
          category.value['patterns'].any((pattern) => message.contains(pattern))) {
        
        var responseList = category.value['responses'];
        var randomResponse = responseList[DateTime.now().microsecond % responseList.length];
        
        return {
          'text': randomResponse,
          'quickReplies': category.value['quickReplies'],
          'attachmentType': category.value['attachmentType'],
          'attachmentUrl': category.value['attachmentUrl'],
          'actionData': category.value['actionData'],
          'suggestionType': category.key,
        };
      }
    }

    // Default response
    var defaultResponses = responses['default']['responses'];
    var randomDefault = defaultResponses[DateTime.now().microsecond % defaultResponses.length];
    return {
      'text': randomDefault.replaceAll('{query}', message),
      'quickReplies': responses['default']['quickReplies'],
      'suggestionType': 'default',
    };
  }
}

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _showSuggestions = true;

  // Predefined intents and responses
  final Map<String, Map<String, dynamic>> _intents = {
    'general_services': {
      'patterns': [
        'what services do you offer',
        'available services',
        'help me with services',
        'municipal services'
      ],
      'response': 'We offer various municipal services including:\n'
          '• Water and Drainage Services\n'
          '• Property Tax Management\n'
          '• Building Permissions\n'
          '• Trade Licenses\n'
          '• Birth/Death Certificates\n'
          'How can I assist you with any of these services?',
      'quick_replies': [
        'Water Services',
        'Property Tax',
        'Building Permission',
        'Trade License'
      ]
    },
    'water_services': {
      'patterns': [
        'water connection',
        'water bill',
        'water supply',
        'water issues'
      ],
      'response': 'For water services, I can help you with:\n'
          '• New Connection Application\n'
          '• Bill Payment\n'
          '• Report Water Issues\n'
          '• Check Connection Status\n'
          'What would you like to know more about?',
      'quick_replies': [
        'New Connection',
        'Pay Water Bill',
        'Report Issue',
        'Check Status'
      ]
    },
    'property_tax': {
      'patterns': [
        'property tax',
        'house tax',
        'tax payment',
        'tax assessment'
      ],
      'response': 'For property tax, I can assist with:\n'
          '• View Tax Details\n'
          '• Pay Property Tax\n'
          '• Tax Assessment\n'
          '• Download Tax Receipt\n'
          'How would you like to proceed?',
      'quick_replies': [
        'View Tax',
        'Pay Tax',
        'Assessment',
        'Tax Receipt'
      ]
    },
    'emergency': {
      'patterns': [
        'emergency',
        'urgent help',
        'immediate assistance',
        'water leakage',
        'pipe burst'
      ],
      'response': '🚨 For emergencies, please:\n'
          '• Call our 24/7 helpline: 1800-XXX-XXXX\n'
          '• Use the Emergency tab in our app\n'
          '• Share your location for immediate assistance\n'
          'Would you like me to connect you to emergency services?',
      'quick_replies': [
        'Call Helpline',
        'Emergency Services',
        'Share Location',
        'Report Emergency'
      ],
      'is_emergency': true
    }
  };

  @override
  void initState() {
    super.initState();
    _addMessage(
      'Hello! 👋 I\'m your Municipal Services Assistant. How can I help you today?',
      false,
      [
        'Available Services',
        'Pay Bills',
        'Report Issue',
        'Track Application'
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    _addMessage(text, true);
    
    setState(() {
      _isTyping = true;
    });

    // Simulate AI processing
    Future.delayed(Duration(seconds: 1), () {
      _processMessage(text);
    });
  }

  void _processMessage(String text) {
    String intent = _findIntent(text.toLowerCase());
    Map<String, dynamic>? response = _intents[intent];

    if (response != null) {
      if (response['is_emergency'] == true) {
        _addMessage('⚠️ ' + response['response'], false, response['quick_replies']);
      } else {
        _addMessage(response['response'], false, response['quick_replies']);
      }
    } else {
      _addMessage(
        'I\'m not sure I understand. Could you please rephrase or select one of these options?',
        false,
        ['Available Services', 'Help', 'Contact Support'],
      );
    }

    setState(() {
      _isTyping = false;
    });
  }

  String _findIntent(String text) {
    for (var entry in _intents.entries) {
      if (entry.value['patterns'].any((pattern) => text.contains(pattern))) {
        return entry.key;
      }
    }
    return 'unknown';
  }

  void _addMessage(String text, bool isUser, [List<String>? quickReplies]) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: isUser,
        timestamp: DateTime.now(),
        quickReplies: quickReplies,
      ));
    });

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleQuickReply(String reply) {
    // Remove the _handleSubmitted call since it's causing duplicate messages
    // _handleSubmitted(reply); - Remove this line
    
    // Convert reply to lowercase and remove emojis for consistent matching
    String cleanReply = reply.toLowerCase().replaceAll(RegExp(r'[^\x00-\x7F]+'), '').trim();
    
    switch(cleanReply) {
      // Property Tax Related
      case 'property tax':
        _handlePropertyTaxOptions();
        break;
      case 'pay tax':
      case 'pay now':
      case 'pay property tax':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => PaymentScreen()
        ));
        break;
      
      // Water Services Related
      case 'water services':
        _handleWaterServicesOptions();
        break;
      case 'new connection':
      case 'pay water bill':
      case 'water bill':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => WaterAndDrainageServicesScreen()
        ));
        break;
      
      // Complaints Related
      case 'file complaint':
      case 'report issue':
      case 'file new complaint':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ComplaintsAndGrievancesScreen()
        ));
        break;
      
      // Certificates Related
      case 'apply for certificate':
      case 'certificates':
      case 'download certificate':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CertificatesScreen()
        ));
        break;
      
      // Emergency Related
      case 'emergency services':
      case 'call helpline':
      case 'emergency contact':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => EmergencyHelplinesScreen()
        ));
        break;
      
      // Payment Related
      case 'pay bills':
      case 'view payment history':
      case 'pay online':
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => PaymentScreen()
        ));
        break;

      default:
        // Process as a regular message only if it's not a navigation action
        _handleSubmitted(reply);
        break;
    }
  }

  // Add these new helper methods
  void _handlePropertyTaxOptions() {
    _addMessage(
      'Here are the Property Tax services:\n'
      '• View and Pay Property Tax\n'
      '• Download Tax Receipt\n'
      '• View Payment History\n'
      '• Update Property Details',
      false,
      [
        '💰 Pay Now',
        '📄 Download Receipt',
        '📋 View History',
        '🏠 Update Details'
      ]
    );
  }

  void _handleWaterServicesOptions() {
    _addMessage(
      'Here are the Water Services available:\n'
      '• Apply for New Connection\n'
      '• Pay Water Bill\n'
      '• Report Water Issues\n'
      '• Check Supply Schedule',
      false,
      [
        'New Connection',
        'Pay Water Bill',
        'Report Issue',
        'Supply Schedule'
      ]
    );
  }

  // Add this method to get icons for quick replies
  IconData _getQuickReplyIcon(String reply) {
    switch(reply.toLowerCase()) {
      case 'water services':
        return Icons.water_drop;
      case 'property tax':
        return Icons.home;
      case 'emergency services':
        return Icons.emergency;
      case 'file complaint':
      case 'report issue':
        return Icons.report_problem;
      case 'certificates':
        return Icons.article;
      case 'pay bills':
        return Icons.payment;
      case 'available services':
        return Icons.list_alt;
      case 'help':
        return Icons.help;
      case 'contact support':
        return Icons.support_agent;
      case 'track application':
        return Icons.track_changes;
      default:
        return Icons.arrow_forward;
    }
  }

  // Update the quick replies widget to include icons
  Widget _buildQuickReplies(List<String> quickReplies) {
    return Container(
      height: 45,
      margin: EdgeInsets.only(left: 48, top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: quickReplies.map((reply) {
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              icon: Icon(_getQuickReplyIcon(reply), size: 16),
              label: Text(reply),
              onPressed: () => _handleQuickReply(reply),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Update the message bubble widget for better theming
  Widget _buildMessage(ChatMessage message) {
    return Column(
      crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser)
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.support_agent, color: Colors.white),
                ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(
                          color: message.isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (message.isUser)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.grey[700]),
                  ),
                ),
            ],
          ),
        ),
        if (message.quickReplies != null && message.quickReplies!.isNotEmpty)
          _buildQuickReplies(message.quickReplies!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Municipal Assistant'),
            Text(
              'Online • Usually responds instantly',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => _showHelp(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),
          if (_isTyping)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Assistant is typing...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: () => _showAttachmentOptions(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Ask about Services'),
              subtitle: Text('Get information about municipal services'),
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Bill Payments'),
              subtitle: Text('Pay water bills, property tax, etc.'),
            ),
            ListTile(
              leading: Icon(Icons.report_problem),
              title: Text('Report Issues'),
              subtitle: Text('Report problems or file complaints'),
            ),
            ListTile(
              leading: Icon(Icons.track_changes),
              title: Text('Track Applications'),
              subtitle: Text('Check status of your applications'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Upload Photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement photo upload
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Share Location'),
              onTap: () {
                Navigator.pop(context);
                // Implement location sharing
              },
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Upload Document'),
              onTap: () {
                Navigator.pop(context);
                // Implement document upload
              },
            ),
          ],
        ),
      ),
    );
  }
}