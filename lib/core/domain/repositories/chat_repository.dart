import '../../data_state.dart';
import '../model/chat/chat.dart';

abstract class ChatRepository {
  Future<DataState<List<ChatThread>>> getThreads();

  Future<DataState<int>> createThread({
    required String channel,
    required String contextType,
    int? contextId,
    int? counterpartyBuyerId,
  });

  Future<DataState<List<ChatMessage>>> getMessages(int threadId);

  /// The returned message carries the censored text, which may differ from
  /// what was sent.
  Future<DataState<ChatMessage>> sendMessage({
    required int threadId,
    required String text,
    String? attachmentUrl,
  });

  Future<DataState<ChatResponseRate>> getResponseRate();
}
