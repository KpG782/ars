import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:arsapplication/core/theme/app_theme.dart';

const String _kChatbotBaseUrlFallback = String.fromEnvironment(
  'ARS_CHATBOT_BASE_URL',
  defaultValue: 'https://pacebeats-ars-chatbot.kygozf.easypanel.host',
);
const String _kChatbotApiKeyFallback = String.fromEnvironment(
  'ARS_CHATBOT_API_KEY',
  defaultValue: '',
);
const String _kRapideApiKeyFallback = String.fromEnvironment(
  'ARS_RAPIDE_API_KEY',
  defaultValue: '',
);
const String _kApiKeysFallback = String.fromEnvironment(
  'API_KEYS',
  defaultValue: '',
);
const String _kChatbotBaseUrlsFallback = String.fromEnvironment(
  'ARS_CHATBOT_BASE_URLS',
  defaultValue: '',
);

class AiChatScreen extends StatefulWidget {
  final String sessionId;
  final String? initialContext;

  const AiChatScreen({super.key, required this.sessionId, this.initialContext});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  bool _isLoading = false;
  bool _usingLiveApi = true;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _chatbotBaseUrl =>
      (dotenv.env['ARS_CHATBOT_BASE_URL'] ?? _kChatbotBaseUrlFallback).trim();
  List<String> get _chatbotBaseUrls {
    final configured =
        (dotenv.env['ARS_CHATBOT_BASE_URLS'] ?? _kChatbotBaseUrlsFallback)
            .trim();
    final values = <String>[
      if (_chatbotBaseUrl.isNotEmpty) _chatbotBaseUrl,
      if (configured.isNotEmpty)
        ...configured
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
    ];
    return values.toSet().toList();
  }

  String get _chatbotApiKey {
    final key = _firstNonEmpty([
      dotenv.env['ARS_CHATBOT_API_KEY'],
      dotenv.env['ARS_RAPIDE_API_KEY'],
      dotenv.env['API_KEYS'],
      _kChatbotApiKeyFallback,
      _kRapideApiKeyFallback,
      _kApiKeysFallback,
    ]);

    if (key == null) return '';
    // Support comma-separated API_KEYS and pick first key.
    return key.split(',').first.trim();
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    // Auth guard — pop immediately if no user is signed in.
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    _addBotMessage(
      'ARS Assistant is ready. Ask about shops, mechanics, and booking help.',
    );

    final contextText = widget.initialContext?.trim();
    if (contextText != null && contextText.isNotEmpty) {
      _addBotMessage('Current app context: $contextText');
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(_ChatMessage(text: _prepareMarkdown(text), isUser: false));
    });
    _scrollToBottom();
  }

  String _prepareMarkdown(String text) {
    var output = text.replaceAll(r'\n', '\n').replaceAll(r'\t', '  ');
    output = output.replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'), (match) {
      final value = int.tryParse(match.group(1)!, radix: 16);
      return value == null ? match.group(0)! : String.fromCharCode(value);
    });
    return output.trim();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _inputController.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final responseText = await _requestBackendReply(text);
      _addBotMessage(responseText);
      if (!_usingLiveApi) {
        setState(() => _usingLiveApi = true);
      }
    } catch (e) {
      // Graceful fallback for demo continuity.
      if (_usingLiveApi) {
        setState(() => _usingLiveApi = false);
      }
      debugPrint('ARS Assistant live API fallback: $e');
      _addBotMessage(_generateLocalReply(text));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _requestBackendReply(String text) async {
    final bases = _chatbotBaseUrls;
    if (bases.isEmpty) {
      throw Exception('Missing chatbot base URL');
    }

    if (_chatbotApiKey.isEmpty) {
      throw Exception('Missing chatbot API key');
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-Key': _chatbotApiKey,
      'Authorization': 'Bearer $_chatbotApiKey',
    };

    final errors = <String>[];

    for (final base in bases) {
      final uri = Uri.parse(
        '${base.endsWith('/') ? base.substring(0, base.length - 1) : base}/chat',
      );

      try {
        final response = await http
            .post(
              uri,
              headers: headers,
              body: jsonEncode({
                'message': text,
                'user_id': _userId,
                'conversation_id': widget.sessionId,
              }),
            )
            .timeout(const Duration(seconds: 45));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          errors.add(
            '$base -> status ${response.statusCode}: ${response.body.trim()}',
          );
          continue;
        }

        if (response.body.trim().isEmpty) {
          errors.add('$base -> empty response body');
          continue;
        }

        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final formatted = _formatBackendPayload(decoded);
            if (formatted.trim().isNotEmpty) {
              return formatted;
            }
          }
          final message = _extractBackendMessage(decoded);
          if (message != null && message.trim().isNotEmpty) {
            return message.trim();
          }
        } catch (_) {
          // Continue to raw body fallback below.
        }

        // Fallback: treat raw body as response if backend returns plain text
        // or a schema we do not yet explicitly parse.
        final raw = response.body.trim();
        if (raw.isNotEmpty) {
          return raw;
        }

        errors.add('$base -> response missing message');
      } on SocketException catch (e) {
        errors.add('$base -> network: ${e.message}');
      } on http.ClientException catch (e) {
        errors.add('$base -> client: ${e.message}');
      } on HandshakeException catch (e) {
        errors.add('$base -> tls: $e');
      } on HttpException catch (e) {
        errors.add('$base -> http: ${e.message}');
      } catch (e) {
        errors.add('$base -> $e');
      }
    }

    throw Exception('All chatbot endpoints failed: ${errors.join(' | ')}');
  }

  String _formatBackendPayload(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    final response = _pickText(data, const [
      'response',
      'answer',
      'message',
      'reply',
      'result',
      'output',
      'content',
      'text',
    ]);
    if (response != null) {
      buffer.writeln(response.trim());
      buffer.writeln();
    }

    final intent = data['intent']?.toString();
    final urgency = data['urgency']?.toString();
    final confidence = _asDouble(data['confidence']);
    final latencyMs = _asDouble(data['latency_ms']);
    final cached = data['cached'];
    final conversationId = data['conversation_id']?.toString();

    final hasMeta =
        intent != null ||
        urgency != null ||
        confidence != null ||
        latencyMs != null ||
        cached != null ||
        conversationId != null;
    if (hasMeta) {
      buffer.writeln('### Diagnostics');
      if (intent != null) buffer.writeln('- **Intent:** `$intent`');
      if (urgency != null) buffer.writeln('- **Urgency:** `$urgency`');
      if (confidence != null) {
        buffer.writeln(
          '- **Confidence:** `${(confidence * 100).toStringAsFixed(1)}%`',
        );
      }
      if (latencyMs != null) {
        buffer.writeln('- **Latency:** `${latencyMs.toStringAsFixed(0)} ms`');
      }
      if (cached != null) buffer.writeln('- **Cached:** `$cached`');
      if (conversationId != null) {
        buffer.writeln('- **Conversation ID:** `$conversationId`');
      }
      buffer.writeln();
    }

    final costEstimate = data['cost_estimate'];
    if (costEstimate is Map<String, dynamic>) {
      buffer.writeln('### Cost Estimate');

      final estimateMsg = _pickText(costEstimate, const [
        'message',
        'summary',
        'response',
        'text',
      ]);
      if (estimateMsg != null && estimateMsg.trim().isNotEmpty) {
        buffer.writeln(estimateMsg.trim());
        buffer.writeln();
      }

      final services = costEstimate['services'];
      if (services is List && services.isNotEmpty) {
        for (var i = 0; i < services.length; i++) {
          final service = services[i];
          if (service is! Map<String, dynamic>) continue;
          final name =
              service['service_name']?.toString() ?? 'Service ${i + 1}';
          buffer.writeln('#### ${i + 1}. $name');

          final description = service['description']?.toString();
          if (description != null && description.isNotEmpty) {
            buffer.writeln(description);
          }

          final talyer = _formatPriceRange(service['talyer_price_php']);
          final casa = _formatPriceRange(service['casa_price_php']);
          if (talyer != null) buffer.writeln('- **Talyer:** $talyer');
          if (casa != null) buffer.writeln('- **Casa:** $casa');

          final duration = service['duration_minutes'];
          if (duration != null) {
            buffer.writeln('- **Duration:** `${duration.toString()} mins`');
          }

          final parts = service['parts_included'];
          if (parts is List && parts.isNotEmpty) {
            final partsText = parts.map((e) => e.toString()).join(', ');
            buffer.writeln('- **Parts:** $partsText');
          }

          final interval = service['recommended_interval']?.toString();
          if (interval != null && interval.isNotEmpty) {
            buffer.writeln('- **Recommended Interval:** $interval');
          }

          final notes = service['notes']?.toString();
          if (notes != null && notes.isNotEmpty) {
            buffer.writeln('- **Notes:** $notes');
          }
          buffer.writeln();
        }
      } else {
        final pricingData = costEstimate['pricing_data']?.toString();
        if (pricingData != null && pricingData.isNotEmpty) {
          buffer.writeln('```');
          buffer.writeln(pricingData.trim());
          buffer.writeln('```');
          buffer.writeln();
        }
      }
    }

    return buffer.toString().trim();
  }

  String? _pickText(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? _formatPriceRange(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    final low = _asDouble(value['low']);
    final high = _asDouble(value['high']);
    if (low == null || high == null) return null;
    final lowText = low.toStringAsFixed(0);
    final highText = high.toStringAsFixed(0);
    return 'PHP $lowText - $highText';
  }

  String? _extractBackendMessage(dynamic decoded) {
    if (decoded is String) return decoded;

    if (decoded is Map<String, dynamic>) {
      final direct = [
        decoded['response'],
        decoded['answer'],
        decoded['message'],
        decoded['reply'],
        decoded['result'],
        decoded['output'],
        decoded['content'],
        decoded['text'],
        decoded['diagnosis'],
        decoded['summary'],
        decoded['detail'],
      ];

      for (final item in direct) {
        if (item == null) continue;
        if (item is String && item.trim().isNotEmpty) return item;
        if (item is num || item is bool) return item.toString();
        if (item is Map || item is List) {
          final jsonText = jsonEncode(item);
          if (jsonText.trim().isNotEmpty) return jsonText;
        }
      }

      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final nested = [
          data['response'],
          data['answer'],
          data['message'],
          data['reply'],
          data['result'],
          data['output'],
          data['content'],
          data['text'],
          data['diagnosis'],
          data['summary'],
          data['detail'],
        ];
        for (final item in nested) {
          if (item == null) continue;
          if (item is String && item.trim().isNotEmpty) return item;
          if (item is num || item is bool) return item.toString();
          if (item is Map || item is List) {
            final jsonText = jsonEncode(item);
            if (jsonText.trim().isNotEmpty) return jsonText;
          }
        }
      }
    }

    if (decoded is List && decoded.isNotEmpty) {
      return jsonEncode(decoded);
    }

    return null;
  }

  String _generateLocalReply(String input) {
    final text = input.toLowerCase().trim();

    if (text.contains('shop') || text.contains('store')) {
      return 'Use the Shop button on the map to show or hide nearby shops.';
    }

    if (text.contains('mechanic') || text.contains('online')) {
      return 'Use the Mechanic button on the map to view online mechanics.';
    }

    if (text.contains('tire') || text.contains('flat')) {
      return 'For tire issues: choose Tire Problem and pick the specific tire service.';
    }

    if (text.contains('brake')) {
      return 'For brake issues: choose Brake Problem and pick the exact brake service.';
    }

    if (text.contains('engine')) {
      return 'For engine issues: choose Engine Problems and select diagnosis or repair.';
    }

    if (text.contains('emergency') || text.contains('sos')) {
      return 'Use Emergency SOS in the bottom panel for urgent requests.';
    }

    return 'Backend is temporarily unavailable. You can still continue booking from the map controls.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withAlpha(60),
              radius: 16,
              child: const Icon(LucideIcons.bot, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARS Assistant',
                  style: AppTheme.figtreeSemiBold.copyWith(
                    fontSize: AppTheme.fontSize15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _usingLiveApi ? 'Live API Connected' : 'Fallback Mode',
                  style: AppTheme.figtreeRegular.copyWith(
                    fontSize: AppTheme.fontSize11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(message: _messages[i]),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor.withAlpha(150),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assistant is typing...',
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize12,
                      color: AppTheme.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTheme.figtreeRegular.copyWith(
                      fontSize: AppTheme.fontSize14,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask ARS Assistant...',
                      hintStyle: AppTheme.figtreeRegular.copyWith(
                        color: AppTheme.subtitleColor.withAlpha(150),
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final textColor = isUser ? Colors.white : AppTheme.onSurfaceColor;
    final markdownStyle = MarkdownStyleSheet.fromTheme(Theme.of(context))
        .copyWith(
          p: TextStyle(
            fontSize: AppTheme.fontSize14,
            color: textColor,
            height: 1.4,
          ),
          code: TextStyle(
            fontSize: AppTheme.fontSize13,
            color: textColor,
            backgroundColor: isUser
                ? Colors.white24
                : Colors.black.withValues(alpha: 0.06),
          ),
          codeblockDecoration: BoxDecoration(
            color: isUser
                ? Colors.white24
                : Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
          ),
          blockquote: TextStyle(
            fontSize: AppTheme.fontSize14,
            color: textColor.withValues(alpha: 0.9),
            height: 1.4,
          ),
          blockquoteDecoration: BoxDecoration(
            color: isUser ? Colors.white24 : AppTheme.grey100,
            borderRadius: BorderRadius.circular(8),
          ),
          listBullet: TextStyle(
            fontSize: AppTheme.fontSize14,
            color: textColor,
          ),
          a: TextStyle(
            fontSize: AppTheme.fontSize14,
            color: isUser ? Colors.white : AppTheme.blue700,
            decoration: TextDecoration.underline,
          ),
          h1: TextStyle(
            fontSize: AppTheme.fontSize18,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          h2: TextStyle(
            fontSize: AppTheme.fontSize16,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          h3: TextStyle(
            fontSize: AppTheme.fontSize15,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          strong: TextStyle(
            fontSize: AppTheme.fontSize14,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
          em: TextStyle(
            fontSize: AppTheme.fontSize14,
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 1,
                color: isUser ? Colors.white38 : Colors.black12,
              ),
            ),
          ),
        );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : AppTheme.grey100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: isUser
            ? SelectableText(
                message.text,
                style: TextStyle(
                  fontSize: AppTheme.fontSize14,
                  color: textColor,
                  height: 1.4,
                ),
              )
            : MarkdownBody(
                data: message.text,
                selectable: true,
                styleSheet: markdownStyle,
                onTapLink: (text, href, title) async {
                  if (href == null) return;
                  final uri = Uri.tryParse(href);
                  if (uri == null) return;
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
      ),
    );
  }
}
