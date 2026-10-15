import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_notice.dart';
import '../../core/widgets/election_ui.dart';
import '../../state/election_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});
  final ElectionController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController(text: 'aline@school.edu');
  final passwordController = TextEditingController(text: 'vote2026');
  late final AnimationController animation;
  bool isLogin = true;
  bool obscure = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) animation.stop();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    animation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() => submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    final result = isLogin
        ? widget.controller.login(
            email: emailController.text,
            password: passwordController.text,
          )
        : widget.controller.register(
            name: nameController.text,
            email: emailController.text,
            password: passwordController.text,
          );
    if (result != AuthStatus.success) {
      setState(() => submitting = false);
      final message = switch (result) {
        AuthStatus.invalidEmail => 'Enter a valid school email address.',
        AuthStatus.weakPassword =>
          isLogin
              ? 'Password must be at least 4 characters.'
              : 'Create a password with at least 6 characters.',
        AuthStatus.emptyName => 'Tell us your full name.',
        AuthStatus.success => '',
      };
      showNotice(context, message: message, tone: NoticeTone.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 860;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: wide
                    ? Row(
                        children: [
                          Expanded(child: _visualPanel()),
                          Expanded(child: _formPanel()),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [_mobileVisual(), _formPanel()],
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _visualPanel() => Container(
    margin: const EdgeInsets.all(18),
    padding: const EdgeInsets.all(38),
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BallotBrand(light: true),
        const Spacer(),
        Center(child: _floatingArt(300)),
        const Spacer(),
        Text(
          'Your class.\nYour voice.',
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(color: Colors.white, fontSize: 50),
        ),
        const SizedBox(height: 14),
        Text(
          'A real-feeling election space for campaigns, secure ballots, and transparent results.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 26),
        const Row(
          children: [
            _TrustPoint(Icons.verified_user_outlined, 'Verified students'),
            SizedBox(width: 20),
            _TrustPoint(Icons.lock_outline_rounded, 'Private ballots'),
          ],
        ),
      ],
    ),
  );

  Widget _mobileVisual() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
    child: Row(
      children: [
        const BallotBrand(),
        const Spacer(),
        SizedBox(width: 92, height: 78, child: _floatingArt(100)),
      ],
    ),
  );

  Widget _floatingArt(double size) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = animation.value;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, .001)
          ..translateByDouble(0, math.sin(t * math.pi) * -10, 0, 1)
          ..rotateY((t - .5) * .08),
        child: child,
      );
    },
    child: Image.asset(
      'assets/images/ballot-box-3d.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'A secure ballot box',
    ),
  );

  Widget _formPanel() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLogin ? 'Welcome back' : 'Join your class',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isLogin ? 'Sign in to see your active class elections.' : 'Create a student account. This demo accepts any valid email.',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 26),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.soft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _authTab('Log in', true),
                  _authTab('Register', false),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: isLogin
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        TextField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'School email',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passwordController,
              obscureText: obscure,
              autofillHints: [
                isLogin ? AutofillHints.password : AutofillHints.newPassword,
              ],
              onSubmitted: (_) => submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: obscure ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: submitting ? null : submit,
                icon: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.ink,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  submitting
                      ? 'Checking…'
                      : isLogin
                      ? 'Enter election space'
                      : 'Create account',
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.controller.continueDemo,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('Explore demo account'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 17,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Mock authentication for classroom demonstration only.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _authTab(String label, bool login) => Expanded(
    child: Semantics(
      selected: isLogin == login,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => setState(() => isLogin = login),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isLogin == login ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isLogin == login
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .07),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isLogin == login ? AppColors.ink : AppColors.muted,
            ),
          ),
        ),
      ),
    ),
  );
}

class _TrustPoint extends StatelessWidget {
  const _TrustPoint(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: AppColors.primary, size: 19),
      const SizedBox(width: 7),
      Text(
        label,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(color: Colors.white),
      ),
    ],
  );
}
