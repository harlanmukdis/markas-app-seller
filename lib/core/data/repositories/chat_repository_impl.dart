import '../../data_state.dart';
import '../../domain/model/chat/chat.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/remote/service/chat_service.dart';
import 'repository_guard.dart';

class ChatRepositoryImpl with RepositoryGuard implements ChatRepository {
  const ChatRepositoryImpl(this._service);

  final ChatService _service;

  @override
  Future<DataState<List<ChatThread>>> getThreads() =>
      guard(() => _service.getThreads());

  @override
  Future<DataState<int>> createThread({
    required String channel,
    required String contextType,
    int? contextId,
    int? counterpartyBuyerId,
  }) =>
      guard(() => _service.createThread(
            channel: channel,
            contextType: contextType,
            contextId: contextId,
            counterpartyBuyerId: counterpartyBuyerId,
          ));

  @override
  Future<DataState<List<ChatMessage>>> getMessages(int threadId) =>
      guard(() => _service.getMessages(threadId));

  @override
  Future<DataState<ChatMessage>> sendMessage({
    required int threadId,
    required String text,
    String? attachmentUrl,
  }) =>
      guard(() => _service.sendMessage(
            threadId: threadId,
            text: text,
            attachmentUrl: attachmentUrl,
          ));

  @override
  Future<DataState<ChatResponseRate>> getResponseRate() =>
      guard(() => _service.getResponseRate());
}
