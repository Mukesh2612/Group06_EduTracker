import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../admin/admin_dashboard.dart';
import '../student/student_dashboard.dart';
import '../Fa/fa_dashboard.dart';
import '../config/api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/session.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  // ── Colors ──────────────────────────────────────────────
  static const _bg      = Color(0xFFF5F7FA);
  static const _white   = Colors.white;
  static const _navy    = Color(0xFF03305A);
  static const _blue    = Color(0xFF0077B6);
  static const _border  = Color(0xFFD8E3ED);
  static const _muted   = Color(0xFF6B7C93);
  static const _hint    = Color(0xFFAAB8C5);

  // ── State ────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _showPass   = false;
  bool _isLoading  = false;
  int  _roleIndex  = 0; // 0=Student 1=Faculty 2=Admin

  final _roles = ['Student', 'Faculty', 'Admin'];

  // ── Google sign-in ───────────────────────────────────────
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  // ── Normal login ─────────────────────────────────────────
  Future<void> _loginUser() async {
    final e = _emailCtrl.text.trim();
    final p = _passCtrl.text.trim();
    setState(() => _isLoading = true);

    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final res = await http.post(
        Uri.parse('$BASE_URL/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': e, 'password': p, 'fcmToken': fcmToken}),
      );

      if (res.statusCode == 200) {
        final data       = jsonDecode(res.body);
        final role       = data['role'];
        final firstLogin = data['firstLogin'] ?? false;

        if (firstLogin == true) {
          _go(ChangePasswordPage(prefilledEmail: e));
          return;
        }
        _navigate(role, data);
      } else {
        _msg('Invalid email or password');
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      _msg('Cannot connect to server');
    }

    setState(() => _isLoading = false);
  }

  // ── Google login ─────────────────────────────────────────
  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final cred = await _signInWithGoogle();
      if (cred == null) { _msg('Google sign-in cancelled'); setState(() => _isLoading = false); return; }

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final res = await http.post(
        Uri.parse('$BASE_URL/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _navigate(data['role'], data);
      } else if (res.statusCode == 403) {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
        _msg('Your email is not registered in the system');
      } else {
        _msg('Google login failed. Try again.');
      }
    } catch (e) {
      debugPrint('GOOGLE LOGIN ERROR: $e');
      _msg('Cannot connect to server');
    }
    setState(() => _isLoading = false);
  }

  void _navigate(String? role, Map data) async {
    // ✅ Save session so app remembers login for 1 hour
    await SessionManager.save({
      'role':  role ?? '',
      'id':    data['id'],
      'email': data['email'] ?? '',
      'name':  data['name']  ?? '',
      'dept':  data['dept']  ?? '',
      // FA needs full user map
      ...Map<String, dynamic>.from(data),
    });

    if (role == 'STUDENT') {
      _go(StudentDashboard(email: data['email'], studentId: data['id']));
    } else if (role == 'ADMIN') {
      _go(const AdminDashboard());
    } else if (role == 'FA') {
      _go(FADashboard(user: data));
    } else {
      _msg('Unknown role');
    }
  }

  void _go(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ── Input decoration ─────────────────────────────────────
  InputDecoration _inputDec(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText:    label,
      labelStyle:   const TextStyle(
        fontSize:      10,
        fontWeight:    FontWeight.w500,
        color:         _muted,
        letterSpacing: 0.8,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled:     true,
      fillColor:  _white,
      prefixIcon: Icon(icon, size: 18, color: _muted),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: _navy, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Logo ─────────────────────────────────────
              const SizedBox(height: 30), // 🔥 push everything down

              Center(
                child: Image.asset(
                  'assets/design.png',
                  height: 180, // 🔥 bigger logo
                ),
              ),

              const SizedBox(height: 16), // 🔥 space between logo & text

              const Center(
                child: Text(
                  'Sign in to your account',
                  style: TextStyle(
                    fontSize: 14,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 32), // 🔥 more breathing space
              // ── Email field ───────────────────────────────
              const Text(
                'EMAIL ADDRESS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _muted, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller:  _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style:        const TextStyle(fontSize: 14, color: _navy),
                decoration:   _inputDec('Email', Icons.mail_outline_rounded),
              ),
              const SizedBox(height: 16),

              // ── Password field ────────────────────────────
              const Text(
                'PASSWORD',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: _muted, letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              TextField(
                controller:  _passCtrl,
                obscureText: !_showPass,
                style:       const TextStyle(fontSize: 14, color: _navy),
                decoration:  _inputDec(
                  'Password',
                  Icons.lock_outline_rounded,
                  suffix: IconButton(
                    icon: Icon(
                      _showPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: _hint,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                ),
              ),

              // ── Row links ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                    ),
                    child: const Text(
                      'Change password',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _blue),
                    ),
                  ),
                  TextButton(
                    onPressed: _showForgotDialog,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Sign in button ────────────────────────────
              SizedBox(
                width:  double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: _white,
                    disabledBackgroundColor: _navy.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Sign in', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),

              // ── OR divider ────────────────────────────────
              const Row(
                children: [
                  Expanded(child: Divider(color: _border)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or continue with', style: TextStyle(fontSize: 12, color: _hint)),
                  ),
                  Expanded(child: Divider(color: _border)),
                ],
              ),
              const SizedBox(height: 18),

              // ── Google button ─────────────────────────────
              GestureDetector(
                onTap: _isLoading ? null : _loginWithGoogle,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color:        _white,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: _border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/google.png', height: 20),
                      const SizedBox(width: 10),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1E)),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ────────────────────────────────────
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  "By signing in you agree to the institution's terms of use",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: _hint),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Forgot password dialog ────────────────────────────────
  void _showForgotDialog() {
    final emailCtrl = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Forgot password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _navy)),
                const SizedBox(height: 6),
                const Text('Enter your email to receive a reset link.', style: TextStyle(fontSize: 13, color: _muted)),
                const SizedBox(height: 18),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText:  'Email address',
                    hintStyle: const TextStyle(color: _hint),
                    filled:    true,
                    fillColor: const Color(0xFFF5F7FA),
                    border:    OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:   BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:  _muted,
                          side:             const BorderSide(color: _border),
                          shape:            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navy,
                          foregroundColor: Colors.white,
                          elevation:       0,
                          shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final e = emailCtrl.text.trim();
                          if (e.isEmpty) { _msg('Enter email'); return; }
                          try {
                            final res = await http.post(
                              Uri.parse('$BASE_URL/auth/forgot-password'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({'email': e}),
                            );
                            if (res.statusCode == 200) {
                              Navigator.pop(context);
                              _msg('Reset link sent');
                            } else {
                              _msg(res.body);
                            }
                          } catch (_) {
                            _msg('Server error');
                          }
                        },
                        child: const Text('Send'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: child,
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════
// CHANGE PASSWORD PAGE
// ════════════════════════════════════════════════════════════
class ChangePasswordPage extends StatefulWidget {
  final String? prefilledEmail;
  const ChangePasswordPage({super.key, this.prefilledEmail});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const _bg    = Color(0xFFF5F7FA);
  static const _navy  = Color(0xFF03305A);
  static const _white = Colors.white;
  static const _border= Color(0xFFD8E3ED);
  static const _muted = Color(0xFF6B7C93);
  static const _hint  = Color(0xFFAAB8C5);
  static const _green = Color(0xFF1D9E75);
  static const _red   = Color(0xFFE24B4A);

  final _emailCtrl   = TextEditingController();
  final _oldCtrl     = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showOld     = false;
  bool _showNew     = false;
  bool _showConfirm = false;

  bool _hasLen      = false;
  bool _hasUpper    = false;
  bool _hasLower    = false;
  bool _hasNum      = false;
  bool _hasSpecial  = false;
  bool _matches     = false;
  bool _touched     = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) _emailCtrl.text = widget.prefilledEmail!;
    _newCtrl.addListener(_validate);
    _confirmCtrl.addListener(_checkMatch);
  }

  void _validate() {
    final v = _newCtrl.text;
    setState(() {
      _touched   = v.isNotEmpty;
      _hasLen    = v.length >= 8;
      _hasUpper  = RegExp(r'[A-Z]').hasMatch(v);
      _hasLower  = RegExp(r'[a-z]').hasMatch(v);
      _hasNum    = RegExp(r'[0-9]').hasMatch(v);
      _hasSpecial= RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,.<>?/`~|\\]').hasMatch(v);
    });
    _checkMatch();
  }

  void _checkMatch() => setState(() =>
  _matches = _newCtrl.text == _confirmCtrl.text && _confirmCtrl.text.isNotEmpty);

  bool get _allValid => _hasLen && _hasUpper && _hasLower && _hasNum && _hasSpecial && _matches;

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  Future<void> _submit() async {
    if (_emailCtrl.text.trim().isEmpty) { _msg('Enter your email'); return; }
    if (_oldCtrl.text.trim().isEmpty)   { _msg('Enter your old password'); return; }
    if (!_allValid)                      { _msg('Please meet all password requirements'); return; }

    try {
      final res = await http.post(
        Uri.parse('$BASE_URL/auth/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email':           _emailCtrl.text.trim(),
          'oldPassword':     _oldCtrl.text,
          'newPassword':     _newCtrl.text,
          'confirmPassword': _confirmCtrl.text,
        }),
      );
      if (res.statusCode == 200) {
        _msg('Password updated successfully');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (r) => false,
        );
      } else {
        _msg('Invalid old password');
      }
    } catch (_) {
      _msg('Server error');
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _oldCtrl.dispose();
    _newCtrl.dispose();   _confirmCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint, {Widget? suffix}) => InputDecoration(
    hintText:  hint,
    hintStyle: const TextStyle(color: _hint),
    filled:    true,
    fillColor: _white,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:   const BorderSide(color: _border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:   const BorderSide(color: _navy, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: _navy),
        centerTitle: true,
        title: const Text('Change password',
            style: TextStyle(color: _navy, fontWeight: FontWeight.w500, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _emailCtrl, decoration: _dec('Email address')),
            const SizedBox(height: 14),
            TextField(
              controller: _oldCtrl, obscureText: !_showOld,
              decoration: _dec('Old password', suffix: _eyeBtn(_showOld, () => setState(() => _showOld = !_showOld))),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _newCtrl, obscureText: !_showNew,
              decoration: _dec('New password', suffix: _eyeBtn(_showNew, () => setState(() => _showNew = !_showNew))),
            ),

            if (_touched) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Password must contain:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _muted)),
                    const SizedBox(height: 8),
                    _rule('At least 8 characters',             _hasLen),
                    _rule('At least 1 uppercase letter (A–Z)', _hasUpper),
                    _rule('At least 1 lowercase letter (a–z)', _hasLower),
                    _rule('At least 1 number (0–9)',            _hasNum),
                    _rule('At least 1 special character',       _hasSpecial),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            TextField(
              controller: _confirmCtrl, obscureText: !_showConfirm,
              decoration: _dec('Confirm password', suffix: _eyeBtn(_showConfirm, () => setState(() => _showConfirm = !_showConfirm))),
            ),

            if (_confirmCtrl.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  children: [
                    Icon(_matches ? Icons.check_circle : Icons.cancel, size: 14, color: _matches ? _green : _red),
                    const SizedBox(width: 6),
                    Text(
                      _matches ? 'Passwords match' : 'Passwords do not match',
                      style: TextStyle(fontSize: 12, color: _matches ? _green : _red),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _allValid ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: _white,
                  disabledBackgroundColor: _border,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Update password',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eyeBtn(bool visible, VoidCallback onTap) => IconButton(
    icon: Icon(visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 18, color: _hint),
    onPressed: onTap,
  );

  Widget _rule(String text, bool ok) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 15, color: ok ? _green : _hint),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(fontSize: 13, color: ok ? _green : _muted,
                fontWeight: ok ? FontWeight.w500 : FontWeight.normal)),
      ],
    ),
  );
}
