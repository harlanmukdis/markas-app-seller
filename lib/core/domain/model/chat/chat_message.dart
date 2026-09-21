import '../../../utils/json_parse.dart';

/// One row of `GET /chat/conversations/{id}/messages`.
///
/// The server returns them **newest first**, thirty to a page, ordered by
/// `created_at` — which is only second-resolution, so two messages sent in the
/// same second come back in an arbitrary order. Sort by [id] before rendering:
/// it is the only strictly increasing field, and it is what `poll` pages
/// against too.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    this.type = ChatMessageType.text,
    this.content,
    this.sharedProductId,
    this.sharedOrderId,
    this.createdAt,
    this.readAt,
  });

  final int id;
  final int conversationId;

  /// The only identity a message carries — no name, no role, no side. Which
  /// bubble is the store's own is decided by comparing this against the signed
  /// in user, so a store answered by two staff accounts shows both as "ours".
  final int senderUserId;

  final String type;

  /// Nullable in the schema and never validated: the server accepts a message
  /// with no content at all and stores it.
  final String? content;

  final int? sharedProductId;
  final int? sharedOrderId;

  final DateTime? createdAt;

  /// Stamped by `POST /read` for every message the *other* side sent. A message
  /// the store sent is only marked when the buyer opens the thread.
  final DateTime? readAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: asInt(json['id']),
        conversationId: asInt(json['conversation_id']),
        senderUserId: asInt(json['sender_user_id']),
        type: asString(json['message_type'], fallback: ChatMessageType.text),
        content: asStringOrNull(json['content']),
        sharedProductId: asIntOrNull(json['shared_product_id']),
        sharedOrderId: asIntOrNull(json['shared_order_id']),
        createdAt: asCreatedDate(json),
        readAt: asDateTime(json['read_at']),
      );

  bool get isRead => readAt != null;

  /// `image` and `video` messages have nowhere to put a file: the
  /// `chat_attachments` table exists but **no route writes to it**, so the URL
  /// has to travel in [content] like any other text.
  bool get isMedia =>
      type == ChatMessageType.image || type == ChatMessageType.video;

  bool get isShare =>
      type == ChatMessageType.productShare || type == ChatMessageType.orderShare;
}

abstract class ChatMessageType {
  static const String text = 'text';
  static const String image = 'image';
  static const String video = 'video';
  static const String productShare = 'product_share';
  static const String orderShare = 'order_share';

  static String label(String? type) => switch (type) {
        text => 'Pesan',
        image => 'Gambar',
        video => 'Video',
        productShare => 'Produk dibagikan',
        orderShare => 'Pesanan dibagikan',
        _ => type ?? '-',
      };
}
