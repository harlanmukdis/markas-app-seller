import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/chat/chat_conversation.dart';
import '../../../../domain/model/chat/chat_message.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

/// Buyer↔store conversations.
///
/// **Everything here except [getMyBuyerConversations] works for a seller**,
/// because `Chat::guard_participant` admits the store's owner and its active
/// staff as participants. What does not work is *finding* a conversation:
/// `GET /chat/conversations` is buyer-scoped in the model, and no route lists
/// a store's conversations. Until the backend adds one, a thread is reachable
/// only by an id that arrived from somewhere else.
///
/// There is no WebSocket in this build, whatever `docs/03` says about
/// `wss://realtime.marketplace.id` — no such service in `docker-compose.yml`
/// and no socket library in the repo. `send_message` tries to publish to Redis
/// and swallows the failure, so [pollMessages] is the only delivery path that
/// actually exists.
class ChatService extends BaseService {
  const ChatService(super.dio);

  /// The signed-in account's conversations **as a buyer** — not the store's
  /// inbox. Named for what it returns rather than for its path, because the
  /// path reads like the other thing.
  Future<List<ChatConversation>> getMyBuyerConversations() async {
    final envelope = await getRequest(ApiEndpoints.chatConversations);
    return asModelList(envelope.data, ChatConversation.fromJson);
  }

  /// One page of a thread, thirty messages, **newest first**.
  ///
  /// Ordered by `created_at`, which stores whole seconds — two messages sent in
  /// the same second come back in an arbitrary order, so the caller sorts by
  /// id. A non-participant is refused with `403 NOT_PARTICIPANT`.
  Future<List<ChatMessage>> getMessages(int conversationId, {int page = 1}) async {
    final envelope = await getRequest(
      ApiEndpoints.chatMessages(conversationId),
      query: <String, dynamic>{'page': page},
    );
    return asModelList(envelope.data, ChatMessage.fromJson);
  }

  /// Sends a message and returns its id.
  ///
  /// Read as JSON — unlike `POST /chat/conversations` in the same controller,
  /// which uses the REST helper. `content` is nullable and unvalidated: an
  /// empty message is accepted and stored, so the composer refuses one.
  Future<int> sendMessage(
    int conversationId, {
    required String content,
    String type = ChatMessageType.text,
    int? sharedProductId,
    int? sharedOrderId,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.chatMessages(conversationId),
      body: <String, dynamic>{
        'content': content,
        'message_type': type,
        if (sharedProductId != null) 'shared_product_id': sharedProductId,
        if (sharedOrderId != null) 'shared_order_id': sharedOrderId,
      },
    );
    return asInt(envelope.map['id']);
  }

  /// Marks everything the **other** side sent as read. Answers `data: null`.
  Future<void> markRead(int conversationId) async {
    await postRequest(ApiEndpoints.chatRead(conversationId));
  }

  /// Long-poll: returns as soon as a message newer than [sinceId] exists, or
  /// an **empty list** after the server's 25-second hold. An empty result is
  /// the ordinary timeout, not a failure. Unlike [getMessages] it comes back
  /// oldest-first and unpaged.
  ///
  /// ⚠️ **Not used by the app today.** The API runs on `php -S`, which is
  /// single-threaded, so a held request blocks every other one: measured here,
  /// `GET /health` took 23.9s during a poll against 0.00s otherwise. The chat
  /// screen re-reads [getMessages] on a timer instead. Kept because it is
  /// verified and correct, and is the right mechanism the moment the backend
  /// runs behind a worker pool.
  Future<List<ChatMessage>> pollMessages(
    int conversationId, {
    required int sinceId,
  }) async {
    final envelope = await getRequest(
      ApiEndpoints.chatPoll(conversationId),
      query: <String, dynamic>{'since_id': sinceId},
      receiveTimeout: const Duration(seconds: 45),
    );
    return asModelList(envelope.data, ChatMessage.fromJson);
  }
}
