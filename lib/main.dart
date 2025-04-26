import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mubarak_vegetables/services/ZoneService.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/location_provider.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/BottomNavigationScreen.dart';
import 'screens/LocationUpdateScreen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider should be initialized first
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),

        // ProductsProvider uses AuthProvider's user UID
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
          create: (_) => ProductsProvider(),
          update: (ctx, auth, previous) {
            final provider = previous ?? ProductsProvider();
            provider.updateAuth(auth.user?.uid);
            return provider;
          },
        ),

        // OrdersProvider uses AuthProvider's user UID
        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(),
          update: (ctx, auth, previous) {
            final provider = previous ?? OrdersProvider();
            provider.updateAuth(auth.user?.uid);
            return provider;
          },
        ),

        // Other independent providers
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mubarak Vegetables',
        theme: _buildAppTheme(),
        home: SplashScreen(), // Your custom main screen
        routes: {
          '/product-detail': (ctx) => ProductDetailScreen(),
          CheckoutScreen.routeName: (ctx) => CheckoutScreen(),
          // Add more named routes if needed
        },
      ),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primarySwatch: Colors.green,
      colorScheme: ColorScheme.light(
        primary: Colors.green[800]!,
        secondary: Colors.orange[600]!,
      ),
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.green[800],
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
