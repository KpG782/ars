import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:flutter/services.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey50,
      appBar: AppBar(
        title: const Text(
          'Support',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSupportHeader(),
          const SizedBox(height: 24),
          _buildContactSection(),
          const SizedBox(height: 24),
          _buildFAQSection(context),
          const SizedBox(height: 24),
          _buildReportIssueButton(context),
        ],
      ),
    );
  }

  Widget _buildSupportHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: AppTheme.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our support team is available 24/7 to assist you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSize14,
                color: AppTheme.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Us',
          style: TextStyle(
            fontSize: AppTheme.fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Builder(
          builder: (context) => Column(
            children: [
              _buildContactCard(
                icon: Icons.phone,
                color: AppTheme.green,
                title: 'Phone Support',
                subtitle: '+63 917 123 4567',
                onTap: () => _makePhoneCall(context, '+639171234567'),
              ),
              _buildContactCard(
                icon: Icons.email,
                color: AppTheme.blue,
                title: 'Email Support',
                subtitle: 'support@arsapplication.com',
                onTap: () => _sendEmail(context, 'support@arsapplication.com'),
              ),
              _buildContactCard(
                icon: Icons.chat,
                color: Colors.purple,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () => _openLiveChat(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppTheme.fontSize16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: AppTheme.fontSize14,
              color: AppTheme.grey600,
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: AppTheme.fontSize18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _showAllFAQs(context),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFAQItem(
          context,
          'How do I book a mechanic?',
          'Simply select the service you need on the map, choose your location, and book. A nearby mechanic will be assigned to you.',
        ),
        _buildFAQItem(
          context,
          'What payment methods are accepted?',
          'We accept Cash, GCash, and Credit/Debit cards. You can manage your payment methods in the Payment Methods section.',
        ),
        _buildFAQItem(
          context,
          'How do I cancel a booking?',
          'You can cancel a booking before the mechanic arrives. Go to your current booking and tap on Cancel Booking.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: AppTheme.fontSize15,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: AppTheme.fontSize14,
                color: AppTheme.grey700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportIssueButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _showReportIssueDialog(context),
      icon: const Icon(Icons.report_problem),
      label: const Text('Report an Issue'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number copied: $phoneNumber'),
          backgroundColor: AppTheme.primaryColor,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _sendEmail(BuildContext context, String email) async {
    await Clipboard.setData(ClipboardData(text: email));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email copied: $email'),
          backgroundColor: AppTheme.primaryColor,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _openLiveChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live chat feature coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _showAllFAQs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('FAQs'),
            backgroundColor: AppTheme.primaryColor,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFAQItem(
                context,
                'How do I book a mechanic?',
                'Simply select the service you need on the map, choose your location, and book. A nearby mechanic will be assigned to you.',
              ),
              _buildFAQItem(
                context,
                'What payment methods are accepted?',
                'We accept Cash, GCash, and Credit/Debit cards.',
              ),
              _buildFAQItem(
                context,
                'How do I cancel a booking?',
                'You can cancel before the mechanic arrives from your current booking.',
              ),
              _buildFAQItem(
                context,
                'How long does it take for a mechanic to arrive?',
                'Typically 10-30 minutes depending on your location and traffic conditions.',
              ),
              _buildFAQItem(
                context,
                'Are mechanics verified?',
                'Yes, all mechanics go through a verification process including background checks.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    final issueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report an Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please describe the issue you encountered:'),
            const SizedBox(height: 12),
            TextField(
              controller: issueController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              issueController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              issueController.dispose();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Issue reported. Our team will review it shortly.',
                  ),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
