import 'package:coffi/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:coffi/core/theme/app_theme.dart';
import 'package:coffi/models/product_model.dart';
import 'package:coffi/models/table_model.dart';
import 'package:coffi/providers/auth_provider.dart';
import 'package:coffi/providers/cart_provider.dart';
import 'package:coffi/providers/menu_provider.dart';
import 'package:coffi/providers/order_provider.dart';
import 'package:coffi/providers/table_provider.dart';
import 'package:coffi/views/auth/login_screen.dart';
import 'package:coffi/views/auth/welcome_screen.dart';
import 'package:coffi/views/customer/customer_main_screen.dart';
import 'package:coffi/views/customer/widgets/customer_cart_sheet.dart';

Widget createTestApp(
  Widget home, {
  AuthProvider? auth,
  TableProvider? tables,
  MenuProvider? menu,
  CartProvider? cart,
  OrderProvider? orders,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: auth ?? AuthProvider()),
      ChangeNotifierProvider.value(value: tables ?? TableProvider()),
      ChangeNotifierProvider.value(value: menu ?? MenuProvider()),
      ChangeNotifierProvider.value(value: cart ?? CartProvider()),
      ChangeNotifierProvider.value(value: orders ?? OrderProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: home),
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await SupabaseService.instance.initialize();
  });

  group('FLOW 1: Authentication & Guest Entry Flow', () {
    testWidgets(
      'Guest entry from WelcomeScreen navigates directly to Dashboard',
      (tester) async {
        await tester.pumpWidget(createTestApp(const WelcomeScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final guestBtn = find.text('Lanjutkan sebagai Tamu (Guest Mode)');
        expect(guestBtn, findsOneWidget);

        await tester.tap(guestBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('LOKASI OUTLET'), findsOneWidget);
        expect(find.text('Beranda'), findsOneWidget);
        expect(find.text('Eksplor Menu'), findsNothing); // We are on Beranda
        final err = tester.takeException();
        if (err != null) {
          if (err is FlutterError) {
            debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
          } else {
            debugPrint('OVERFLOW ERROR DETAILS: $err');
          }
        }
        expect(err, isNull);
      },
    );

    testWidgets('LoginScreen form interaction & password obscurity toggle', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(const LoginScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final emailField = find.widgetWithText(TextField, 'example@mail.com');
      final passField = find.widgetWithText(TextField, '••••••••');
      expect(emailField, findsOneWidget);
      expect(passField, findsOneWidget);

      await tester.enterText(emailField, 'test@coffi.com');
      await tester.enterText(passField, 'secret123');
      await tester.pump();

      // Check obscurity icon toggle (initial is off/hidden)
      final visibilityOffIcon = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityOffIcon, findsOneWidget);
      await tester.tap(visibilityOffIcon);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });

    testWidgets('Navigation from LoginScreen to RegisterScreen and back', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(const LoginScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final registerLink = find.byWidgetPredicate(
        (w) =>
            w is RichText && w.text.toPlainText().contains('Daftar Sekarang'),
      );
      expect(registerLink, findsOneWidget);
      await tester.tap(registerLink);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('DAFTAR'), findsOneWidget);
      expect(find.text('VERIFIKASI PASSWORD'), findsOneWidget);

      final loginLink = find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText().contains('Masuk/Login Sekarang'),
      );
      expect(loginLink, findsOneWidget);
      await tester.tap(loginLink);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('MASUK'), findsOneWidget);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });
  });

  group('FLOW 2: Dashboard Header, Outlets, & Notifications Flow', () {
    testWidgets(
      'Outlet selector bottom sheet opens and changes selected outlet',
      (tester) async {
        await tester.pumpWidget(createTestApp(const CustomerMainScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        final outletSelector = find.text('COFFI (Senopati)');
        expect(outletSelector, findsOneWidget);

        await tester.tap(outletSelector);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Pilih Lokasi Outlet'), findsOneWidget);
        expect(find.text('COFFI (SCBD Park)'), findsOneWidget);

        await tester.tap(find.text('COFFI (SCBD Park)'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('COFFI (SCBD Park)'), findsOneWidget);
        final err = tester.takeException();
        if (err != null) {
          if (err is FlutterError) {
            debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
          } else {
            debugPrint('OVERFLOW ERROR DETAILS: $err');
          }
        }
        expect(err, isNull);
      },
    );

    testWidgets('Notification sheet opens and can be dismissed', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(const CustomerMainScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final bellIcon = find.byIcon(Icons.notifications_none_rounded);
      expect(bellIcon, findsOneWidget);

      await tester.tap(bellIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Notifikasi Promo & Pesanan'), findsOneWidget);
      expect(find.text('Promo Buy 1 Get 1 Free Aktif!'), findsOneWidget);

      // Dismiss bottom sheet by tapping barrier
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Notifikasi Promo & Pesanan'), findsNothing);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });

    testWidgets('LIHAT SEMUA on Rekomendasi Favorit navigates to Menu tab', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp(const CustomerMainScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final seeAll = find.text('LIHAT SEMUA');
      expect(seeAll, findsOneWidget);

      await tester.tap(seeAll);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Eksplor Menu'), findsOneWidget);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });
  });

  group('FLOW 3: Catalog Browsing, Search, & Filtering Flow', () {
    testWidgets(
      'Category chips filter products dynamically without exceptions',
      (tester) async {
        await tester.pumpWidget(
          createTestApp(const CustomerMainScreen(initialTab: 1)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Eksplor Menu'), findsOneWidget);
        expect(find.text('Semua'), findsOneWidget);

        final espressoChip = find.text('Espresso');
        if (espressoChip.evaluate().isNotEmpty) {
          await tester.tap(espressoChip);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        }

        final nonCoffeeChip = find.text('Non-Coffee');
        if (nonCoffeeChip.evaluate().isNotEmpty) {
          await tester.tap(nonCoffeeChip);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
        }

        await tester.tap(find.text('Semua'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final err = tester.takeException();
        if (err != null) {
          if (err is FlutterError) {
            debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
          } else {
            debugPrint('OVERFLOW ERROR DETAILS: $err');
          }
        }
        expect(err, isNull);
      },
    );

    testWidgets(
      'Search query filters menu items and gracefully handles empty results',
      (tester) async {
        final menu = MenuProvider();
        await menu.init();
        await tester.pumpWidget(
          createTestApp(const CustomerMainScreen(initialTab: 1), menu: menu),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        final searchField = find.byType(TextField);
        expect(searchField, findsOneWidget);

        await tester.enterText(searchField, 'Aren');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        await tester.enterText(searchField, 'non_existent_drink_xyz');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Tidak ada menu ditemukan'), findsOneWidget);

        await tester.enterText(searchField, '');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Tidak ada menu ditemukan'), findsNothing);
        final err = tester.takeException();
        if (err != null) {
          if (err is FlutterError) {
            debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
          } else {
            debugPrint('OVERFLOW ERROR DETAILS: $err');
          }
        }
        expect(err, isNull);
      },
    );
  });

  group('FLOW 4: Add to Cart, Badge Counter, & Empty Cart State', () {
    testWidgets('Empty cart sheet renders friendly empty illustration', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestApp(const CustomerMainScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final cartDock = find.text('Keranjang');
      expect(cartDock, findsOneWidget);

      await tester.tap(cartDock);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Keranjang masih kosong'), findsOneWidget);
      expect(find.text('Pilih menu favorit Anda sekarang.'), findsOneWidget);

      // Dismiss
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });

    testWidgets(
      'Adding product from Favorite Card updates Cart badge & shows SnackBar',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final cart = CartProvider();
        final menu = MenuProvider();
        await menu.init();
        await tester.pumpWidget(
          createTestApp(const CustomerMainScreen(), cart: cart, menu: menu),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(cart.totalItemsCount, 0);

        await tester.drag(
          find.text('Mau ngopi apa hari ini?'),
          const Offset(0, -300),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        final addButtons = find.byIcon(Icons.add_rounded);
        expect(addButtons, findsWidgets);

        await tester.tap(addButtons.first);
        await tester.pump();

        expect(cart.totalItemsCount, 1);
        expect(
          find.textContaining('ditambahkan ke keranjang.'),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 2));
        final err = tester.takeException();
        if (err != null) {
          if (err is FlutterError) {
            debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
          } else {
            debugPrint('OVERFLOW ERROR DETAILS: $err');
          }
        }
        expect(err, isNull);
      },
    );
  });

  group('FLOW 5: Cart Management & Quantity Modification', () {
    testWidgets('Incrementing, decrementing, and clearing items in CartSheet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cart = CartProvider();
      final demoProduct = ProductModel(
        id: 'p1',
        categoryId: 'c1',
        name: 'COFFI Aren',
        description: 'Espresso, Milk, Gula Aren',
        price: 28000,
        costPrice: 10500,
        stock: 35,
        minStock: 10,
        trackStock: true,
        isActive: true,
      );

      cart.addItem(product: demoProduct);
      expect(cart.totalItemsCount, 1);
      expect(cart.subtotalAmount, 28000);

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (ctx) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
                      builder: (_) => CustomerCartSheet(onOrderPlaced: () {}),
                    );
                  },
                  child: const Text('Buka Keranjang'),
                ),
              );
            },
          ),
          cart: cart,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Buka Keranjang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('COFFI Aren'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tap '+' button inside cart sheet (Icons.add_circle_outline_rounded)
      final incrementBtn = find.byIcon(Icons.add_circle_outline_rounded);
      expect(incrementBtn, findsOneWidget);
      await tester.tap(incrementBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cart.totalItemsCount, 2);
      expect(cart.subtotalAmount, 56000);

      // Tap '-' button inside cart sheet (Icons.remove_circle_outline_rounded)
      final decrementBtn = find.byIcon(Icons.remove_circle_outline_rounded);
      expect(decrementBtn, findsOneWidget);
      await tester.tap(decrementBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cart.totalItemsCount, 1);
      expect(cart.subtotalAmount, 28000);

      // Tap 'Hapus Semua'
      final clearAllBtn = find.text('Hapus Semua');
      expect(clearAllBtn, findsOneWidget);
      await tester.tap(clearAllBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cart.totalItemsCount, 0);

      expect(find.text('Keranjang masih kosong'), findsOneWidget);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });
  });

  group('FLOW 6: Dine-in Table Selection & Checkout Validation', () {
    testWidgets('Dine In order requires table selection before placing order', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cart = CartProvider();
      final tableProv = TableProvider();
      final demoProduct = ProductModel(
        id: 'p1',
        categoryId: 'c1',
        name: 'COFFI Aren',
        price: 28000,
        costPrice: 10000,
        stock: 20,
        minStock: 5,
        trackStock: true,
        isActive: true,
      );

      cart.addItem(product: demoProduct);
      cart.setOrderType('dine_in');

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (ctx) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
                      builder: (_) => CustomerCartSheet(onOrderPlaced: () {}),
                    );
                  },
                  child: const Text('Buka Keranjang'),
                ),
              );
            },
          ),
          cart: cart,
          tables: tableProv,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Buka Keranjang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Submit without table selected
      final submitBtn = find.text('Kirim Pesanan Sekarang');
      expect(submitBtn, findsOneWidget);

      await tester.tap(submitBtn);
      await tester.pump();

      expect(
        find.text('Silakan pilih nomor meja untuk pesanan Dine In.'),
        findsOneWidget,
      );

      // Switch order type to Take Away
      final takeAwayOption = find.textContaining('Take Away');
      expect(takeAwayOption, findsOneWidget);
      await tester.tap(takeAwayOption);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(cart.isTakeaway, isTrue);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });

    testWidgets('Selecting table and placing order triggers successful flow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cart = CartProvider();
      final tableProv = TableProvider();
      final orderProv = OrderProvider();

      final demoProduct = ProductModel(
        id: 'p1',
        categoryId: 'c1',
        name: 'COFFI Aren',
        price: 28000,
        costPrice: 10000,
        stock: 20,
        minStock: 5,
        trackStock: true,
        isActive: true,
      );

      cart.addItem(product: demoProduct);
      cart.setOrderType('dine_in');
      cart.setSelectedTable(
        TableModel(
          id: 't1',
          tableNumber: 'Meja 01',
          area: 'Indoor',
          capacity: 2,
          status: 'available',
        ),
      );

      bool orderPlacedCalled = false;

      await tester.pumpWidget(
        createTestApp(
          Builder(
            builder: (ctx) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: ctx,
                      isScrollControlled: true,
                      builder: (_) => CustomerCartSheet(
                        onOrderPlaced: () {
                          orderPlacedCalled = true;
                        },
                      ),
                    );
                  },
                  child: const Text('Buka Keranjang'),
                ),
              );
            },
          ),
          cart: cart,
          tables: tableProv,
          orders: orderProv,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Buka Keranjang'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      final submitBtn = find.text('Kirim Pesanan Sekarang');
      await tester.tap(submitBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(orderPlacedCalled, isTrue);
      expect(cart.items.isEmpty, isTrue);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });
  });

  group('FLOW 7: Order Status Tab & Empty State', () {
    testWidgets('Empty orders tab renders illustration and Eksplor Menu CTA', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestApp(const CustomerMainScreen(initialTab: 3)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Status & Riwayat Pesanan'), findsOneWidget);
      expect(find.text('Belum Ada Pesanan'), findsOneWidget);

      final ctaBtn = find.widgetWithText(ElevatedButton, 'Eksplor Menu');
      expect(ctaBtn, findsOneWidget);

      await tester.tap(ctaBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should redirect to Menu tab
      expect(find.text('Eksplor Menu'), findsOneWidget);
      final err = tester.takeException();
      if (err != null) {
        if (err is FlutterError) {
          debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
        } else {
          debugPrint('OVERFLOW ERROR DETAILS: $err');
        }
      }
      expect(err, isNull);
    });
  });

  group('FLOW 8: Profile Tab & Logout Flow', () {
    testWidgets(
      'Profile tab elements and Logout action works without crashes',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          createTestApp(const CustomerMainScreen(initialTab: 4)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Profil Saya'), findsOneWidget);
        expect(find.text('COFFI STAMP CARD'), findsOneWidget);
        expect(find.text('Keluar Sesi'), findsOneWidget);

        await tester.tap(find.text('Keluar Sesi'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Navigates back to WelcomeScreen
        expect(find.text('COFFI'), findsOneWidget);
        expect(find.text('MASUK / DAFTAR'), findsOneWidget);
        final err = tester.takeException();
        if (err != null) {
          if (err is FlutterError) {
            debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
          } else {
            debugPrint('OVERFLOW ERROR DETAILS: $err');
          }
        }
        expect(err, isNull);
      },
    );
  });

  group(
    'FLOW 9: Multi-Resolution Responsiveness & Anti-Overflow Diagnostics',
    () {
      final resolutions = [
        {
          'name': 'Compact Phone (360x780)',
          'size': const Size(360 * 2, 780 * 2),
          'ratio': 2.0,
        },
        {
          'name': 'Standard Phone (390x844)',
          'size': const Size(390 * 3, 844 * 3),
          'ratio': 3.0,
        },
        {
          'name': 'Large Phone (412x915)',
          'size': const Size(412 * 2.6, 915 * 2.6),
          'ratio': 2.6,
        },
      ];

      for (final res in resolutions) {
        testWidgets('Dashboard on ${res['name']} has 0 RenderFlex overflow', (
          tester,
        ) async {
          tester.view.physicalSize = res['size'] as Size;
          tester.view.devicePixelRatio = res['ratio'] as double;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(createTestApp(const CustomerMainScreen()));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.text('LOKASI OUTLET'), findsOneWidget);
          expect(find.text('Rekomendasi Favorit'), findsOneWidget);
          final err = tester.takeException();
          if (err != null) {
            if (err is FlutterError) {
              debugPrint('OVERFLOW ERROR DEEP: ${err.toStringDeep()}');
            } else {
              debugPrint('OVERFLOW ERROR DETAILS: $err');
            }
          }
          expect(err, isNull);
        });
      }
    },
  );
}
