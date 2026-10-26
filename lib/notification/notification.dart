import 'package:flutter/material.dart';
import '../core/providers/auth_provider.dart';
import '../core/models/student_models.dart';
import '../core/widgets/assignment_details_screen.dart';
import '../student_role/Quizzes/student_quiz_questions_screen.dart';
import '../student_role/Quizzes/student_quiz_result_screen.dart';
import '../teacher_role/Quiz_Screen/student_detail.dart';
import '../chat/screens/chat_screen.dart';
import '../chat/models/chat_session_model.dart';
import '../chat/models/chat_role.dart';
import 'notification_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/models/notification_model.dart';
import 'package:opalmer_education/core/providers/notification_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  final String? childId;
  const NotificationScreen({super.key, this.childId});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationsProvider.notifier).load();
      if (!mounted) return;
    });
  }

  Future<void> _open(NotificationModel notification) async {
    try {
      final destination = await ref
          .read(notificationServiceProvider)
          .destination(notification.id);
      final record = Map<String, dynamic>.from(destination['record']);
      final user = ref.read(authStateProvider);
      if (user == null) return;
      Widget page;
      switch (destination['kind']) {
        case 'homework':
          page = AssignmentDetailsScreen(
            homeworkId: record['_id'].toString(),
            childId: user.type == 'parent'
                ? destination['studentId']?.toString()
                : null,
          );
          break;
        case 'grade':
          page = user.type == 'teacher'
              ? StudentDetailScreen(resultId: record['_id'].toString())
              : StudentQuizResultScreen(
                  result: QuizSubmissionResult.fromJson(record),
                );
          break;
        case 'quiz':
          page = user.type == 'student'
              ? StudentQuizQuestionsScreen(quiz: QuizModel.fromJson(record))
              : NotificationDetails(title: notification.title, record: record);
          break;
        case 'message':
          page = ChatScreen(
            session: ChatSessionModel.fromJson(record, user.id),
            role: user.type == 'teacher'
                ? ChatRole.teacher
                : user.type == 'parent'
                ? ChatRole.parent
                : ChatRole.student,
          );
          break;
        default:
          page = NotificationDetails(title: notification.title, record: record);
      }
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This item is unavailable or you no longer have access. Please refresh and retry.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _refresh() =>
      ref.read(notificationsProvider.notifier).load(silent: true);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    final visibleState = widget.childId == null
        ? state
        : state.copyWith(
            items: state.items
                .where((item) => item.studentId == widget.childId)
                .toList(),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(visibleState.unreadCount),
            Expanded(child: _buildBody(visibleState)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int unread) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryMid,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Notification",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          if (unread > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryMid,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unread new',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(NotificationState state) {
    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return _buildError(state.error!);
    }
    if (state.items.isEmpty) {
      return _buildEmpty();
    }

    final groups = _groupByDate(state.items);
    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primaryMid,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: 12,
                  left: 2,
                  top: index == 0 ? 0 : 12,
                ),
                child: Text(
                  group.header,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              ...group.items.map(
                (n) => GestureDetector(
                  onTap: () => _open(n),
                  child: NotificationCard(notification: n),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        const Icon(
          Icons.notifications_off_outlined,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(onPressed: _refresh, child: const Text('Refresh')),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF666666)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMid,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  List<_NotificationGroup> _groupByDate(List<NotificationModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final map = <String, List<NotificationModel>>{};
    final order = <String>[];

    for (final n in items) {
      final created = n.createdAt;
      String key;
      if (created == null) {
        key = 'Earlier';
      } else {
        final d = DateTime(created.year, created.month, created.day);
        if (d == today) {
          key = 'Today';
        } else if (d == yesterday) {
          key = 'Yesterday';
        } else {
          key = _formatDate(d);
        }
      }
      if (!map.containsKey(key)) {
        map[key] = [];
        order.add(key);
      }
      map[key]!.add(n);
    }

    return order
        .map((key) => _NotificationGroup(header: key, items: map[key]!))
        .toList();
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';
}

class _NotificationGroup {
  final String header;
  final List<NotificationModel> items;
  _NotificationGroup({required this.header, required this.items});
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  IconData get _icon {
    switch (notification.type.toLowerCase()) {
      case 'quiz':
      case 'quiz_result':
      case 'grade':
        return Icons.grade_outlined;
      case 'homework':
        return Icons.assignment_outlined;
      case 'lesson':
        return Icons.menu_book_outlined;
      case 'attendance':
        return Icons.how_to_reg_outlined;
      case 'behavior':
        return Icons.psychology_outlined;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'exam':
        return Icons.event_note_outlined;
      case 'schedule':
        return Icons.calendar_today_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isViewed;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread
              ? AppColors.primaryMid.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.primaryMid,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryMid,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                if (notification.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _relativeTime(notification.createdAt!),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '';
  }
}
