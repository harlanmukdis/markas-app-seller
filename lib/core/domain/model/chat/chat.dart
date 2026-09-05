import '../../../utils/json_parse.dart';

class ChatThread {
  const ChatThread({
    required this.id,
    this.channel,
    this.contextType,
    this.contextId,
    this.counterpartyName,
    this.lastMessage,
    this.unreadCount = 0,
    this.updatedAt,
  });

  final int id;
  final String? channel;
  final String? contextType;
  final int? contextId;
  final String? counterpartyName;
  final String? lastMessage;
  final int unreadCount;
  final DateTime? updatedAt;

  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: asInt(json['id']),
        channel: asStringOrNull(json['channel']),
        contextType: asStringOrNull(json['context_type']),
        contextId: asIntOrNull(json['context_id']),
        counterpartyName: asStringOrNull(
          json['counterparty_name'] ?? json['buyer_name'],
        ),
        lastMessage: asStringOrNull(json['last_message']),
        unreadCount: asInt(json['unread_count']),
        updatedAt: asDateTime(json['updated_at']),
      );
}

/// The `text` that comes back is the **censored** version: phone numbers are
/// masked until the related order is paid, and bank accounts or invitations to
/// deal off-platform are always blocked. Tell the store why its message
/// changed — otherwise it reads as a bug.
class ChatMessage {
  const ChatMessage({
    required this.id,
    this.threadId,
    this.senderType,
    this.senderId,
    this.text,
    this.attachmentUrl,
    this.createdAt,
  });

  final int id;
  final int? threadId;
  final String? senderType;
  final int? senderId;
  final String? text;
  final String? attachmentUrl;
  final DateTime? createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: asInt(json['id']),
        threadId: asIntOrNull(json['thread_id']),
        senderType: asStringOrNull(json['sender_type']),
        senderId: asIntOrNull(json['sender_id']),
        text: asStringOrNull(json['text']),
        attachmentUrl: asStringOrNull(json['attachment_url']),
        createdAt: asDateTime(json['created_at']),
      );

  bool get isFromSeller => senderType == 'SELLER';
}

/// Shown on the store's public page, so it belongs on the dashboard too. The
/// SLA is one hour during working hours (CHT-03).
class ChatResponseRate {
  const ChatResponseRate({this.responseRate, this.avgResponseMinutes});

  final double? responseRate;
  final double? avgResponseMinutes;

  factory ChatResponseRate.fromJson(Map<String, dynamic> json) =>
      ChatResponseRate(
        responseRate: asDoubleOrNull(
          json['response_rate'] ?? json['seller_response_rate'],
        ),
        avgResponseMinutes: asDoubleOrNull(json['avg_response_minutes']),
      );
}

abstract class ChatChannel {
  static const String buyerSeller = 'BUYER_SELLER';
  static const String sellerCs = 'SELLER_CS';

  static const List<String> all = <String>[buyerSeller, sellerCs];

  static String label(String? channel) => switch (channel) {
        buyerSeller => 'Pembeli',
        sellerCs => 'Customer Service',
        _ => channel ?? '-',
      };
}

abstract class ChatContextType {
  static const String product = 'PRODUCT';
  static const String order = 'ORDER';
  static const String rfq = 'RFQ';
  static const String general = 'GENERAL';

  static const List<String> all = <String>[product, order, rfq, general];
}
