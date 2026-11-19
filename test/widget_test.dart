import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coffi/core/theme/app_theme.dart';
import 'package:coffi/main.dart';
import 'package:coffi/providers/admin_dashboard_provider.dart';
import 'package:coffi/providers/auth_provider.dart';
import 'package:coffi/providers/cart_provider.dart';
import 'package:coffi/providers/menu_provider.dart';
import 'package:coffi/providers/order_provider.dart';
import 'package:coffi/providers/table_provider.dart';
import 'package:coffi/services/supabase_service.dart';
import 'package:coffi/views/admin/admin_main_screen.dart';
import 'package:coffi/views/auth/login_screen.dart';
import 'package:coffi/views/auth/register_screen.dart';
import 'package:coffi/views/auth/welcome_screen.dart';
import 'package:coffi/views/customer/customer_main_screen.dart';

Widget createTestApp(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => TableProvider()),
      ChangeNotifierProvider(create: (_) => MenuProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: home,
    ),
  );
}

void main() {
  setUpAll(() async {
    await SupabaseService.instance.initialize();
  });

  testWidgets('WelcomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CoffiApp());
    await tester.pumpAndSettle();

    expect(find.text('COFFI'), findsOneWidget);
    expect(find.text('MASUK / DAFTAR'), findsOneWidget);
    expect(find.text('Lanjutkan sebagai Tamu (Guest Mode)'), findsOneWidget);
  });

  testWidgets('WelcomeScreen navigation to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('MASUK / DAFTAR'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
  });

  testWidgets('WelcomeScreen Guest Mode navigates directly to CustomerMainScreen', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const WelcomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lanjutkan sebagai Tamu (Guest Mode)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('LOKASI OUTLET'), findsOneWidget);
    expect(find.text('Rekomendasi Favorit'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
  });

  testWidgets('LoginScreen elements check', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Silakan masuk untuk melanjutkan pesanan Anda.'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('Atau masuk dengan'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('OTP'), findsNothing);
  });

  testWidgets('RegisterScreen elements check', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp(const RegisterScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('DAFTAR'), findsOneWidget);
    expect(find.text('Atau masuk dengan'), findsOneWidget);
  });

  testWidgets('Dashboard has no layout overflow on phone-sized screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp(const CustomerMainScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Banner copy is rendered once (no duplicated text baked into the image).
    expect(find.text('Buy 1 Get 1 Free!'), findsOneWidget);
    expect(find.text('LIMITED TIME'), findsOneWidget);
    expect(find.text('Rekomendasi Favorit'), findsOneWidget);
    // Any RenderFlex overflow would surface here as a test exception.
    expect(tester.takeException(), isNull);
  });

  testWidgets('CustomerMainScreen Dashboard & Navigation elements check', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const CustomerMainScreen()));
    // Let async futures resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Check Dashboard elements
    expect(find.text('LOKASI OUTLET'), findsOneWidget);
    expect(find.text('COFFI (Senopati)'), findsOneWidget);
    expect(find.text('Rekomendasi Favorit'), findsOneWidget);
    expect(find.text('LIHAT SEMUA'), findsOneWidget);
    expect(find.text('LIMITED TIME'), findsOneWidget);
    expect(find.text('Buy 1 Get 1 Free!'), findsOneWidget);

    // Check Bottom Nav items (with fixed unclipped labels)
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);
    expect(find.text('Pesanan'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Tap on Menu nav item
    await tester.tap(find.text('Menu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Check Eksplor Menu screen
    expect(find.text('Eksplor Menu'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
  });

  testWidgets('AdminMainScreen Dashboard and Kelola Produk render and work interactively', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestApp(const AdminMainScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Senopati Branch is removed and core dashboard elements are shown
    expect(find.text('Senopati Branch'), findsNothing);
    expect(find.text('TOTAL PENJUALAN'), findsOneWidget);
    expect(find.text('TRANSAKSI'), findsOneWidget);
    expect(find.text('STOK KRITIS'), findsWidgets);
    expect(find.text('Grafik Penjualan'), findsOneWidget);
    expect(find.text('HARI INI'), findsOneWidget);
    expect(find.text('Menu Terlaris'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Test interactive period selector on Grafik Penjualan
    await tester.tap(find.text('HARI INI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7 Hari Terakhir'));
    await tester.pumpAndSettle();
    expect(find.text('7 HARI'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Test LIHAT SEMUA navigates to Kelola Produk tab
    await tester.ensureVisible(find.text('LIHAT SEMUA'));
    await tester.tap(find.text('LIHAT SEMUA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Kelola Produk'), findsOneWidget);
    expect(find.text('Tambah Produk'), findsOneWidget);
    expect(find.text('Kategori: Semua'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Tapping a product navigates to dedicated Edit Produk screen
    await tester.tap(find.text('Almond Croissant').first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Produk'), findsOneWidget);
    expect(find.text('Foto Produk'), findsOneWidget);
    expect(find.text('Satuan Produk'), findsOneWidget);
    expect(find.text('SIMPAN PRODUK'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Return to Kelola Produk via BATAL
    await tester.tap(find.text('BATAL'));
    await tester.pumpAndSettle();
    expect(find.text('Kelola Produk'), findsOneWidget);

    // Switch to Kelola Kategori sub-tab
    await tester.tap(find.text('Kategori'));
    await tester.pumpAndSettle();
    expect(find.text('Kelola Kategori'), findsOneWidget);
    expect(find.text('Tambah Kategori'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Switch to Kelola Varian & Add-on sub-tab
    await tester.tap(find.text('Varian & Add-on'));
    await tester.pumpAndSettle();
    expect(find.text('Kelola Varian & Add-on'), findsOneWidget);
    expect(find.text('DAFTAR ADD-ON'), findsOneWidget);
    expect(find.text('Extra Shot'), findsOneWidget);
    expect(find.text('Tambah Add-on'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
