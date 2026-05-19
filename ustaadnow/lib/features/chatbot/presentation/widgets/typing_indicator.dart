import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Animated "AI is working" indicator that cycles through the real backend
/// agent pipeline steps so the user knows exactly what's happening.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  // ── Agent steps that mirror the backend pipeline ──────────────────────────
  static const _steps = [
    _AgentStep(
      icon: Icons.psychology_rounded,
      label: 'Understanding request…',
      sublabel: 'intent agent',
    ),
    _AgentStep(
      icon: Icons.travel_explore_rounded,
      label: 'Searching nearby providers…',
      sublabel: 'discovery agent',
    ),
    _AgentStep(
      icon: Icons.auto_awesome_rounded,
      label: 'Ranking best match…',
      sublabel: 'matching agent',
    ),
    _AgentStep(
      icon: Icons.checklist_rounded,
      label: 'Preparing your options…',
      sublabel: 'booking agent',
    ),
  ];

  int _stepIndex = 0;
  late Timer _stepTimer;

  // Dot bounce controllers
  final List<AnimationController> _dotControllers = [];
  final List<Animation<double>> _dotAnims = [];

  // Step fade controller
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Shimmer / progress bar controller
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    // Bouncing dots
    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 550),
      );
      final anim = Tween<double>(begin: 0, end: -7).animate(
        CurvedAnimation(
          parent: ctrl,
          curve: const Interval(0, 0.5, curve: Curves.easeOut),
        ),
      );
      _dotControllers.add(ctrl);
      _dotAnims.add(anim);
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
    }

    // Step fade
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();

    // Shimmer bar
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    // Cycle through steps with dynamic durations
    _startStepTimer();
  }

  void _startStepTimer() {
    final durations = [
      const Duration(milliseconds: 5000), // Step 0: 5 seconds (allows quick follow-ups to finish without showing other steps)
      const Duration(milliseconds: 2200), // Step 1: 2.2 seconds
      const Duration(milliseconds: 2200), // Step 2: 2.2 seconds
      const Duration(milliseconds: 2200), // Step 3: 2.2 seconds
    ];
    
    _stepTimer = Timer(durations[_stepIndex], () {
      if (!mounted) return;
      _fadeCtrl.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _stepIndex = (_stepIndex + 1) % _steps.length;
        });
        _fadeCtrl.forward();
        _startStepTimer();
      });
    });
  }

  @override
  void dispose() {
    _stepTimer.cancel();
    for (final c in _dotControllers) {
      c.dispose();
    }
    _fadeCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _steps[_stepIndex];

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI avatar
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8, bottom: 2),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: Colors.white, size: 16),
          ),

          // Bubble
          Container(
            constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.aiBubbleDark : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step row with fade
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated icon
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(step.icon,
                            size: 14, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              step.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              step.sublabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Shimmer progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 3,
                    child: AnimatedBuilder(
                      animation: _shimmerAnim,
                      builder: (_, __) {
                        return CustomPaint(
                          painter: _ShimmerBarPainter(
                            progress: _shimmerAnim.value,
                            isDark: isDark,
                          ),
                          child: const SizedBox.expand(),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Bouncing dots row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Processing',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    ...List.generate(3, (i) => AnimatedBuilder(
                          animation: _dotAnims[i],
                          builder: (_, __) => Transform.translate(
                            offset: Offset(0, _dotAnims[i].value),
                            child: Container(
                              width: 5,
                              height: 5,
                              margin: EdgeInsets.only(right: i < 2 ? 3 : 0),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.6 + i * 0.13),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────

class _AgentStep {
  final IconData icon;
  final String label;
  final String sublabel;

  const _AgentStep({
    required this.icon,
    required this.label,
    required this.sublabel,
  });
}

// ── Shimmer bar painter ───────────────────────────────────────────────────

class _ShimmerBarPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _ShimmerBarPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Background track
    final trackPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), trackPaint);

    // Shimmer highlight
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0),
          AppColors.primaryLight.withValues(alpha: 0.9),
          AppColors.primary.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(
        progress * size.width - size.width * 0.4,
        0,
        size.width * 0.8,
        size.height,
      ));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      shimmerPaint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerBarPainter old) => old.progress != progress;
}
