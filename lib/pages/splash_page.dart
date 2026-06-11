

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();

    
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _logoFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    // Logo slides up from 30 px below its final position.
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    ));

    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 0.72, curve: Curves.easeOut),
    );

    _btnFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.58, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
    _resolveAuthState();
  }

  Future<void> _resolveAuthState() async {
    final user = await FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    if (user != null) {
      // Authenticated — let animation finish, then go home.
      await Future.delayed(const Duration(milliseconds: 1600));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
    // Not authenticated → CTA button visible; user taps to navigate.
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onStart() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl, // Arabic-first RTL layout
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Gradient background ─────────────────────────────────────
            const _GradientBackground(),

            Positioned(
  left: 0,
  right: 0,
  bottom: 0,
  child: Opacity(
    opacity: 0.10,
    child: Image.asset(
      'assets/images/city.png',
      width: double.infinity,
      fit: BoxFit.fitWidth,
      alignment: Alignment.bottomCenter,
    ),
  ),
),

            // ── 3. Main content ────────────────────────────────────────────

    SafeArea(
  child: Center(
    child: Column(
      children: [
        const Spacer(),

        // Logo
        FadeTransition(
          opacity: _logoFade,
          child: SlideTransition(
            position: _logoSlide,
            child: Hero(
              tag: 'app_logo',
              flightShuttleBuilder: _heroShuttleBuilder,
              child: Image.asset(
                'assets/images/Symbol.png',
                width: 190,
                height: 190,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        FadeTransition(
          opacity: _textFade,
          child: const _BrandText(),
        ),

        const Spacer(),

        FadeTransition(
          opacity: _btnFade,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 65),
            child: _GoldButton(
              label: 'ابدأ الآن',
              onTap: _onStart,
            ),
          ),
        ),
      ],
    ),
  ),
),
          ],
        ),
      ),
    );

  }
}

// ─── Hero flight shuttle ───────────────────────────────────────────────────
// A custom shuttle that keeps the image fully visible and applies a subtle
// scale spring during the flight, giving a premium feel.
Widget _heroShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection direction,
  BuildContext fromContext,
  BuildContext toContext,
) {
  final hero = direction == HeroFlightDirection.push
      ? toContext.widget as Hero
      : fromContext.widget as Hero;

  return ScaleTransition(
    scale: animation.drive(
      Tween<double>(begin: 0.85, end: 1.0).chain(
        CurveTween(curve: Curves.easeOutCubic),
      ),
    ),
    child: FadeTransition(
      opacity: animation.drive(
        Tween<double>(begin: 0.6, end: 1.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
      ),
      child: hero.child,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient background
// ─────────────────────────────────────────────────────────────────────────────
class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF13808F), // lighter Bleu Canard
            Color(0xFF0A5560), // deep teal
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand text — Arabic + DHALLA subtitle with gold dashes
// ─────────────────────────────────────────────────────────────────────────────
class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'الضــالـّة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontFamilyFallback: ['Noto Kufi Arabic', 'Noto Sans Arabic'],
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _goldDash(),
            const SizedBox(width: 10),
            const Text(
              'DHALLA',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFFD4B06A),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(width: 10),
            _goldDash(),
          ],
        ),
      ],
    );
  }

  Widget _goldDash() => Container(
        width: 35,
        height: 2,
        decoration: BoxDecoration(
          color: const Color(0xFFD4B06A),
          borderRadius: BorderRadius.circular(2),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Gold CTA button
// ─────────────────────────────────────────────────────────────────────────────
class _GoldButton extends StatelessWidget {
  const _GoldButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4B06A).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFD4B06A),
          foregroundColor: Color(0xFF0A5560),
          minimumSize: const Size(260, 58),
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

