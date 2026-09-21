import '../../../utils/json_parse.dart';

/// One row of `GET /chat/conversations`.
///
/// ⚠️ **That endpoint is buyer-scoped.** `Chat_model::list_conversations`
/// filters on `cc.buyer_id = <signed in user>`, so it answers with the
/// conversations in which *you* are the customer — never the ones belonging to
/// a store you own. Verified live: after a buyer wrote to store 1, its owner
/// still received an empty array.
///
/// There is no store-scoped equivalent. The schema is ready for one — it
/// carries `idx_conversations_store (store_id, last_message_at)`, an index
/// with no query behind it — but no route reaches it, so a seller inbox cannot
/// be built until the backend adds `GET /stores/{id}/chat/conversations`.
class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.buyerId,
    required this.storeId,
    this.storeName,
    this.lastMessageAt,
    this.createdAt,
  });

  final int id;
  final int buyerId;
  final int storeId;

  /// Joined from `stores`. Present because this list is written for the buyer,
  /// who needs the shop's name — the counterpart a seller would need, the
  /// buyer's name, is **not** joined anywhere.
  final String? storeName;

  /// Null until the first message. Ordering is by this column, so a
  /// conversation that was opened and never used sorts last.
  final DateTime? lastMessageAt;

  final DateTime? createdAt;

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      ChatConversation(
        id: asInt(json['id']),
        buyerId: asInt(json['buyer_id']),
        storeId: asInt(json['store_id']),
        storeName: asStringOrNull(json['store_name']),
        lastMessageAt: asDateTime(json['last_message_at']),
        createdAt: asCreatedDate(json),
      );

  /// True when the signed-in account owns the store on the other end — which
  /// on this endpoint means the account opened a conversation with its **own**
  /// shop. The server allows that (it answers `201` and makes a row where
  /// buyer and owner are the same person); the app never offers it.
  bool isWithOwnStore(int? activeStoreId) =>
      activeStoreId != null && storeId == activeStoreId;

  bool get hasMessages => lastMessageAt != null;
}
