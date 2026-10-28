import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/teacher_provider.dart';

final guideSchoolProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((
  ref,
) async {
  final user = ref.watch(authStateProvider);
  final schoolId = user?.schoolId;
  if (schoolId == null || schoolId.isEmpty) return null;
  final response = await ref.read(apiClientProvider).get('/school/$schoolId');
  return Map<String, dynamic>.from(response.data['data'] as Map);
});

class _SchoolContext extends ConsumerWidget {
  const _SchoolContext();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(guideSchoolProvider)
        .when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => ListTile(
            title: const Text('Unable to load your school details'),
            trailing: TextButton(
              onPressed: () => ref.invalidate(guideSchoolProvider),
              child: const Text('Retry'),
            ),
          ),
          data: (school) {
            final district = school?['districtId'];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: Text(
                  school?['name']?.toString() ??
                      'No school assigned to your account',
                ),
                subtitle: Text(
                  district is Map
                      ? 'District: ${district['name']} (${district['code']})'
                      : 'Contact your school to verify or update your account’s school and district details.',
                ),
              ),
            );
          },
        );
  }
}

class AccessGuideScreen extends StatelessWidget {
  final String role;
  const AccessGuideScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final steps = <(String, String)>[
      (
        'Sign in',
        'Use the ID or email and password supplied for your own account. Complete email verification if requested. If access fails, contact your school; never share passwords.',
      ),
      if (role == 'parent') ...[
        (
          'Link your child',
          'Ask the school to send an invitation to your account email. Open the child profiles tab, tap +, enter the Student ID and invitation code, then tap Link student.',
        ),
        (
          'Invitation problems',
          'Codes are single use and expire after 72 hours. Check the Student ID, code and account email. Ask your school for a new invitation if a code is expired, already used or incorrect.',
        ),
        (
          'Choose a child',
          'Open a linked child profile and select a subject to view attendance, grades, homework, lessons, behavior and documents available to you. Select the correct child before checking records.',
        ),
        (
          'Access changes',
          'You can view only children linked to your account. If a child is missing or access is denied after unlinking, contact the school to verify the relationship.',
        ),
      ],
      if (role == 'student') ...[
        (
          'Open your subjects',
          'Use Subjects to open your enrolled classes and view lessons, homework and documents shared with you. Contact your school if a class is missing.',
        ),
        (
          'Complete your work',
          'Open a homework assignment, follow its instructions and submit your work. Use Quizzes for published assessments; check the time limit before starting and submit before the deadline.',
        ),
        (
          'Check your progress',
          'View your own attendance and progress in the relevant subject. Assessment results appear when your teacher releases them. You cannot open another student’s private records.',
        ),
      ],
      if (role == 'teacher') ...[
        (
          'Choose your class',
          'Open Classes & students and select an assigned class. Check the roster before recording or sharing information. Contact your school administrator if an assignment is missing.',
        ),
        (
          'Manage class work',
          'Use Assignments, Lessons and Assessments from the menu. Select the class, enter the content, check the intended students and publish when ready.',
        ),
        (
          'Record and review',
          'Use Attendance and Behavior for the selected class. Review submissions in Assignments and scores in Gradebook. Release reviewed assessment results when students should see them.',
        ),
        (
          'Protect student information',
          'Open records only for your assigned classes and students. If access is denied, ask the administrator to verify your assignment. School and district uploads are managed by the platform admin.',
        ),
      ],
      (
        'Return Home',
        'Use Home in the bottom navigation or the Home icon at the top right of a page to return to your dashboard. Save your work first. Choosing Stay here cancels the return; active assessments may require their own exit confirmation. Open How to use from your side menu or Profile.',
      ),
      (
        'Get help',
        'Use Chat to contact an available school contact, or contact your school directly for login, enrollment, invitation or incorrect school details. Include the action and error message, never your password or invitation code.',
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        actions: [const AppHomeButton()],
        title: Text('${role[0].toUpperCase()}${role.substring(1)} guide'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: steps.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (_, index) {
          if (index == 0) return const _SchoolContext();
          index--;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(steps[index].$1),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(steps[index].$2),
              ),
            ),
          );
        },
      ),
    );
  }
}
