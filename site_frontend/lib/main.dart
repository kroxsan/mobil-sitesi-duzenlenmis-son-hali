import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // ⬅️ SADECE BUNU EKLEDİK

import 'providers/event_provider.dart';
import 'providers/auth_provider.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/admin_panel_page.dart';
import 'pages/my_tickets_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.loadToken();

  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, EventProvider>(
          create: (_) => EventProvider(),
          update: (_, authProvider, eventProvider) {
            eventProvider!.token = authProvider.token;
            return eventProvider;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Etkinlik Sitesi',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        builder: (context, child) {
          // 🔥 SADECE WEB'DE TELEFON GÖRÜNÜMÜ
          if (kIsWeb) {
            return Center(
              child: Container(
                width: 390,   // iPhone 14 genişliği
                height: 844,  // iPhone 14 yüksekliği
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: child!,
                ),
              ),
            );
          }

          // 📱 MOBİLDE HİÇBİR ŞEY DEĞİŞMEZ
          return child!;
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/admin': (context) => const AdminPanelPage(),
          '/my-tickets': (context) => const MyTicketsPage(),
        },
      ),
    );
  }
}
