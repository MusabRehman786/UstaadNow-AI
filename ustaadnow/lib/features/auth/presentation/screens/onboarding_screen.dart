import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_ui_helpers.dart';
import '../../data/auth_provider.dart';

final _onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

class OnboardingState {
  final String name;
  final String phone;
  final String password;
  final String address;
  final UserRole selectedRole;
  final bool isLoading;
  final int step; // 0 = Login, 1 = Signup

  const OnboardingState({
    this.name = '',
    this.phone = '',
    this.password = '',
    this.address = '',
    this.selectedRole = UserRole.customer,
    this.isLoading = false,
    this.step = 0, // Default to Login
  });

  OnboardingState copyWith({
    String? name,
    String? phone,
    String? password,
    String? address,
    UserRole? selectedRole,
    bool? isLoading,
    int? step,
  }) =>
      OnboardingState(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        password: password ?? this.password,
        address: address ?? this.address,
        selectedRole: selectedRole ?? this.selectedRole,
        isLoading: isLoading ?? this.isLoading,
        step: step ?? this.step,
      );
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void updateName(String v) => state = state.copyWith(name: v);
  void updatePhone(String v) => state = state.copyWith(phone: v.trim());
  void updatePassword(String v) => state = state.copyWith(password: v);
  void updateAddress(String v) => state = state.copyWith(address: v);
  void selectRole(UserRole role) => state = state.copyWith(selectedRole: role);
  void setStep(int step) => state = state.copyWith(step: step);
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtr = TextEditingController();
  final _phoneCtr = TextEditingController();
  final _passCtr = TextEditingController();
  final _addressCtr = TextEditingController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    
    // Set up listeners for 100% robust Riverpod input stream synchronization
    _nameCtr.addListener(() {
      ref.read(_onboardingProvider.notifier).updateName(_nameCtr.text);
    });
    _phoneCtr.addListener(() {
      ref.read(_onboardingProvider.notifier).updatePhone(_phoneCtr.text);
    });
    _passCtr.addListener(() {
      ref.read(_onboardingProvider.notifier).updatePassword(_passCtr.text);
    });
    _addressCtr.addListener(() {
      ref.read(_onboardingProvider.notifier).updateAddress(_addressCtr.text);
    });

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
    _slideCtrl.forward();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _phoneCtr.dispose();
    _passCtr.dispose();
    _addressCtr.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    final formState = ref.read(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    notifier.state = formState.copyWith(isLoading: true);
    try {
      final success = await ref.read(authProvider.notifier).signUpUser(
        name: formState.name,
        phone: formState.phone,
        password: formState.password,
        address: formState.address,
        role: formState.selectedRole,
      );

      notifier.state = formState.copyWith(
        isLoading: false,
        step: 0, // Successfully registered -> Move back to Login Screen!
      );

      // Clear the signup fields so they don't conflict with Login
      _nameCtr.clear();
      _passCtr.clear();
      _addressCtr.clear();

      if (mounted && success) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Account Created! 🎉', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            content: const Text('Your account has been successfully created. You can now login with your phone number and password.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      notifier.state = formState.copyWith(isLoading: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Signup error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final formState = ref.read(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);

    notifier.state = formState.copyWith(isLoading: true);
    try {
      final success = await ref.read(authProvider.notifier).loginUser(
        phone: formState.phone,
        password: formState.password,
      );
      
      notifier.state = formState.copyWith(isLoading: false);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.error,
              content: Text('Invalid phone number or password. Please try again.'),
            ),
          );
        }
      }
      // If success is true, the RouterNotifier inside app_router.dart automatically catches the auth change and instantly redirects to the Home dashboard!
    } catch (e) {
      notifier.state = formState.copyWith(isLoading: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Login error: ${e.toString()}'),
          ),
        );
      }
    }
  }

  String? _validatePhone(String? v) {
    if (v == null || v.isEmpty) return 'Phone is required';
    if (!v.startsWith('+92')) return 'Phone must start with +92';
    if (v.length != 13) return 'Phone must be exactly 13 characters (+92xxxxxxxxxx)';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_onboardingProvider);
    final notifier = ref.read(_onboardingProvider.notifier);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            height: size.height * 0.38,
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          ),
          // Decorative circles
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 40, right: 40,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        children: [
                          Container(
                            width: 54, height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: const Center(
                              child: Text('U', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary)),
                            ),
                          ),
                          const VGap(12),
                          const Text(
                            AppStrings.appName,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                          ),
                          const VGap(4),
                          Text(
                            AppStrings.appSubtagline,
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85), fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const VGap(24),
                    // Form card
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAF9),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.step == 0) ...[
                                  // LOGIN SCREEN
                                  Text('Welcome Back', style: Theme.of(context).textTheme.headlineSmall),
                                  const VGap(4),
                                  Text('Login to your UstaadNow profile', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                                  const VGap(24),

                                  AppTextField(
                                    label: 'Phone Number',
                                    hint: '+923000000000',
                                    controller: _phoneCtr,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                    textInputAction: TextInputAction.next,
                                    validator: _validatePhone,
                                  ),
                                  const VGap(16),
                                  AppTextField(
                                    label: 'Password',
                                    hint: 'Enter your password',
                                    controller: _passCtr,
                                    obscureText: true,
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                    textInputAction: TextInputAction.done,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                                  ),
                                  const VGap(28),
                                  AppGradientButton(
                                    label: 'Login',
                                    isLoading: state.isLoading,
                                    onPressed: _submitLogin,
                                    icon: Icons.login_rounded,
                                  ),
                                  const VGap(20),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        notifier.setStep(1); // Go to Signup screen
                                        _nameCtr.clear();
                                        _passCtr.clear();
                                        _addressCtr.clear();
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          children: const [
                                            TextSpan(text: "Don't have an account? "),
                                            TextSpan(text: "Sign Up", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else if (state.step == 1) ...[
                                  // SIGNUP SCREEN
                                  Text('Create Account', style: Theme.of(context).textTheme.headlineSmall),
                                  const VGap(4),
                                  Text('Join UstaadNow AI service booking platform', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                                  const VGap(20),

                                  AppTextField(
                                    label: 'Full Name',
                                    hint: 'e.g. Ahmed Khan',
                                    controller: _nameCtr,
                                    prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                                    textInputAction: TextInputAction.next,
                                    validator: (v) => (v?.isEmpty ?? true) ? 'Name is required' : null,
                                  ),
                                  const VGap(16),
                                  AppTextField(
                                    label: 'Phone Number',
                                    hint: '+923000000000',
                                    controller: _phoneCtr,
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                    textInputAction: TextInputAction.next,
                                    validator: _validatePhone,
                                  ),
                                  const VGap(16),
                                  AppTextField(
                                    label: 'Password',
                                    hint: 'Minimum 6 characters',
                                    controller: _passCtr,
                                    obscureText: true,
                                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                    textInputAction: TextInputAction.next,
                                    validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                                  ),
                                  const VGap(16),
                                  AppTextField(
                                    label: 'Address / Location',
                                    hint: 'e.g. G-13, Islamabad',
                                    controller: _addressCtr,
                                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                                    textInputAction: TextInputAction.done,
                                    validator: (v) => (v?.isEmpty ?? true) ? 'Address is required' : null,
                                  ),
                                  const VGap(24),

                                  // Removed Role Selection UI as per request
                                  AppGradientButton(
                                    label: 'Sign Up',
                                    isLoading: state.isLoading,
                                    onPressed: _submitSignup,
                                    icon: Icons.arrow_forward_rounded,
                                  ),
                                  const VGap(16),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        notifier.setStep(0); // Go to Login screen
                                        _passCtr.clear();
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          children: const [
                                            TextSpan(text: "Already have an account? "),
                                            TextSpan(text: "Login", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : null,
              )),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
