import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ProfileController>();
    final home = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => _Avatar(
                    initial: c.initial,
                    displayName: c.displayName,
                    email: c.email,
                  )),
              const SizedBox(height: 24),
              Obx(() => _StatsRow(
                    totalTrades: home.totalTrades,
                    winRate: home.winRate,
                    disciplineScore: home.disciplineScore,
                  )),
              const SizedBox(height: 32),
              const _SectionLabel('Account'),
              const SizedBox(height: 12),
              _Card(
                children: [
                  Obx(() => _EditableTile(
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: c.displayName,
                        onTap: (ctx) => _showEditName(ctx, c),
                      )),
                  const Divider(height: 1),
                  Obx(() => _EditableTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: c.email,
                        onTap: (ctx) => _showEditEmail(ctx, c),
                      )),
                  const Divider(height: 1),
                  _EditableTile(
                    icon: Icons.lock_outline,
                    label: 'Password',
                    value: '••••••••',
                    onTap: (ctx) => _showChangePassword(ctx, c),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionLabel('Data'),
              const SizedBox(height: 12),
              _Card(
                children: [
                  _ActionTile(
                    icon: Icons.delete_outline,
                    label: 'Delete all trades',
                    color: AppColors.loss,
                    onTap: (ctx) => _showDeleteConfirm(ctx, c),
                  ),
                  const Divider(height: 1),
                  _ActionTile(
                    icon: Icons.no_accounts_outlined,
                    label: 'Delete account',
                    color: AppColors.loss,
                    onTap: (ctx) => _showDeleteAccount(ctx, c),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: c.signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('MyFX Mentor v1.0', style: AppTextStyles.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditName(BuildContext ctx, ProfileController c) async {
    final result = await showDialog<String>(
      context: ctx,
      builder: (_) => _EditDialog(
        title: 'Update Name',
        initialValue: c.displayName,
        hint: 'Your name',
        keyboardType: TextInputType.name,
        capitalization: TextCapitalization.words,
        actionLabel: 'Save',
      ),
    );
    if (result == null || result.isEmpty || result == c.displayName) return;
    try {
      await c.updateDisplayName(result);
      Get.snackbar('Done', 'Name updated.', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    } catch (_) {
      Get.snackbar('Error', 'Failed to update name.', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    }
  }

  Future<void> _showEditEmail(BuildContext ctx, ProfileController c) async {
    final result = await showDialog<String>(
      context: ctx,
      builder: (_) => _EditDialog(
        title: 'Update Email',
        initialValue: c.email,
        hint: 'New email address',
        keyboardType: TextInputType.emailAddress,
        actionLabel: 'Send Verification',
      ),
    );
    if (result == null || result.isEmpty || result == c.email) return;
    try {
      await c.updateEmail(result);
      Get.snackbar(
        'Check your inbox',
        'A verification link was sent to $result.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      );
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'requires-recent-login'
          ? 'Sign out and sign back in before changing your email.'
          : 'Failed to update email.';
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    }
  }

  Future<void> _showChangePassword(BuildContext ctx, ProfileController c) async {
    final result = await showDialog<({String current, String next})>(
      context: ctx,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (result == null) return;
    try {
      await c.updatePassword(result.current, result.next);
      Get.snackbar('Done', 'Password updated.', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? 'Current password is incorrect.'
          : e.code == 'weak-password'
              ? 'New password must be at least 6 characters.'
              : 'Failed to update password.';
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    }
  }

  Future<void> _showDeleteAccount(BuildContext ctx, ProfileController c) async {
    final password = await showDialog<String>(
      context: ctx,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (password == null) return;
    try {
      await c.deleteAccount(password);
    } on FirebaseAuthException catch (e) {
      final msg = e.code == 'wrong-password' || e.code == 'invalid-credential'
          ? 'Password is incorrect.'
          : 'Failed to delete account.';
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
    }
  }

  Future<void> _showDeleteConfirm(BuildContext ctx, ProfileController c) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete all trades?'),
        content: const Text('This permanently removes all trade history and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.loss)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await c.deleteAllTrades();
    Get.snackbar('Done', 'All trades deleted.', snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
  }
}

// ─── Delete Account Dialog ────────────────────────────────────────────────────

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _ctrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will permanently delete your account and all trade history. This cannot be undone.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            obscureText: _obscure,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter your password to confirm',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: const Text('Delete Account', style: TextStyle(color: AppColors.loss)),
        ),
      ],
    );
  }
}

// ─── Change Password Dialog ───────────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNext = true;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_next.text != _confirm.text) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }
    if (_next.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    Navigator.pop(context, (current: _current.text.trim(), next: _next.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _current,
            obscureText: _obscureCurrent,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Current password',
              suffixIcon: IconButton(
                icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _next,
            obscureText: _obscureNext,
            decoration: InputDecoration(
              hintText: 'New password',
              suffixIcon: IconButton(
                icon: Icon(_obscureNext ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                onPressed: () => setState(() => _obscureNext = !_obscureNext),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirm,
            obscureText: _obscureNext,
            decoration: const InputDecoration(hintText: 'Confirm new password'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.loss, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: _submit, child: const Text('Update')),
      ],
    );
  }
}

// ─── Edit Dialog (StatefulWidget so TextEditingController is lifecycle-safe) ──

class _EditDialog extends StatefulWidget {
  const _EditDialog({
    required this.title,
    required this.initialValue,
    required this.hint,
    required this.keyboardType,
    required this.actionLabel,
    this.capitalization = TextCapitalization.none,
  });

  final String title;
  final String initialValue;
  final String hint;
  final TextInputType keyboardType;
  final TextCapitalization capitalization;
  final String actionLabel;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.capitalization,
        decoration: InputDecoration(hintText: widget.hint),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.displayName, required this.email});
  final String initial;
  final String displayName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
          child: Center(
            child: Text(initial, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: AppTextStyles.titleLarge),
              const SizedBox(height: 2),
              Text(email, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.totalTrades, required this.winRate, required this.disciplineScore});
  final int totalTrades;
  final double winRate;
  final double disciplineScore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Total Trades', value: '$totalTrades'),
        const SizedBox(width: 12),
        _StatCard(label: 'Win Rate', value: '${(winRate * 100).toStringAsFixed(0)}%'),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Discipline',
          value: '${(disciplineScore * 100).toStringAsFixed(0)}%',
          valueColor: disciplineScore >= 0.7
              ? AppColors.profit
              : disciplineScore >= 0.4
                  ? AppColors.warning
                  : AppColors.textPrimary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.statValue.copyWith(color: valueColor)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.titleSmall.copyWith(color: AppColors.textSecondary));
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _EditableTile extends StatelessWidget {
  const _EditableTile({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final void Function(BuildContext ctx) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Text(value, style: AppTextStyles.labelLarge),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final void Function(BuildContext ctx) onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color)),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
