import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/user_model.dart';
import '../../data/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // ── Video ──────────────────────────────────────────────────────────────────
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  bool _isVideoStuck = false;
  bool _hasNavigated = false;
  Timer? _safetyTimer;
  int _retryCount = 0;

  // ── Fallback animation controllers ────────────────────────────────────────
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _setFullscreen(true);
    _initFallbackAnimations();
    _initializeVideo();
    // Hard cap: navigate no matter what after 12s
    _safetyTimer = Timer(const Duration(seconds: 12), () {
      debugPrint('Splash hard-cap timer fired');
      _navigateToNext(force: true);
    });
  }

  // ── Fallback animation setup ───────────────────────────────────────────────

  void _initFallbackAnimations() {
    // Logo scale + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    // Text fade + slide up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Shimmer bar
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start sequence
    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _textController.forward();
      });
    });
  }

  // ── Video initialization ───────────────────────────────────────────────────

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(
          'assets/animations/splash_screen.mp4');
      await _controller!.initialize();
      if (!mounted) return;

      setState(() => _isVideoInitialized = true);
      _controller!.addListener(_videoListener);
      _controller!.play();

      // Once initialized, reset safety timer to duration + 3s
      final durMs = _controller!.value.duration.inMilliseconds;
      final safetyMs = (durMs > 0 ? durMs : 6000) + 3000;
      _safetyTimer?.cancel();
      _safetyTimer = Timer(Duration(milliseconds: safetyMs), () {
        debugPrint('Splash duration-based timer fired (${safetyMs}ms)');
        _navigateToNext(force: true);
      });

      // Stuck detection: 2.5s after init — check position AND isPlaying AND hasError
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!mounted || _hasNavigated || _isVideoStuck) return;
        final val = _controller?.value;
        if (val == null || val.hasError || (val.position == Duration.zero && !val.isPlaying)) {
          debugPrint(
              'Video stuck/error after 2.5s (hasError=${val?.hasError}). Using branding fallback.');
          _controller?.removeListener(_videoListener);
          setState(() => _isVideoStuck = true);
          try { _controller?.pause(); } catch (_) {}
          Future.delayed(const Duration(milliseconds: 2800), () {
            _navigateToNext(force: true);
          });
        }
      });
    } catch (e) {
      debugPrint('Video init exception: $e — using branding fallback.');
      if (mounted) setState(() => _isVideoStuck = true);
      Future.delayed(const Duration(milliseconds: 2800), () {
        _navigateToNext(force: true);
      });
    }
  }

  void _videoListener() {
    if (!mounted || _isVideoStuck) return;

    // Immediately fall back if the hardware decoder reported an error
    if (_controller?.value.hasError == true) {
      debugPrint(
          'Video player error detected: ${_controller?.value.errorDescription}');
      _controller?.removeListener(_videoListener);
      setState(() => _isVideoStuck = true);
      try { _controller?.pause(); } catch (_) {}
      Future.delayed(const Duration(milliseconds: 2800), () {
        _navigateToNext(force: true);
      });
      return;
    }

    final pos = _controller?.value.position;
    final dur = _controller?.value.duration;
    if (dur != null && dur != Duration.zero && pos != null && pos >= dur) {
      _navigateToNext();
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _setFullscreen(bool on) {
    if (on) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
  }

  void _navigateToNext({bool force = false}) {
    if (_hasNavigated) return;

    final auth = ref.read(authProvider);
    if (auth.isLoading && !force && _retryCount < 20) {
      _retryCount++;
      Future.delayed(
          const Duration(milliseconds: 100), () => _navigateToNext(force: force));
      return;
    }

    _hasNavigated = true;
    _safetyTimer?.cancel();
    _setFullscreen(false);
    if (!mounted) return;

    if (auth.isAuthenticated) {
      if (auth.user?.role == UserRole.provider) {
        context.go(AppRoutes.providerHome);
      } else {
        context.go(AppRoutes.userHome);
      }
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _setFullscreen(false);
    _logoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    try {
      _controller?.removeListener(_videoListener);
      _controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final showVideo = _isVideoInitialized && !_isVideoStuck;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background — always visible (video sits on top)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1A1040),
                  Color(0xFF0D1B2A),
                ],
              ),
            ),
          ),

          // ── Video (when hardware supports it) ──
          if (showVideo)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: (_controller?.value.size.width ?? 0) > 0
                      ? _controller!.value.size.width
                      : 1080,
                  height: (_controller?.value.size.height ?? 0) > 0
                      ? _controller!.value.size.height
                      : 1920,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),

          // ── Premium animated branding fallback ──
          if (!showVideo) _buildBrandingFallback(),
        ],
      ),
    );
  }

  Widget _buildBrandingFallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 3),

        // Animated logo
        ScaleTransition(
          scale: _logoScale,
          child: FadeTransition(
            opacity: _logoFade,
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 32,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Animated app name + tagline
        SlideTransition(
          position: _textSlide,
          child: FadeTransition(
            opacity: _textFade,
            child: Column(
              children: [
                const Text(
                  'UstaadNow AI',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AI-Powered Service Booking',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(flex: 2),

        // Shimmer progress bar
        FadeTransition(
          opacity: _textFade,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 3,
                    child: AnimatedBuilder(
                      animation: _shimmerAnim,
                      builder: (_, __) => CustomPaint(
                        painter: _SplashShimmerPainter(_shimmerAnim.value),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Initializing AI agents...',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 48),
      ],
    );
  }
}

// ── Shimmer bar painter ────────────────────────────────────────────────────

class _SplashShimmerPainter extends CustomPainter {
  final double progress;
  const _SplashShimmerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Track
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withValues(alpha: 0.12),
    );

    // Shimmer
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.0),
          AppColors.primaryLight.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.6),
          AppColors.primaryLight.withValues(alpha: 0.9),
          AppColors.primary.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(
        progress * size.width - size.width * 0.6,
        0,
        size.width * 1.2,
        size.height,
      ));

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_SplashShimmerPainter old) => old.progress != progress;
}
