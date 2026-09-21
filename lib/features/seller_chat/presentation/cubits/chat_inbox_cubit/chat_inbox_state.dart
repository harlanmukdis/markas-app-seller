part of 'chat_inbox_cubit.dart';

sealed class ChatInboxState {
  const ChatInboxState();
}

final class ChatInboxInProgress extends ChatInboxState {
  const ChatInboxInProgress();
}

final class ChatInboxFailure extends ChatInboxState {
  const ChatInboxFailure(this.error);

  final DataError error;
}

final class ChatInboxLoaded extends ChatInboxState {
  const ChatInboxLoaded({
    required this.buyerConversations,
    this.activeStoreId,
  });

  /// Conversations where this account is the **customer**, newest first. This
  /// is the whole of what the endpoint gives; the store's own inbox has no
  /// endpoint at all.
  final List<ChatConversation> buyerConversations;

  final int? activeStoreId;

  /// Rows pointing at the account's own shop — the result of the account
  /// having opened a conversation with itself, which the server permits. Shown
  /// separately so they are not mistaken for customer enquiries.
  List<ChatConversation> get withOwnStore => buyerConversations
      .where((c) => c.isWithOwnStore(activeStoreId))
      .toList(growable: false);

  List<ChatConversation> get withOtherStores => buyerConversations
      .where((c) => !c.isWithOwnStore(activeStoreId))
      .toList(growable: false);
}
