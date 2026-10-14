import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'providers/admin_dashboard_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'providers/table_provider.dart';
import 'services/supabase_service.dart';
import 'views/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian locale formatting
  await initializeDateFormatting('id_ID', null);

  // Load saved credentials from local storage
  await SupabaseConfig.loadSavedConfig();

  // Initialize Supabase & Realtime connection
  await SupabaseService.instance.initialize();

  runApp(const CafekuApp());
}

class CafekuApp extends StatelessWidget {
  const CafekuApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        title: 'Cafeku - Modern Cafe POS & Kitchen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
      ),
    );
  }
}
