import 'package:flutter/material.dart';
import '../../core/widgets/policy_content_screen.dart';
import '../../core/services/policy_content_service.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const PolicyContentScreen(type: PolicyContentType.terms);
}
