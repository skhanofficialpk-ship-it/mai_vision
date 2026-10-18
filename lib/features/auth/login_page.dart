import 'dart:async';
import 'dart:ui';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

// ─── LOCAL STORAGE HELPERS FOR PERSISTENT LOCKOUT ───
int _getStoredFailedAttempts() {
  if (kIsWeb) {
    try {
      final val = html.window.localStorage['admin_failed_attempts'];
      return int.tryParse(val ?? '0') ?? 0;
    } catch (_) {}
  }
  return 0;
}

void _setStoredFailedAttempts(int count) {
  if (kIsWeb) {
    try {
      html.window.localStorage['admin_failed_attempts'] = count.toString();
    } catch (_) {}
  }
}

int _getStoredLockoutUntil() {
  if (kIsWeb) {
    try {
      final val = html.window.localStorage['admin_lockout_until'];
      return int.tryParse(val ?? '0') ?? 0;
    } catch (_) {}
  }
  return 0;
}

void _setStoredLockoutUntil(int epochMs) {
  if (kIsWeb) {
    try {
      html.window.localStorage['admin_lockout_until'] = epochMs.toString();
    } catch (_) {}
  }
}

void _clearStoredLockout() {
  if (kIsWeb) {
    try {
      html.window.localStorage.remove('admin_failed_attempts');
      html.window.localStorage.remove('admin_lockout_until');
    } catch (_) {}
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  int _failedAttempts = 0;
  int _lockoutUntilMs = 0;
  Timer? _countdownTimer;
  Duration _remainingLockout = Duration.zero;
  bool _isLockedOut = false;

  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _entryController.forward();
    _loadLockoutState();
  }

  void _loadLockoutState() {
    _failedAttempts = _getStoredFailedAttempts();
    _lockoutUntilMs = _getStoredLockoutUntil();
    _checkLockoutTimer();
  }

  void _checkLockoutTimer() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lockoutUntilMs > now) {
      _isLockedOut = true;
      _remainingLockout = Duration(milliseconds: _lockoutUntilMs - now);
      _startCountdownTimer();
    } else {
      if (_isLockedOut || _lockoutUntilMs > 0) {
        // Lockout expired -> Reset state
        _clearStoredLockout();
        _failedAttempts = 0;
        _isLockedOut = false;
        _remainingLockout = Duration.zero;
        _error = null;
      }
    }
    if (mounted) setState(() {});
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (_lockoutUntilMs > now) {
        if (mounted) {
          setState(() {
            _isLockedOut = true;
            _remainingLockout = Duration(milliseconds: _lockoutUntilMs - now);
          });
        }
      } else {
        timer.cancel();
        _clearStoredLockout();
        if (mounted) {
          setState(() {
            _failedAttempts = 0;
            _isLockedOut = false;
            _remainingLockout = Duration.zero;
            _error = null;
          });
        }
      }
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }

  Future<void> _login() async {
    if (_isLockedOut) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .signInWithEmail(_email.text.trim(), _password.text.trim());

      // Reset lockout on successful login
      _clearStoredLockout();
      if (mounted) context.go('/admin');
    } on FirebaseAuthException catch (e) {
      _handleFailedAttempt(_mapError(e.code));
    } catch (e) {
      _handleFailedAttempt('Login failed. Please check your credentials.');
    }
  }

  void _handleFailedAttempt(String baseErrorMessage) {
    _failedAttempts++;
    _setStoredFailedAttempts(_failedAttempts);

    final remaining = (5 - _failedAttempts).clamp(0, 5);

    if (_failedAttempts >= 5) {
      // 5 Failed Attempts -> 1 Hour Lockout!
      final lockoutUntil = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
      _lockoutUntilMs = lockoutUntil;
      _setStoredLockoutUntil(lockoutUntil);
      _isLockedOut = true;
      _remainingLockout = const Duration(hours: 1);
      _loading = false;
      _error = null;
      _startCountdownTimer();
    } else {
      _loading = false;
      _error = '$baseErrorMessage\n⚠️ Warning: $remaining ${_pluralizeAttempts(remaining)} left.';
    }

    if (mounted) setState(() {});
  }

  String _pluralizeAttempts(int count) {
    return count == 1 ? 'attempt' : 'attempts';
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found': return 'No account found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'invalid-email': return 'Invalid email address.';
      case 'invalid-credential': return 'Invalid email or password.';
      default: return 'Login failed. Please check your credentials.';
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _email.dispose();
    _password.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── IMAGE BACKGROUND ───
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Dark overlay for readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // ─── GLASS LOGIN CARD ───
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo
                                _BuildLogo(),
                                const SizedBox(height: 24),
                                
                                const Text(
                                  'MAI Academy',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                    shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
                                  ),
                                ),
                                const Text(
                                  'ADMINISTRATOR ACCESS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 36),

                                // Lockout or Error Warning
                                if (_isLockedOut)
                                  _BuildLockoutMessage(remainingTimeStr: _formatDuration(_remainingLockout))
                                else if (_error != null)
                                  _BuildErrorMessage(error: _error!),

                                // Email
                                _InputField(
                                  controller: _email,
                                  label: 'Email Address',
                                  icon: Icons.alternate_email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !_isLockedOut && !_loading,
                                ),
                                const SizedBox(height: 20),

                                // Password
                                _InputField(
                                  controller: _password,
                                  label: 'Password',
                                  icon: Icons.lock_open_rounded,
                                  obscureText: _obscure,
                                  enabled: !_isLockedOut && !_loading,
                                  suffix: IconButton(
                                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                                      size: 20, color: Colors.white70),
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                  ),
                                  onSubmitted: (_) => _login(),
                                ),
                                
                                const SizedBox(height: 36),

                                // Login Button
                                _LoginButton(
                                  loading: _loading, 
                                  disabled: _isLockedOut,
                                  onTap: _login,
                                ),
                                
                                const SizedBox(height: 28),
                                
                                TextButton(
                                  onPressed: () => context.go('/'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                                  child: const Text('← Return to Public Website', 
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final bool enabled;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Function(String)? onSubmitted;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.enabled = true,
    this.suffix,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      onFieldSubmitted: onSubmitted,
      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5)
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _LoginButton({
    required this.loading,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: disabled
              ? [Colors.grey.shade700, Colors.grey.shade800]
              : [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: disabled
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (loading || disabled) ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: loading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    disabled ? 'LOCKED OUT' : 'SIGN IN TO DASHBOARD',
                    style: TextStyle(
                      color: disabled ? Colors.white54 : Colors.white, 
                      fontWeight: FontWeight.w800, 
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _BuildLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
      ),
      padding: const EdgeInsets.all(15),
      child: Image.asset(
        'assets/images/logo.png',
        errorBuilder: (c, e, s) => const Icon(Icons.security, size: 44, color: Colors.white),
      ),
    );
  }
}

class _BuildErrorMessage extends StatelessWidget {
  final String error;
  const _BuildErrorMessage({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error, 
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildLockoutMessage extends StatelessWidget {
  final String remainingTimeStr;
  const _BuildLockoutMessage({required this.remainingTimeStr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade900.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 15),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock_rounded, color: Colors.redAccent, size: 22),
              SizedBox(width: 8),
              Text(
                'SECURITY LOCKOUT ACTIVE',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '5 failed login attempts detected. Access is temporarily disabled for 1 hour to protect against unauthorized entry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
            ),
            child: Text(
              'Try again in $remainingTimeStr',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
