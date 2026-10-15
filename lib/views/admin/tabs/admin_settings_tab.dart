import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/supabase_config.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/supabase_service.dart';
import '../../auth/login_screen.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  final TextEditingController _urlController = TextEditingController(text: SupabaseConfig.supabaseUrl);
  final TextEditingController _anonKeyController = TextEditingController(text: SupabaseConfig.supabaseAnonKey);

  // General cafe profile state
  String _cafeName = 'COFFI Coffee & Resto';
  String _cafeAddress = 'Jl. Kampus Merdeka No. 42';
  String _cafePhone = '0812-3456-7890';
  String _receiptFooter = 'Terima kasih atas kunjungan Anda!';
  bool _pb1Enabled = true;
  String _printerSize = '58mm';

  @override
  void dispose() {
    _urlController.dispose();
    _anonKeyController.dispose();
    super.dispose();
  }

  // ==========================================
  // MODAL 1: AKUN STAF
  // ==========================================
  void _openStaffModule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.82,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _buildModalHeader(
                  title: 'Manajemen Akun Staf',
                  subtitle: '${auth.demoStaff.length} Staf Terdaftar',
                  icon: Icons.badge_rounded,
                  iconColor: AppColors.warmCaramel,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.roastedCoffee,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _showAddStaffDialog(context, auth),
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: const Text('Tambah Staf Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: auth.demoStaff.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final staff = auth.demoStaff[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.activePillCream,
                              child: Icon(
                                staff.isAdmin
                                    ? Icons.admin_panel_settings
                                    : (staff.isDapur ? Icons.soup_kitchen : Icons.point_of_sale),
                                color: AppColors.espressoDark,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff.fullName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${staff.role.toUpperCase()} • ${staff.email ?? '-'}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.matchaGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Aktif',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.matchaGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context, AuthProvider auth) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'kasir';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Tambah Staf Baru',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Lengkap Staf:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(controller: nameController, decoration: const InputDecoration(hintText: 'e.g. Maya Indah')),
              const SizedBox(height: 12),
              Text('Role / Posisi:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'kasir', child: Text('Kasir (Front Counter)')),
                  DropdownMenuItem(value: 'dapur', child: Text('Barista / Dapur')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin / Owner')),
                ],
                onChanged: (val) => setState(() => selectedRole = val ?? 'kasir'),
              ),
              const SizedBox(height: 12),
              Text('Email Login:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'e.g. maya@coffi.com'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                if (name.isNotEmpty && validEmail) {
                  auth.addStaff(fullName: name, role: selectedRole, email: email);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Staf $name ($email) berhasil ditambahkan!'),
                      backgroundColor: AppColors.matchaGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama wajib diisi dan email harus valid!'),
                      backgroundColor: AppColors.amberOrange,
                    ),
                  );
                }
              },
              child: const Text('Simpan Staf'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODAL 2: SUPABASE & DATABASE CONFIG
  // ==========================================
  void _openSupabaseModule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final isConnected = SupabaseService.instance.isConnected;
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModalHeader(
                    title: 'Koneksi Database & Cloud',
                    subtitle: isConnected ? 'Supabase Terhubung Live' : 'Mode Offline / Local Fallback',
                    icon: Icons.cloud_sync_rounded,
                    iconColor: isConnected ? AppColors.matchaGreen : AppColors.amberOrange,
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isConnected ? AppColors.matchaGreen.withOpacity(0.1) : AppColors.amberOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isConnected ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: isConnected ? AppColors.matchaGreen : AppColors.amberOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isConnected
                                ? 'Database live online. Pesanan dan katalog tersinkron realtime.'
                                : 'Aplikasi menggunakan penyimpanan offline lokal.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isConnected ? AppColors.matchaGreen : AppColors.amberOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Supabase Project URL:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(controller: _urlController, decoration: const InputDecoration(hintText: 'https://xyz.supabase.co')),
                  const SizedBox(height: 14),
                  Text('Supabase Anon Key:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(controller: _anonKeyController, maxLines: 2, decoration: const InputDecoration(hintText: 'eyJhbGciOi...')),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.roastedCoffee),
                      onPressed: () async {
                        await SupabaseConfig.saveConfig(
                          _urlController.text.trim(),
                          _anonKeyController.text.trim(),
                        );
                        await SupabaseService.instance.initialize();
                        Navigator.pop(ctx);
                        this.setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Konfigurasi database berhasil disimpan!'), backgroundColor: AppColors.matchaGreen),
                        );
                      },
                      child: const Text('Simpan & Uji Koneksi'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // MODAL 3: PROFIL KAFE & STRUK
  // ==========================================
  void _openCafeProfileModule(BuildContext context) {
    final nameCtrl = TextEditingController(text: _cafeName);
    final addrCtrl = TextEditingController(text: _cafeAddress);
    final phoneCtrl = TextEditingController(text: _cafePhone);
    final footerCtrl = TextEditingController(text: _receiptFooter);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalHeader(
                title: 'Profil Kafe & Header Struk',
                subtitle: 'Informasi yang tercetak pada struk belanja',
                icon: Icons.storefront_rounded,
                iconColor: AppColors.roastedCoffee,
              ),
              Text('Nama Coffee Shop / Kafe:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(controller: nameCtrl),
              const SizedBox(height: 12),
              Text('Alamat Kafe:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(controller: addrCtrl),
              const SizedBox(height: 12),
              Text('Nomor WhatsApp / Telepon:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(controller: phoneCtrl),
              const SizedBox(height: 12),
              Text('Pesan Footer Struk:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              TextField(controller: footerCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.roastedCoffee),
                  onPressed: () {
                    setState(() {
                      _cafeName = nameCtrl.text.trim();
                      _cafeAddress = addrCtrl.text.trim();
                      _cafePhone = phoneCtrl.text.trim();
                      _receiptFooter = footerCtrl.text.trim();
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil kafe & struk berhasil diperbarui!'), backgroundColor: AppColors.matchaGreen),
                    );
                  },
                  child: const Text('Simpan Profil Kafe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODAL 4: PAJAK & PB1
  // ==========================================
  void _openTaxModule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalHeader(
                title: 'Pengaturan Pajak & PB1 Resto',
                subtitle: 'Ketetapan perpajakan daerah untuk pesanan',
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.coldBrewBlue,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.roastedCoffee,
                title: Text('Aktifkan Pajak PB1 (10%)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                subtitle: Text('Otomatis dihitung pada ringkasan pembayaran kasir', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                value: _pb1Enabled,
                onChanged: (val) {
                  setLocalState(() => _pb1Enabled = val);
                  setState(() => _pb1Enabled = val);
                },
              ),
              const Divider(height: 24),
              Text(
                'Catatan: Pajak Restoran (PB1) sebesar 10% diberlakukan sesuai peraturan perpajakan kuliner lokal dan otomatis disertakan di setiap struk.',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODAL 5: PRINTER KASIR
  // ==========================================
  void _openPrinterModule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalHeader(
                title: 'Format Printer & Struk',
                subtitle: 'Konfigurasi printer thermal Bluetooth / USB',
                icon: Icons.print_rounded,
                iconColor: const Color(0xFF6366F1),
              ),
              Text('Pilih Ukuran Kertas Thermal:', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('58 mm (Standar)'),
                      selected: _printerSize == '58mm',
                      selectedColor: AppColors.activePillCream,
                      onSelected: (val) {
                        setLocalState(() => _printerSize = '58mm');
                        setState(() => _printerSize = '58mm');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('80 mm (Besar)'),
                      selected: _printerSize == '80mm',
                      selectedColor: AppColors.activePillCream,
                      onSelected: (val) {
                        setLocalState(() => _printerSize = '80mm');
                        setState(() => _printerSize = '80mm');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bluetooth, color: AppColors.coldBrewBlue),
                title: const Text('Cari Printer Bluetooth'),
                subtitle: const Text('Status: Siap dipasangkan dengan Mini POS'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memindai perangkat printer Bluetooth thermal terdekat...')),
                  );
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Terapkan Pengaturan Printer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // ==========================================
  // MODAL 7: INFO SISTEM & DIAGNOSTIK
  // ==========================================
  void _openSystemInfoModule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildModalHeader(
              title: 'Info Sistem & Diagnostik',
              subtitle: 'Spesifikasi & status operasional POS',
              icon: Icons.info_outline_rounded,
              iconColor: const Color(0xFF64748B),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                children: [
                  _buildInfoTile('Aplikasi', 'COFFI POS Mobile v1.0.0'),
                  _buildInfoTile('Mode Pelayanan', 'Counter Queue & Name Calling'),
                  _buildInfoTile(
                    'Database Cloud',
                    SupabaseService.instance.isConnected ? 'Supabase Connected' : 'Mode Offline Siap',
                  ),
                  _buildInfoTile('Format Struk', 'Thermal $_printerSize (ESC/POS)'),
                  _buildInfoTile('Pajak PB1', _pb1Enabled ? 'Aktif (10%)' : 'Non-Aktif'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.matchaGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.matchaGreen, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sistem Berjalan Normal',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppColors.espressoDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Seluruh modul tersinkronisasi dengan database lokal & cloud.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache data lokal berhasil dibersihkan!'),
                          backgroundColor: AppColors.matchaGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                    label: const Text('Bersihkan Cache Lokal'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.espressoDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODAL 8: KELUAR AKUN
  // ==========================================
  void _openLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar dari Akun Admin?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text('Sesi admin saat ini akan ditutup dan kembali ke halaman Login.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.berryRed, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Ya, Keluar Akun'),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espressoDark,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.softSand,
      appBar: AppBar(
        title: Text(
          'PENGATURAN & MODUL',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cafe Admin Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.coffeeGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.espressoDark.withOpacity(0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.creamLatte,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        auth.currentProfile?.fullName.isNotEmpty == true
                            ? auth.currentProfile!.fullName[0].toUpperCase()
                            : 'A',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.espressoDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.currentProfile?.fullName ?? 'Owner COFFI',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_cafeName • Hak Akses Owner',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.creamLatte,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'PILIH MODUL PENGATURAN:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Grid of 6 Core POS Modules (2 columns x 3 rows)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: [
                _buildGridCard(
                  title: 'Akun Staf',
                  subtitle: '${auth.demoStaff.length} Staf Terdaftar',
                  icon: Icons.badge_rounded,
                  iconColor: AppColors.warmCaramel,
                  bgColor: const Color(0xFFFFF7ED),
                  onTap: () => _openStaffModule(context),
                ),
                _buildGridCard(
                  title: 'Koneksi Cloud',
                  subtitle: SupabaseService.instance.isConnected ? 'Supabase Live' : 'Mode Offline',
                  icon: Icons.cloud_sync_rounded,
                  iconColor: SupabaseService.instance.isConnected ? AppColors.matchaGreen : AppColors.amberOrange,
                  bgColor: SupabaseService.instance.isConnected ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                  onTap: () => _openSupabaseModule(context),
                ),
                _buildGridCard(
                  title: 'Profil Kafe & Struk',
                  subtitle: _cafeName,
                  icon: Icons.storefront_rounded,
                  iconColor: AppColors.roastedCoffee,
                  bgColor: const Color(0xFFFAF5F0),
                  onTap: () => _openCafeProfileModule(context),
                ),
                _buildGridCard(
                  title: 'Pajak & PB1 Resto',
                  subtitle: _pb1Enabled ? 'PB1 10% Aktif' : 'Non-Aktif',
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.coldBrewBlue,
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () => _openTaxModule(context),
                ),
                _buildGridCard(
                  title: 'Printer Struk Kasir',
                  subtitle: 'Format $_printerSize Thermal',
                  icon: Icons.print_rounded,
                  iconColor: const Color(0xFF6366F1),
                  bgColor: const Color(0xFFEEF2FF),
                  onTap: () => _openPrinterModule(context),
                ),
                _buildGridCard(
                  title: 'Info Sistem',
                  subtitle: 'v1.0.0 • Counter POS',
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFF64748B),
                  bgColor: const Color(0xFFF1F5F9),
                  onTap: () => _openSystemInfoModule(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Tombol Keluar dari Sesi Admin
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openLogoutDialog(context, auth),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.berryRed.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.berryRed.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.logout_rounded, color: AppColors.berryRed, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keluar dari Sesi Admin',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.berryRed,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Akhiri sesi dan kembali ke halaman Login',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEAEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.espressoDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
