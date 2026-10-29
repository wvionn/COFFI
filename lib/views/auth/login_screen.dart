import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_main_screen.dart';
import '../customer/customer_order_mode_screen.dart';
import '../dapur/dapur_kds_screen.dart';
import '../kasir/kasir_main_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _showDemoAccounts = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi.'),
          backgroundColor: AppColors.berryRed,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithEmail(email, password);
    if (!mounted) return;

    if (success) {
      _navigateForRole(authProvider.currentProfile!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'Login gagal! Periksa email dan password.',
          ),
          backgroundColor: AppColors.berryRed,
        ),
      );
    }
  }

  void _navigateForRole(ProfileModel profile) {
    Widget destination;
    if (profile.isAdmin) {
      destination = const AdminMainScreen();
    } else if (profile.isDapur) {
      destination = const DapurKdsScreen();
    } else if (profile.isUser) {
      destination = const CustomerOrderModeScreen();
    } else {
      destination = const KasirMainScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.figmaCreamBg,
      body: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation: Back Button & Quick Demo Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Material(
                      color: AppColors.figmaSoftCream,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _handleBack,
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.figmaCoffee,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showDemoAccounts = !_showDemoAccounts;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        backgroundColor: AppColors.figmaSoftCream,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        _showDemoAccounts
                            ? Icons.expand_less_rounded
                            : Icons.touch_app_rounded,
                        size: 16,
                        color: AppColors.figmaCoffee,
                      ),
                      label: Text(
                        'Demo Akun',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.figmaCoffee,
                        ),
                      ),
                    ),
                  ],
                ),

                // Collapsible Demo Account Bar
                if (_showDemoAccounts) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEADBCE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PILIH AKUN ROLE DEMO (OTOMATIS LOGIN):',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.figmaHazelnut,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildQuickRoleChip('👑 Admin', 'admin@coffi.com'),
                            _buildQuickRoleChip('💼 Kasir', 'kasir@coffi.com'),
                            _buildQuickRoleChip('🍳 Dapur', 'dapur@coffi.com'),
                            _buildQuickRoleChip('👤 Pelanggan', 'user@coffi.com'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Heading
                Text(
                  'Selamat Datang!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: AppColors.figmaCoffee,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Silakan masuk untuk melanjutkan pesanan Anda.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 32),

                // Form Fields
                AuthTextField(
                  label: 'Email / No. Handphone',
                  hintText: 'example@mail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: 18),

                AuthTextField(
                  label: 'Password',
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onTogglePassword: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => auth.isLoading ? null : _submitLogin(),
                ),

                const SizedBox(height: 26),

                // MASUK Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.figmaCoffee,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: auth.isLoading ? null : _submitLogin,
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'MASUK',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),

                // Divider: Atau masuk dengan
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: Color(0xFFEADBCE), thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Atau masuk dengan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFB19A8A),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: Color(0xFFEADBCE), thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Social Auth Buttons: Google & OTP
                SocialAuthRow(
                  onGoogleTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login via Google belum diaktifkan.'),
                        backgroundColor: AppColors.roastedCoffee,
                      ),
                    );
                  },
                  onOtpTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login via OTP WhatsApp belum diaktifkan.'),
                        backgroundColor: AppColors.roastedCoffee,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // Bottom Register Redirect Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Belum punya akun? ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                        children: [
                          TextSpan(
                            text: 'Daftar Sekarang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.figmaCoffee,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickRoleChip(String label, String email) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        _emailController.text = email;
        _passwordController.text = '123456';
        _submitLogin();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.figmaSoftCream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEADBCE)),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.figmaCoffee,
          ),
        ),
      ),
    );
  }
}
