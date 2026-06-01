import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'General';
  double _rating = 5.0;

  final List<String> _categories = [
    'General',
    'App Performance',
    'Mechanic Service',
    'Payment Issues',
    'User Interface',
    'Feature Request',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: AppTheme.figtreeBold.copyWith(
            color: AppTheme.onSurfaceColor,
            fontSize: AppTheme.fontSize18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildRatingSection(),
              const SizedBox(height: 24),
              _buildCategorySection(),
              const SizedBox(height: 24),
              _buildFeedbackSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 24),
              _buildPreviousFeedbackSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.message_circle,
                size: 30,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We Value Your Feedback!',
              style: TextStyle(
                fontSize: AppTheme.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Help us improve your experience by sharing your thoughts',
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

  Widget _buildRatingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Rating',
              style: TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        iconSize: 40,
                        onPressed: () {
                          setState(() {
                            _rating = index + 1.0;
                          });
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingText(_rating),
                    style: const TextStyle(
                      fontSize: AppTheme.fontSize16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Feedback',
              style: TextStyle(
                fontSize: AppTheme.fontSize16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _feedbackController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your feedback';
                }
                if (value.trim().length < 10) {
                  return 'Feedback must be at least 10 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitFeedback,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: AppTheme.onPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Submit Feedback',
          style: TextStyle(
            fontSize: AppTheme.fontSize16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPreviousFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Previous Feedback',
          style: TextStyle(
            fontSize: AppTheme.fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildPreviousFeedbackCard(
          category: 'App Performance',
          feedback:
              'The app loads very smoothly and the interface is intuitive.',
          rating: 5.0,
          date: DateTime.now().subtract(const Duration(days: 15)),
          status: 'Reviewed',
        ),
        _buildPreviousFeedbackCard(
          category: 'Mechanic Service',
          feedback: 'Great service! The mechanic was professional and quick.',
          rating: 4.5,
          date: DateTime.now().subtract(const Duration(days: 30)),
          status: 'Reviewed',
        ),
      ],
    );
  }

  Widget _buildPreviousFeedbackCard({
    required String category,
    required String feedback,
    required double rating,
    required DateTime date,
    required String status,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: AppTheme.fontSize12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: AppTheme.fontSize14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feedback,
              style: const TextStyle(
                fontSize: AppTheme.fontSize14,
                color: AppTheme.grey700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 14,
                  color: AppTheme.grey500,
                ),
                const SizedBox(width: 6),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    fontSize: AppTheme.fontSize12,
                    color: AppTheme.grey500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: AppTheme.green,
                      fontSize: AppTheme.fontSize11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return 'Excellent!';
    if (rating >= 4) return 'Great!';
    if (rating >= 3) return 'Good';
    if (rating >= 2) return 'Fair';
    return 'Needs Improvement';
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thank You!'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.circle_check,
                color: AppTheme.primaryColor,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Your feedback has been submitted successfully!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'We appreciate your input and will use it to improve our service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTheme.fontSize12,
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _feedbackController.clear();
                  _rating = 5.0;
                  _selectedCategory = 'General';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }
}
