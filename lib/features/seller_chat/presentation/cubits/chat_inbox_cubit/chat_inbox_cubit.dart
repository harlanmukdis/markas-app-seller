import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/chat/chat_conversation.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/chat_repository.dart';
import '../../../../../di/injector.dart';

part 'chat_inbox_state.dart';

/// What the chat list can show, which is not what a seller wants.
///
/// `GET /chat/conversations` is buyer-scoped in the backend model, and no
/// route lists a store's conversations — so this loads the account's own
/// conversations *as a customer* and reports the gap rather than passing them
/// off as the store's inbox.
class ChatInboxCubit extends Cubit<ChatInboxState> {
  ChatInboxCubit() : super(const ChatInboxInProgress());

  static ChatInboxCubit get(BuildContext context) => BlocProvider.of(context);

  final ChatRepository _chat = injector<ChatRepository>();
  final AuthRepository _auth = injector<AuthRepository>();

  Future<void> load() async {
    if (isClosed) return;
    emit(const ChatInboxInProgress());

    final result = await _chat.getMyBuyerConversations();
    if (isClosed) return;

    switch (result) {
      case DataSuccess<List<ChatConversation>>(:final value):
        emit(_loaded(value));
      case DataEmpty<List<ChatConversation>>():
        emit(_loaded(const <ChatConversation>[]));
      case DataFailed<List<ChatConversation>>(:final failure):
        emit(ChatInboxFailure(failure));
      default:
        emit(const ChatInboxFailure(
          DataError(
            code: DataErrorCode.unexpected,
            message: 'Daftar percakapan tidak bisa dibaca.',
          ),
        ));
    }
  }

  ChatInboxLoaded _loaded(List<ChatConversation> conversations) =>
      ChatInboxLoaded(
        buyerConversations: conversations,
        activeStoreId: _auth.activeStoreId,
      );
}
