import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/app_back_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/providers/student_provider.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import 'package:opalmer_education/student_role/Subjects/widgets/subject_card.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(studentClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: classesAsync.when(
              data: (classes) {
                if (classes.isEmpty) {
                  return const Center(child: Text("No classes found"));
                }
                final gutter = Responsive.gutter(
                  context,
                  maxWidth: Responsive.dashboardMaxWidth,
                  base: 24,
                );
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 100),
                  child: ResponsiveWrapGrid(
                    minTileWidth: 420,
                    maxColumns: 2,
                    children: [
                      for (final studentClass in classes)
                        SubjectCard(
                          width: double.infinity,
                          studentClass: studentClass,
                          subjectName: studentClass.subject,
                        ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Wave Background
        SizedBox(
          width: double.infinity,
          height: 180,
          child: Image.asset(
            'assets/images/Home_dashboard_header.png',
            fit: BoxFit.cover,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.gutter(
                context,
                maxWidth: Responsive.dashboardMaxWidth,
                base: 24,
              ),
              vertical: 20,
            ),
            child: AppPageHeader(
              homeColor: Colors.white,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppBackButton(),
                const Expanded(
                  child: Text(
                    "Classes",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Notification Bell
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
