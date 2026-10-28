import 'package:opalmer_education/core/widgets/app_home_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../Authentication_Screen/registration_successful_screen.dart';
import '../../core/constants/api_constants.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isRegistrationFlow;
  final ImagePicker? imagePicker;
  const ProfileSetupScreen({
    super.key,
    this.isRegistrationFlow = false,
    this.imagePicker,
  });
  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  static const _purple = Color(0xFF871DAD);
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _subjects = <String>{};
  String? _grade;
  String? _state;
  Uint8List? _photo;
  String? _filename;
  bool _removeAvatar = false;
  bool _saving = false;
  bool _picking = false;
  bool _prefilled = false;
  String? _error;
  static const _subjectOptions = [
    'Math',
    'Science',
    'Reading',
    'History',
    'Social Studies',
  ];
  static const _states = [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'District of Columbia',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming',
  ];

  void _prefill(UserModel? user) {
    if (_prefilled || user == null) return;
    _name.text = user.username;
    _phone.text = user.phoneNumber ?? '';
    _grade = user.gradeLevel;
    _state = user.locationState?.isNotEmpty == true ? user.locationState : null;
    _subjects.addAll(user.subjects);
    _prefilled = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(sheet, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(sheet, ImageSource.camera),
            ),
            if (_photo != null ||
                (!_removeAvatar &&
                    ref.read(authStateProvider)?.avatar?.isNotEmpty == true))
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remove photo'),
                onTap: () {
                  setState(() {
                    _photo = null;
                    _filename = null;
                    _removeAvatar = true;
                  });
                  Navigator.pop(sheet);
                },
              ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final image = await (widget.imagePicker ?? ImagePicker()).pickImage(
        source: source,
        maxWidth: 1400,
        maxHeight: 1400,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024 ||
          !RegExp(
            r'\.(jpe?g|png)$',
            caseSensitive: false,
          ).hasMatch(image.name)) {
        throw Exception('Choose a JPG or PNG under 5 MB.');
      }
      if (!mounted) return;
      setState(() {
        _photo = bytes;
        _filename = image.name;
        _removeAvatar = false;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Unable to select this photo. Check camera/photos permission and choose a JPG or PNG under 5 MB.',
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authStateProvider);
    if (user == null) {
      setState(() => _error = 'Please sign in again to save your profile.');
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(authServiceProvider)
          .updateProfile(
            userId: user.id,
            updates: {
              'username': _name.text.trim(),
              'phoneNumber': _phone.text.trim(),
              if (_grade != null &&
                  int.tryParse(_grade!) != null &&
                  int.parse(_grade!) <= 12)
                'gradeLevel': int.parse(_grade!),
              'locationState': _state ?? '',
              'subjects': _subjects.toList(),
              if (_removeAvatar) 'removeAvatar': true,
            },
            avatarBytes: _photo,
            avatarFilename: _filename,
          );
      ref.read(authStateProvider.notifier).state = updated;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      if (widget.isRegistrationFlow) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const RegistrationSuccessfulScreen(),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Your profile could not be saved. Your changes are still here; please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 21, color: const Color(0xFF81748B)),
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF342C3B),
      ),
    ),
  );
  Widget _emptyAvatar() => Container(
    color: const Color(0xFFF5EDF9),
    alignment: Alignment.center,
    child: const Icon(
      Icons.person_outline_rounded,
      size: 54,
      color: Color(0xFFB088C2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    _prefill(user);
    final avatar = _removeAvatar
        ? null
        : ApiConstants.buildImageUrl(user?.avatar);
    final busy = _saving || _picking;
    final subjectOptions = {..._subjectOptions, ..._subjects};
    final states = {..._states, ?_state}.toList()..sort();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6FB),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 56),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF951EC2), Color(0xFF74189D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(36),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 680),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  76,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppPageHeader(
                                      homeColor: Colors.white,
                                      children: [
                                        IconButton.filledTonal(
                                          onPressed: busy
                                              ? null
                                              : () =>
                                                    Navigator.maybePop(context),
                                          tooltip: 'Back',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.white
                                                .withValues(alpha: 0.16),
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(
                                            Icons.arrow_back_rounded,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        const Expanded(
                                          child: Text(
                                            'Profile Setup',
                                            style: TextStyle(
                                              fontSize: 27,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Complete your profile to connect with your students and school.',
                                      style: TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Upload profile photo',
                      child: InkWell(
                        onTap: busy ? null : _choosePhoto,
                        borderRadius: BorderRadius.circular(64),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 116,
                              height: 116,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE8D3F2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _purple.withValues(alpha: 0.09),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _photo != null
                                    ? Image.memory(
                                        _photo!,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      )
                                    : avatar != null && avatar.isNotEmpty
                                    ? Image.network(
                                        avatar,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _emptyAvatar(),
                                      )
                                    : _emptyAvatar(),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _purple,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 17,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: busy ? null : _choosePhoto,
                  child: Text(
                    _picking
                        ? 'Selecting photo...'
                        : _photo != null || avatar?.isNotEmpty == true
                        ? 'Change profile photo'
                        : 'Upload profile photo',
                    style: const TextStyle(
                      color: _purple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  'Optional · JPG or PNG · Up to 5 MB',
                  style: TextStyle(fontSize: 12, color: Color(0xFF81748B)),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFEDE7F2)),
                        ),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Personal information',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF302538),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Keep your details up to date.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF81748B),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _label('Name'),
                              TextFormField(
                                key: const Key('profile-name'),
                                controller: _name,
                                enabled: !busy,
                                decoration: _decoration(
                                  'Enter your full name',
                                  Icons.person_outline_rounded,
                                ),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                maxLength: 100,
                                buildCounter:
                                    (
                                      _, {
                                      required currentLength,
                                      required isFocused,
                                      maxLength,
                                    }) => null,
                                validator: (value) =>
                                    (value ?? '').trim().isEmpty
                                    ? 'Enter your name'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              _label('Contact number'),
                              TextFormField(
                                key: const Key('profile-phone'),
                                controller: _phone,
                                enabled: !busy,
                                decoration: _decoration(
                                  'Enter your phone number',
                                  Icons.phone_outlined,
                                ),
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.telephoneNumber,
                                ],
                                validator: (value) {
                                  final text = (value ?? '').trim();
                                  final digits = text.replaceAll(
                                    RegExp(r'\D'),
                                    '',
                                  );
                                  return text.isNotEmpty &&
                                          (!RegExp(
                                                r'^\+?[0-9 ()\-.]+$',
                                              ).hasMatch(text) ||
                                              digits.length < 7 ||
                                              digits.length > 15)
                                      ? 'Enter a valid contact number'
                                      : null;
                                },
                              ),
                              const SizedBox(height: 20),
                              _label('Grade level'),
                              DropdownButtonFormField<String>(
                                key: const Key('profile-grade'),
                                initialValue:
                                    List.generate(
                                      12,
                                      (i) => '${i + 1}',
                                    ).contains(_grade)
                                    ? _grade
                                    : null,
                                isExpanded: true,
                                decoration: _decoration(
                                  'Select your grade level',
                                  Icons.school_outlined,
                                ),
                                hint: const Text('Select your grade level'),
                                items: List.generate(
                                  12,
                                  (i) => DropdownMenuItem(
                                    value: '${i + 1}',
                                    child: Text('Grade ${i + 1}'),
                                  ),
                                ),
                                onChanged: busy
                                    ? null
                                    : (value) => setState(() => _grade = value),
                              ),
                              const SizedBox(height: 20),
                              _label('State'),
                              DropdownButtonFormField<String>(
                                key: const Key('profile-state'),
                                initialValue: _state,
                                isExpanded: true,
                                decoration: _decoration(
                                  'Select your state',
                                  Icons.location_on_outlined,
                                ),
                                hint: const Text('Select your state'),
                                items: states
                                    .map(
                                      (state) => DropdownMenuItem(
                                        value: state,
                                        child: Text(
                                          state,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: busy
                                    ? null
                                    : (value) => setState(() => _state = value),
                              ),
                              const SizedBox(height: 24),
                              _label('Subjects'),
                              const Text(
                                'Select all subjects you teach.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF81748B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 9,
                                runSpacing: 9,
                                children: subjectOptions
                                    .map(
                                      (subject) => FilterChip(
                                        label: Text(subject),
                                        selected: _subjects.contains(subject),
                                        onSelected: busy
                                            ? null
                                            : (selected) => setState(() {
                                                if (selected) {
                                                  _subjects.add(subject);
                                                } else {
                                                  _subjects.remove(subject);
                                                }
                                              }),
                                        selectedColor: const Color(0xFFF0DFF8),
                                        checkmarkColor: _purple,
                                        labelStyle: TextStyle(
                                          fontSize: 13,
                                          color: _subjects.contains(subject)
                                              ? _purple
                                              : const Color(0xFF655A6D),
                                        ),
                                        side: BorderSide(
                                          color: _subjects.contains(subject)
                                              ? _purple.withValues(alpha: 0.4)
                                              : const Color(0xFFE9E3ED),
                                        ),
                                        backgroundColor: const Color(
                                          0xFFFCFAFD,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: Color(0xFFB3261E),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 28),
                              FilledButton(
                                onPressed: busy ? null : _save,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _purple,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _saving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Save changes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
