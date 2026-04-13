import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_role.dart';
import '../models/chat_session_model.dart';
import '../models/message_model.dart';

class ChatState {
  final List<ChatSessionModel> chats;
  final List<ChatSessionModel> drafts;
  final List<ChatSessionModel> groups;
  final List<MessageModel> messages;

  const ChatState({
    required this.chats,
    required this.drafts,
    required this.groups,
    this.messages = const [],
  });

  factory ChatState.seeded(ChatRole role) {
    final updatedAt = DateTime(2019, 11, 19);

    switch (role) {
      case ChatRole.parent:
        return ChatState(
          chats: [
            ChatSessionModel(
              id: 'parent-teacher-science',
              type: ChatSessionType.direct,
              title: 'Ms. Sarah Michelle',
              subtitle: 'Mia is doing well in science.',
              updatedAt: updatedAt,
              participantIds: const ['parent-1', 'teacher-science'],
              avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
            ),
            ChatSessionModel(
              id: 'parent-teacher-math',
              type: ChatSessionType.direct,
              title: 'Mr. Randolph',
              subtitle: '2pm is awesome',
              updatedAt: updatedAt,
              participantIds: const ['parent-1', 'teacher-math'],
              avatarUrl: 'https://i.pravatar.cc/150?u=randolph',
            ),
          ],
          drafts: [
            ChatSessionModel(
              id: 'parent-draft-teacher',
              type: ChatSessionType.draft,
              title: 'Draft Message',
              subtitle: 'Can we discuss Alex homework?',
              updatedAt: updatedAt,
              participantIds: const ['parent-1', 'teacher-science'],
            ),
          ],
          groups: [
            ChatSessionModel(
              id: 'parent-subject-teachers-science',
              type: ChatSessionType.group,
              title: 'Subject Teachers - Science',
              subtitle: 'Science is going well.',
              updatedAt: updatedAt,
              participantIds: const [
                'parent-1',
                'teacher-science',
                'advisor-1',
              ],
            ),
            ChatSessionModel(
              id: 'parent-subject-teachers-math',
              type: ChatSessionType.group,
              title: 'Subject Teachers - Math',
              subtitle: 'Practice sheets are ready.',
              updatedAt: updatedAt,
              participantIds: const ['parent-1', 'teacher-math', 'advisor-1'],
            ),
          ],
        );
      case ChatRole.student:
        return ChatState(
          chats: [
            ChatSessionModel(
              id: 'student-chat-mia',
              type: ChatSessionType.direct,
              title: 'Mia Johnson',
              subtitle: 'See you in class.',
              updatedAt: updatedAt,
              participantIds: const ['student-1', 'student-mia'],
              avatarUrl: 'https://i.pravatar.cc/150?u=mia',
            ),
          ],
          drafts: const [],
          groups: [
            ChatSessionModel(
              id: 'student-science-group',
              type: ChatSessionType.group,
              title: 'Science Study Group',
              subtitle: 'Quiz review at 4pm.',
              updatedAt: updatedAt,
              participantIds: const [
                'student-1',
                'student-2',
                'teacher-science',
              ],
            ),
          ],
        );
      case ChatRole.teacher:
        return ChatState(
          chats: [
            ChatSessionModel(
              id: 'teacher-randolph',
              type: ChatSessionType.direct,
              title: 'Randolph',
              subtitle: '2pm is awesome',
              updatedAt: updatedAt,
              participantIds: const ['teacher-1', 'randolph'],
              avatarUrl: 'https://i.pravatar.cc/150?u=randolph',
            ),
            ChatSessionModel(
              id: 'teacher-sarah',
              type: ChatSessionType.direct,
              title: 'Sarah Michelle',
              subtitle: '0:14',
              updatedAt: updatedAt,
              participantIds: const ['teacher-1', 'sarah'],
              avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
              previewType: MessagePreviewType.voice,
            ),
            ChatSessionModel(
              id: 'teacher-max',
              type: ChatSessionType.direct,
              title: 'Maximillian Jacobson',
              subtitle: 'Yes, 2pm is awesome',
              updatedAt: updatedAt,
              participantIds: const ['teacher-1', 'max'],
              avatarUrl: 'https://i.pravatar.cc/150?u=max',
              showReadReceipt: true,
            ),
            ChatSessionModel(
              id: 'teacher-martha',
              type: ChatSessionType.direct,
              title: 'Martha Carig',
              subtitle: 'Photo',
              updatedAt: updatedAt,
              participantIds: const ['teacher-1', 'martha'],
              avatarUrl: 'https://i.pravatar.cc/150?u=martha',
              previewType: MessagePreviewType.photo,
            ),
          ],
          drafts: List.generate(
            8,
            (index) => ChatSessionModel(
              id: 'teacher-draft-$index',
              type: ChatSessionType.draft,
              title: 'Draft Message',
              subtitle: 'Actually I wanted to check with you...',
              updatedAt: updatedAt,
              participantIds: const ['teacher-1'],
            ),
          ),
          groups: List.generate(
            8,
            (index) => ChatSessionModel(
              id: 'teacher-grade-${index + 1}-science',
              type: ChatSessionType.group,
              title: 'Grade ${index + 1} - Science',
              subtitle: 'Actually I wanted to check with you...',
              updatedAt: updatedAt,
              participantIds: const ['teacher-1'],
            ),
          ),
        );
    }
  }

  ChatState copyWith({
    List<ChatSessionModel>? chats,
    List<ChatSessionModel>? drafts,
    List<ChatSessionModel>? groups,
    List<MessageModel>? messages,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      drafts: drafts ?? this.drafts,
      groups: groups ?? this.groups,
      messages: messages ?? this.messages,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this.role) : super(ChatState.seeded(role));

  final ChatRole role;

  void receiveMessage(MessageModel message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void saveDraft(ChatSessionModel draft) {
    state = state.copyWith(drafts: [draft, ...state.drafts]);
  }
}

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, ChatRole>(
      (ref, role) => ChatNotifier(role),
    );
