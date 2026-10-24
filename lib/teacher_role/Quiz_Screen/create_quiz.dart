import 'package:opalmer_education/core/widgets/app_dropdown_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opalmer_education/core/constants/api_constants.dart';
import 'package:opalmer_education/core/providers/grading_provider.dart';
import 'package:opalmer_education/core/providers/teacher_provider.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  List<dynamic> _generatedQuestions = [];
  bool _isGenerating = false;
  String? _selectedClassId;

  @override
  void dispose() {
    _timeController.dispose();
    _promptController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _generateQuestions() async {
    if (_promptController.text.isEmpty) return;

    setState(() => _isGenerating = true);
    try {
      final questions = await ref
          .read(gradingActionProvider.notifier)
          .generateAIQuestions(_promptController.text);
      if (!mounted) return;
      setState(() {
        _generatedQuestions = questions;
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _handleSave({bool publish = false}) async {
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a class")));
      return;
    }
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a quiz title")),
      );
      return;
    }
    if (_generatedQuestions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No questions generated")));
      return;
    }

    final questionsPayload = _generatedQuestions
        .map(
          (q) => {
            'question': q['question'],
            'options': List<String>.from(q['options']),
            'answer': q['answer'],
            'explanation': q['explanation'] ?? '',
            'difficulty': q['difficulty'] ?? 'medium',
            'type': q['type'] ?? 'normal',
            'imagePrompt': q['imagePrompt'] ?? '',
            'imageUrl': q['imageUrl'] ?? '',
          },
        )
        .toList();

    final success = await ref
        .read(gradingActionProvider.notifier)
        .createAndSaveSession(
          classId: _selectedClassId!,
          title: _titleController.text,
          questions: questionsPayload,
          time: int.tryParse(_timeController.text),
          publish: publish,
        );

    if (success != null && mounted) {
      ref.invalidate(teacherQuizzesProvider);
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to save quiz")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(teacherClassesProvider);
    final gradingState = ref.watch(gradingActionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF871DAD),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "Create Quiz",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _buildInputLabel("Class"),
              const SizedBox(height: 8),
              classesAsync.when(
                data: (classes) => AppDropdownField<String>(
                  value: _selectedClassId,
                  hintText: classes.isEmpty
                      ? "No classes available"
                      : "Choose a class",
                  prefixIcon: const Icon(Icons.school_outlined, size: 20),
                  items: classes
                      .map(
                        (cls) => DropdownMenuItem(
                          value: cls.id,
                          child: Text(
                            '${cls.subject} · Grade ${cls.grade}'
                            '${cls.section?.trim().isNotEmpty == true ? ' · ${cls.section}' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedClassId = value),
                ),
                loading: () => const Center(child: LinearProgressIndicator()),
                error: (_, __) => const Text("Error loading classes"),
              ),

              const SizedBox(height: 16),
              _buildInputLabel("Quiz Title"),
              const SizedBox(height: 8),
              _buildTextField(
                hint: "e.g. Fractions practice",
                controller: _titleController,
              ),

              const SizedBox(height: 16),
              _buildInputLabel("Quiz Time (minutes)"),
              const SizedBox(height: 8),
              _buildTextField(
                hint: "e.g. 15",
                controller: _timeController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),
              _buildInputLabel("AI Prompt"),
              const SizedBox(height: 8),
              _buildTextField(
                hint: "Describe the topic and questions you need…",
                controller: _promptController,
                maxLines: 3,
                suffixIcon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Generate questions',
                        icon: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF871DAD),
                          size: 20,
                        ),
                        onPressed: _generateQuestions,
                      ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Generated Questions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 16),

              if (_generatedQuestions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F6FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        color: Color(0xFF871DAD),
                        size: 28,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your questions will appear here',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Add a prompt above, then tap the sparkle icon.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF787481),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

              ...List.generate(_generatedQuestions.length, (index) {
                final q = _generatedQuestions[index];
                return _buildQuestionTile(
                  number: index + 1,
                  question: q['question'] ?? '',
                  options: List<String>.from(q['options'] ?? []),
                  answer: q['answer'] ?? '',
                  explanation: q['explanation']?.toString() ?? '',
                  type: q['type']?.toString() ?? 'normal',
                  difficulty: q['difficulty']?.toString() ?? 'medium',
                  imageUrl: q['imageUrl']?.toString() ?? '',
                );
              }),
            ],
          ),

          if (gradingState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: gradingState.isLoading
                      ? null
                      : () => _handleSave(publish: false),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF871DAD),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "DRAFT",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF871DAD),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: gradingState.isLoading
                      ? null
                      : () => _handleSave(publish: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF871DAD),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "PUBLISH",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF494451),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 2 : null,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(hintText: hint, suffixIcon: suffixIcon),
    );
  }

  Widget _buildQuestionTile({
    required int number,
    required String question,
    List<String>? options,
    String? answer,
    String explanation = '',
    String type = 'normal',
    String difficulty = 'medium',
    String imageUrl = '',
    bool initiallyExpanded = false,
  }) {
    final resolvedImageUrl = ApiConstants.buildImageUrl(imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            "$number. $question",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
            ),
          ),
          children: [
            if (options != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuestionChip(type),
                        _buildQuestionChip(difficulty),
                      ],
                    ),
                    if (resolvedImageUrl.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          resolvedImageUrl,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 120,
                            alignment: Alignment.center,
                            color: Colors.grey.shade100,
                            child: Text(
                              'Image preview unavailable',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ...List.generate(options.length, (i) {
                      final char = String.fromCharCode(65 + i);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "$char. ${options[i]}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }),
                    if (answer != null) ...[
                      const Divider(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Answer: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              answer,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (explanation.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        explanation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionChip(String label) {
    final normalizedLabel = label.trim().isEmpty ? 'normal' : label.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF871DAD).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalizedLabel.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF871DAD),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
