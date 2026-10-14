import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_main_screen.dart';
import '../dapur/dapur_kds_screen.dart';
import '../kasir/kasir_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPinMode = true; // DIRECTLY TO PIN STAFF AS REQUESTED
  bool _isPasswordVisible = false;
  String _enteredPin = '';

  final _emailController = TextEditingController(text: 'admin@cafeku.com');
  final _passwordController = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPinDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onPinBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _submitPin() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithPin(_enteredPin);
    if (!mounted) return;

    if (success) {
      _navigateForRole(authProvider.currentProfile!);
    } else {
      setState(() {
        _enteredPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'PIN salah! Silakan coba lagi.'),
          backgroundColor: AppColors.berryRed,
        ),
      );
    }
  }

  Future<void> _submitEmail() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;

    if (success) {
      _navigateForRole(authProvider.currentProfile!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login gagal! Periksa email dan sandi.'),
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
    } else {
      destination = const KasirMainScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.darkCoffeeHeader, // Rich dark coffee brown matching Image 1
      body: Column(
        children: [
          // Top Header Section (Matching Image 1)
          Container(
            width: double.infinity,
            height: size.height * 0.25,
            color: AppColors.darkCoffeeHeader,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.coffee_rounded,
                          color: AppColors.activePillCream,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Selamat Datang di Coffi',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cafeku POS & Kitchen System',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.creamLatte.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Curved White Card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isPinMode) ...[
                        // PIN Mode Title & Instruction
                        Center(
                          child: Text(
                            'Masukkan 4 Digit PIN Staf',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.espressoDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            'Pilih digit untuk masuk cepat ke sistem',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // PIN Indicator Dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final filled = index < _enteredPin.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: filled ? AppColors.roastedCoffee : Colors.transparent,
                                border: Border.all(
                                  color: filled ? AppColors.roastedCoffee : AppColors.borderSubtle,
                                  width: 2.2,
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 20),

                        // PIN Numpad Grid
                        Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 290),
                            child: Column(
                              children: [
                                for (var row in [
                                  ['1', '2', '3'],
                                  ['4', '5', '6'],
                                  ['7', '8', '9'],
                                  ['', '0', 'back'],
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: row.map((key) {
                                        if (key.isEmpty) {
                                          return const SizedBox(width: 72, height: 56);
                                        }
                                        if (key == 'back') {
                                          return SizedBox(
                                            width: 72,
                                            height: 56,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(16),
                                              onTap: _onPinBackspace,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.backspace_outlined,
                                                  color: AppColors.espressoDark,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return SizedBox(
                                          width: 72,
                                          height: 56,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFFAFAFA),
                                              foregroundColor: AppColors.espressoDark,
                                              elevation: 0,
                                              side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            onPressed: () => _onPinDigitPressed(key),
                                            child: Text(
                                              key,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // Email Mode
                        Text(
                          'Email',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.textMuted, size: 20),
                            hintText: 'nama@email.com',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textMuted),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.roastedCoffee, width: 1.5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Password',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            hintText: 'Masukan Password',
                            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textMuted),
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.roastedCoffee, width: 1.5),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Hubungi Administrator untuk reset kata sandi.'),
                                  backgroundColor: AppColors.roastedCoffee,
                                ),
                              );
                            },
                            child: Text(
                              'Lupa Password?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.activePillCream,
                              foregroundColor: AppColors.espressoDark,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: auth.isLoading ? null : _submitEmail,
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.espressoDark,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    'Masuk',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.espressoDark,
                                    ),
                                  ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Toggle between PIN Staf and Email
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _isPinMode = !_isPinMode;
                              _enteredPin = '';
                            });
                          },
                          icon: Icon(
                            _isPinMode ? Icons.mail_outline_rounded : Icons.dialpad_rounded,
                            size: 16,
                            color: AppColors.roastedCoffee,
                          ),
                          label: Text(
                            _isPinMode ? 'Masuk dengan Email & Password' : '⚡ Masuk dengan PIN Staf',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.roastedCoffee,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Quick Demo Account Switcher
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.warmCaramel),
                                const SizedBox(width: 6),
                                Text(
                                  'Pilih Akun Demo (Uji Coba Langsung):',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: auth.demoStaff.map((staff) {
                                return ActionChip(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                    color: staff.isAdmin
                                        ? AppColors.espressoDark.withOpacity(0.3)
                                        : (staff.isDapur
                                            ? AppColors.amberOrange.withOpacity(0.3)
                                            : AppColors.matchaGreen.withOpacity(0.3)),
                                  ),
                                  avatar: Icon(
                                    staff.isAdmin
                                        ? Icons.admin_panel_settings
                                        : (staff.isDapur ? Icons.outdoor_grill : Icons.point_of_sale),
                                    size: 14,
                                    color: staff.isAdmin
                                        ? AppColors.espressoDark
                                        : (staff.isDapur ? AppColors.amberOrange : AppColors.matchaGreen),
                                  ),
                                  label: Text(
                                    '${staff.fullName} (PIN: ${staff.pinCode})',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () {
                                    auth.switchDemoUser(staff);
                                    _navigateForRole(staff);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
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
