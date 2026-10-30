import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coffi/core/theme/app_theme.dart';
import 'package:coffi/main.dart';
import 'package:coffi/providers/auth_provider.dart';
import 'package:coffi/providers/cart_provider.dart';
import 'package:coffi/providers/menu_provider.dart';
import 'package:coffi/providers/order_provider.dart';
import 'package:coffi/providers/table_provider.dart';
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
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: home,
    ),
  );
}

void main() {
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
    await tester.pumpWidget(createTestApp(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Silakan masuk untuk melanjutkan pesanan Anda.'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('Atau masuk dengan'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('OTP'), findsOneWidget);
  });

  testWidgets('RegisterScreen elements check', (WidgetTester tester) async {
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
}
