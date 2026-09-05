import '../../../../../config/network/api_endpoints.dart';
import '../../../../domain/model/chat/chat.dart';
import '../../../../utils/json_parse.dart';
import 'base_service.dart';

class ChatService extends BaseService {
  const ChatService(super.dio);

  Future<List<ChatThread>> getThreads() async {
    final envelope = await getRequest(ApiEndpoints.chatThreads);
    return envelope
        .listAt('threads')
        .map(ChatThread.fromJson)
        .toList(growable: false);
  }

  Future<int> createThread({
    required String channel,
    required String contextType,
    int? contextId,
    int? counterpartyBuyerId,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.chatThreads,
      body: <String, dynamic>{
        'channel': channel,
        'context_type': contextType,
        'context_id': contextId,
        'counterparty_buyer_id': counterpartyBuyerId,
      },
    );
    return asInt(envelope.map['id'] ?? envelope.map['thread_id']);
  }

  Future<List<ChatMessage>> getMessages(int threadId) async {
    final envelope = await getRequest(
      ApiEndpoints.chatMessages,
      query: <String, dynamic>{'thread_id': threadId},
    );
    return envelope
        .listAt('messages')
        .map(ChatMessage.fromJson)
        .toList(growable: false);
  }

  /// The stored text comes back censored — phone numbers are masked until the
  /// related order is paid, and bank accounts or off-platform invitations are
  /// always blocked. Compare the response against what was sent so the store
  /// can be told why its message changed.
  Future<ChatMessage> sendMessage({
    required int threadId,
    required String text,
    String? attachmentUrl,
  }) async {
    final envelope = await postRequest(
      ApiEndpoints.chatMessages,
      body: <String, dynamic>{
        'thread_id': threadId,
        'text': text,
        'attachment_url': attachmentUrl,
      },
    );
    return ChatMessage.fromJson(envelope.map);
  }

  /// No parameters — a `SEL` token resolves to this store. The figure appears
  /// on the store's public page, so it belongs on the dashboard.
  Future<ChatResponseRate> getResponseRate() async {
    final envelope = await getRequest(ApiEndpoints.chatResponseRate);
    return ChatResponseRate.fromJson(envelope.map);
  }
}
