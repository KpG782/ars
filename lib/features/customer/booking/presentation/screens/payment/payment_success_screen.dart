import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import '../booking.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String mechanicName;
  final String serviceName;
  final double amount;
  final String paymentMethod;

  const PaymentSuccessScreen({
    super.key,
    required this.mechanicName,
    required this.serviceName,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkAnimationController;
  late AnimationController _confettiAnimationController;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _confettiAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _checkAnimationController.forward();
      _confettiAnimationController.forward();
    });

    // Haptic feedback
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    _confettiAnimationController.dispose();
    super.dispose();
  }

  void _goBackToBooking() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const BookingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Animation
                    AnimatedBuilder(
                      animation: _checkAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00BFA5,
                              ).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _checkAnimation,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: CheckPainter(
                                          _checkAnimation.value,
                                        ),
                                        size: const Size(80, 80),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Thank you for using our service.\nYour payment has been processed successfully.',
                      style: TextStyle(
                        fontSize: AppTheme.fontSize16,
                        color: AppTheme.grey600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Payment Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.grey50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Service:',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize16,
                                  color: AppTheme.grey,
                                ),
                              ),
                              Text(
                                widget.serviceName,
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSize16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Mechanic:',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize16,
                                  color: AppTheme.grey,
                                ),
                              ),
                              Text(
                                widget.mechanicName,
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSize16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Payment Method:',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize16,
                                  color: AppTheme.grey,
                                ),
                              ),
                              Text(
                                widget.paymentMethod,
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSize16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount:',
                                style: TextStyle(
                                  fontSize: AppTheme.fontSize18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₱${widget.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: AppTheme.fontSize20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _goBackToBooking,
                      child: const Text(
                        'Book Another Service',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppTheme.primaryColor),
                      ),
                      onPressed: () {
                        // TODO: Implement receipt/invoice download
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt saved to downloads'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      },
                      child: const Text(
                        'Download Receipt',
                        style: TextStyle(
                          fontSize: AppTheme.fontSize16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckPainter extends CustomPainter {
  final double progress;

  CheckPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final checkPath = Path();

    // Define check mark points
    final startPoint = Offset(center.dx - 12, center.dy);
    final middlePoint = Offset(center.dx - 4, center.dy + 8);
    final endPoint = Offset(center.dx + 12, center.dy - 8);

    if (progress > 0) {
      checkPath.moveTo(startPoint.dx, startPoint.dy);

      if (progress <= 0.5) {
        final currentPoint = Offset.lerp(
          startPoint,
          middlePoint,
          progress * 2,
        )!;
        checkPath.lineTo(currentPoint.dx, currentPoint.dy);
      } else {
        checkPath.lineTo(middlePoint.dx, middlePoint.dy);
        final currentPoint = Offset.lerp(
          middlePoint,
          endPoint,
          (progress - 0.5) * 2,
        )!;
        checkPath.lineTo(currentPoint.dx, currentPoint.dy);
      }

      canvas.drawPath(checkPath, paint);
    }
  }

  @override
  bool shouldRepaint(CheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
