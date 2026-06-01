import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:arsapplication/core/theme/app_theme.dart';
import 'package:arsapplication/core/utils/app_logger.dart';
import 'package:share_plus/share_plus.dart';

class LocationSharingService {
  /// Build emergency message with Google Maps link
  static String buildMessage({
    required double latitude,
    required double longitude,
    required String customerName,
    required String mechanicName,
    required String eta,
  }) {
    final mapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';

    return '''
🚨 EMERGENCY ALERT

$customerName needs roadside assistance!

📍 Live Location (Tap to open in Google Maps):
$mapsUrl

Mechanic: $mechanicName
ETA: $eta

⚠️ Location updates every 30 seconds

- ARS Emergency Response
''';
  }

  /// 1. SMS (Native SMS App)
  static Future<bool> shareViaSMS({required String message}) async {
    try {
      // Use SMS deep link that works on both Android and iOS
      final uri = Uri.parse('sms:?body=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return launched;
      }

      // Fallback to native share
      await Share.share(message, subject: '🚨 Emergency Location Alert');
      return true;
    } catch (e) {
      appLogger.w('SMS error: $e');
      // Final fallback: native share sheet
      try {
        await Share.share(message, subject: '🚨 Emergency Location Alert');
        return true;
      } catch (shareError) {
        appLogger.w('Share fallback error: $shareError');
        return false;
      }
    }
  }

  /// 2. Facebook Messenger
  static Future<bool> shareViaMessenger({
    required String message,
    required String trackingUrl,
    required BuildContext context,
  }) async {
    try {
      // Try Messenger deep links
      final messengerSchemes = [
        'fb-messenger://share?text=${Uri.encodeComponent(message)}',
        'fb-messenger://',
      ];

      for (final scheme in messengerSchemes) {
        final uri = Uri.parse(scheme);
        if (await canLaunchUrl(uri)) {
          await Clipboard.setData(ClipboardData(text: message));
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );

          if (launched && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text('Message copied! Paste in Messenger')),
                  ],
                ),
                backgroundColor: AppTheme.infoColor,
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return true;
          }
        }
      }

      // Fallback: Open native share with specific text for Messenger
      await Share.share(message, subject: '🚨 Emergency Location Alert');
      return true;
    } catch (e) {
      appLogger.w('Messenger error: $e');
      // Final fallback: native share
      try {
        await Share.share(message, subject: '🚨 Emergency Location Alert');
        return true;
      } catch (shareError) {
        appLogger.w('Share fallback error: $shareError');
        return false;
      }
    }
  }

  /// 3. WhatsApp
  static Future<bool> shareViaWhatsApp({required String message}) async {
    try {
      // Try WhatsApp deep link
      final whatsappUrl =
          'whatsapp://send?text=${Uri.encodeComponent(message)}';
      final uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      }

      // Try web WhatsApp link (opens WhatsApp app if installed)
      final webUri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(webUri)) {
        final launched = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      }

      // Fallback to native share
      await Share.share(message, subject: '🚨 Emergency Location Alert');
      return true;
    } catch (e) {
      appLogger.w('WhatsApp error: $e');
      // Final fallback: native share
      try {
        await Share.share(message, subject: '🚨 Emergency Location Alert');
        return true;
      } catch (shareError) {
        appLogger.w('Share fallback error: $shareError');
        return false;
      }
    }
  }

  /// 4. Copy to Clipboard
  static Future<bool> copyToClipboard({
    required String message,
    required BuildContext context,
  }) async {
    try {
      await Clipboard.setData(ClipboardData(text: message));

      // Show confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Copied to clipboard!'),
              ],
            ),
            backgroundColor: AppTheme.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return true;
    } catch (e) {
      appLogger.w('Clipboard error: $e');
      return false;
    }
  }
}
