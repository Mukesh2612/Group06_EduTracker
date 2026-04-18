import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/session.dart';
import 'admin/admin_dashboard.dart';
import 'student/student_dashboard.dart';
import 'Fa/fa_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loaderCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _loaderWidth;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // LOGO ANIMATION
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _logoScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // TEXT ANIMATION
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    // LOADER
    _loaderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _loaderWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loaderCtrl, curve: Curves.easeInOut),
    );

    // ANIMATION SEQUENCE
    _logoCtrl.forward();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _loaderCtrl.forward();
    });

    // NAVIGATION — check session first
    Future.delayed(const Duration(milliseconds: 2700), () async {
      if (!mounted) return;

      final session = await SessionManager.load();

      Widget destination;
      if (session != null) {
        final role = session['role'] as String? ?? '';
        if (role == 'STUDENT') {
          destination = StudentDashboard(
            email:     session['email'] ?? '',
            studentId: session['id'] ?? 0,
          );
        } else if (role == 'FA') {
          destination = FADashboard(user: session);
        } else if (role == 'ADMIN') {
          destination = const AdminDashboard();
        } else {
          destination = const LoginPage();
        }
      } else {
        destination = const LoginPage();
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => destination,
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _loaderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E9EB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEDF3FC), Color(0xFFE8E9EB), Color(0xFFDDE0E4)],
          ),
        ),
        child: SafeArea(
          child: Center( // ✅ PERFECT CENTERING
            child: Column(
              mainAxisSize: MainAxisSize.min, // ✅ NO EXTRA SPACE
              children: [

                // LOGO
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 300,
                      height: 250,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // TEXT
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Edu',
                                style: GoogleFonts.sora(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1a3d7a),
                                ),
                              ),
                              TextSpan(
                                text: 'Tracker',
                                style: GoogleFonts.sora(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1a3d7a),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Student Activity Points Tracking',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF746D69),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // LOADER
                AnimatedBuilder(
                  animation: _loaderWidth,
                  builder: (_, __) => Opacity(
                    opacity: _loaderCtrl.value > 0 ? 1.0 : 0.0,
                    child: Container(
                      width: 130,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCDC6),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _loaderWidth.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1a4fa0),
                                Color(0xFF2e7de8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(99),
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