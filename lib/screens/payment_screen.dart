import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentHeader(),
            SizedBox(height: 24),
            Text(
              'Payment Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildPaymentCard(
              context,
              'Property Tax',
              Icons.home,
              'Pay your property tax',
              Colors.blue.shade100,
              Colors.blue,
            ),
            _buildPaymentCard(
              context,
              'Water Bill',
              Icons.water_drop,
              'Pay your water bill',
              Colors.cyan.shade100,
              Colors.cyan,
            ),
            _buildPaymentCard(
              context,
              'Trade License Fee',
              Icons.store,
              'Pay trade license fee',
              Colors.orange.shade100,
              Colors.orange,
            ),
            _buildPaymentCard(
              context,
              'Building Permission Fee',
              Icons.business,
              'Pay building permission fee',
              Colors.purple.shade100,
              Colors.purple,
            ),
            _buildPaymentCard(
              context,
              'Market Fee',
              Icons.shopping_cart,
              'Pay market stall fee',
              Colors.green.shade100,
              Colors.green,
            ),
            _buildPaymentCard(
              context,
              'Other Payments',
              Icons.payments,
              'Make other municipal payments',
              Colors.grey.shade100,
              Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.payment,
            color: Colors.blue,
            size: 40,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Make secure payments for various municipal services. Multiple payment options available.',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    Color backgroundColor,
    Color iconColor,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: backgroundColor,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(icon, size: 40, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                color: iconColor.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.credit_card, size: 16, color: iconColor),
                SizedBox(width: 4),
                Text(
                  'Multiple payment options available',
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _showPaymentForm(context, title),
          style: ElevatedButton.styleFrom(
            backgroundColor: iconColor,
          ),
          child: Text(
            'Pay Now',
            style: TextStyle(color: Colors.white),
          ),
        ),
        onTap: () => _showPaymentForm(context, title),
      ),
    );
  }

  void _showPaymentForm(BuildContext context, String paymentType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.blue),
            SizedBox(width: 8),
            Text('Pay $paymentType'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Consumer ID / Property ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPaymentOptions(context, paymentType);
            },
            child: Text('Proceed to Pay'),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, String paymentType) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('Credit/Debit Card'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, paymentType, 'card');
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Net Banking'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, paymentType, 'netbanking');
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('UPI'),
              onTap: () {
                Navigator.pop(context);
                _processPayment(context, paymentType, 'upi');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context, String paymentType, String method) {
    // Simulate payment processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing payment...'),
          ],
        ),
      ),
    );

    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Close processing dialog
      _showPaymentSuccess(context, paymentType);
    });
  }

  void _showPaymentSuccess(BuildContext context, String paymentType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Text(
          'Your payment for $paymentType has been processed successfully.\n\n'
          'Transaction ID: P${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)}\n\n'
          'A receipt has been sent to your registered email address.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              // Implement receipt download
            },
            child: Text('Download Receipt'),
          ),
        ],
      ),
    );
  }
} 