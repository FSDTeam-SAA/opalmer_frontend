import 'package:opalmer_education/core/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:opalmer_education/chat/widgets/block_user_form.dart';
import 'package:opalmer_education/chat/widgets/chat_simple_app_bar.dart';
import 'package:opalmer_education/core/services/api_client.dart';
import 'package:opalmer_education/core/services/attachment_service.dart';

class BlockUserScreen extends StatefulWidget {
  final String userName;
  final String roomId;
  final bool isBlocked;

  const BlockUserScreen({
    super.key,
    required this.userName,
    required this.roomId,
    this.isBlocked = false,
  });

  @override
  State<BlockUserScreen> createState() => _BlockUserScreenState();
}

class _BlockUserScreenState extends State<BlockUserScreen> {
  String _selectedReason = 'Other';
  final TextEditingController _reasonController = TextEditingController();
  bool _busy = false;
  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ApiClient().patch(
        '/rooms/${widget.roomId}/block',
        data: {'blocked': !widget.isBlocked},
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AttachmentService.errorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _selectReason(String reason) {
    setState(() {
      _selectedReason = reason;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatSimpleAppBar(title: widget.isBlocked ? 'Unblock' : 'Block'),
      body: ResponsiveBody(
        child: widget.isBlocked
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: FilledButton(
                  onPressed: _busy ? null : _save,
                  child: const Text('Unblock conversation'),
                ),
              )
            : BlockUserForm(
                userName: widget.userName,
                selectedReason: _selectedReason,
                reasonController: _reasonController,
                onReasonSelected: _selectReason,
                onBlock: _save,
              ),
      ),
    );
  }
}
