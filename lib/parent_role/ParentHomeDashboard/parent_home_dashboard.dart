import 'dart:convert';
import '../providers/parent_children_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/providers/auth_provider.dart';
import 'package:opalmer_education/core/models/user_model.dart';
import 'package:opalmer_education/core/services/secure_storage_service.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/core/theme/app_colors.dart';
import '../widgets/parent_child_summary_card.dart';
import 'package:opalmer_education/core/widgets/learning_tip_card.dart';
import 'package:opalmer_education/core/widgets/dashboard_header.dart';
import 'package:opalmer_education/parent_role/LearningTipsScreen/models/learning_tip.dart';
import 'package:opalmer_education/parent_role/services/learning_tips_service.dart';
import 'package:opalmer_education/notification/notification.dart';
import 'package:opalmer_education/parent_role/LearningTipsScreen/learning_tips_screen.dart';
import 'package:opalmer_education/parent_role/LearningTipsScreen/learning_tip_detail_screen.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/childs_profiles_screen.dart';
import 'package:opalmer_education/parent_role/ChildsProfilesScreen/models/child_profile.dart';
import 'package:opalmer_education/parent_role/SubjectsScreen/subjects_screen.dart';

class ParentHomeDashboard extends ConsumerStatefulWidget {
  final VoidCallback? onOpenMenu;
  const ParentHomeDashboard({super.key, this.onOpenMenu});

  @override
  ConsumerState<ParentHomeDashboard> createState() =>
      _ParentHomeDashboardState();
}

class _ParentHomeDashboardState extends ConsumerState<ParentHomeDashboard> {
  bool _isLoading = true;
  bool _isLoadingProfiles = true;
  bool _isLoadingTips = true;
  List<ChildProfile> _profiles = [];
  List<LearningTip> _tips = [];
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _loadUserFromStorageIfEmpty();
    _loadProfiles();
    _loadTips();
  }

  Future<void> _loadTips() async {
    try {
      final tips = await LearningTipsService.instance.fetch();
      if (mounted) {
        setState(() {
          _tips = tips;
        });
      }
    } catch (e) {
      debugPrint('Failed to load dashboard learning tips: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTips = false;
        });
      }
    }
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoadingProfiles = true;
    });
    try {
      String? userData = await _storage.getUserData();
      if (userData != null) {
        final userMap = jsonDecode(userData);
        final parentId = userMap['id'] ?? userMap['_id'];

        final response = await _apiClient.get('/parent/child/parent/$parentId');
        if (response.data['success'] == true) {
          final List childrenList = response.data['data']['children'] ?? [];
          if (mounted) {
            setState(() {
              _profiles = childrenList
                  .map((c) {
                    final child = c['childId'];
                    if (child is! Map) return null;
                    return ChildProfile.fromJson(
                      Map<String, dynamic>.from(child),
                      relationId: c['_id']?.toString(),
                    );
                  })
                  .whereType<ChildProfile>()
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to load dashboard profiles: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfiles = false;
        });
      }
    }
  }

  Future<void> _loadUserFromStorageIfEmpty() async {
    // If the global state is null, try to load it from storage
    if (ref.read(authStateProvider) == null) {
      try {
        final userDataStr = await _storage.getUserData();
        if (userDataStr != null) {
          final map = jsonDecode(userDataStr);
          ref.read(authStateProvider.notifier).state = UserModel.fromJson(map);
        }
      } catch (_) {}
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(parentChildrenRevisionProvider, (_, _) {
      _loadProfiles();
      _loadTips();
    });
    final user = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          DashboardHeader(
            name: _isLoading ? '...' : user?.username ?? 'Parent',
            workspace: 'Parent workspace',
            subtitle: "Stay connected with your child's learning.",
            onOpenMenu: widget.onOpenMenu,
            onNotifications: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            ),
          ),

          // Content below header gracefully fills remaining space
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // ── My Students ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "My Students",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChildsProfilesScreen(),
                              ),
                            ).then((_) => _loadProfiles());
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryMid,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoadingProfiles
                      ? const SizedBox(
                          height: 120,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryMid,
                            ),
                          ),
                        )
                      : _profiles.isEmpty
                      ? const SizedBox(
                          height: 120,
                          child: Center(
                            child: Text(
                              "No children added yet.\nTap 'View All' to add.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height:
                              128 *
                              MediaQuery.textScalerOf(
                                context,
                              ).scale(1).clamp(1.0, 2.0),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: _profiles.take(3).map((profile) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: _buildChildCard(profile),
                              );
                            }).toList(),
                          ),
                        ),

                  const SizedBox(height: 32),

                  // ── Learning Tips ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Learning Tips",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LearningTipsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryMid,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoadingTips
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryMid,
                            ),
                          )
                        : _tips.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'No learning tips available yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                children: [
                                  ..._tips.take(5).map((tip) {
                                    return LearningTipCard(
                                      title: tip.title,
                                      imageUrl: tip.imageUrl,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LearningTipDetailScreen(
                                                  tip: tip,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(ChildProfile profile) => ParentChildSummaryCard(
    profile: profile,
    onTap: () {
      final childId = profile.mongoId;
      if (childId == null || childId.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubjectsScreen(
            initialChildId: childId,
            initialChildName: profile.name,
          ),
        ),
      );
    },
  );
}
