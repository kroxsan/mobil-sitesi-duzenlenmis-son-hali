import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Etkinlik Platformu',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.deepPurple,
      elevation: 2,
      actions: [
        const SizedBox(width: 8),

        // DEBUG BİLGİSİ - Giriş durumunu ekranda göster
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: authProvider.isLoggedIn ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                authProvider.isLoggedIn ? 'GİRİŞ YAPILDI' : 'GİRİŞ YOK',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),

        const SizedBox(width: 12),

        // Profil ikonu
        IconButton(
          icon: const Icon(
            Icons.person,
            color: Colors.white,
            size: 28,
          ),
          tooltip: 'Giriş Yap / Kayıt Ol',
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),

        // "Diğer Şıklar" butonu
        Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (!authProvider.isLoggedIn) {
              return const SizedBox.shrink();
            }

            return PopupMenuButton<String>(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[700],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Diğer Şıklar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
              offset: const Offset(0, 50),
              onSelected: (value) async {
                switch (value) {
                  case 'tickets':
                    Navigator.pushNamed(context, '/my-tickets');
                    break;
                  case 'admin':
                    Navigator.pushNamed(context, '/admin');
                    break;
                  case 'logout':
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Çıkış yapıldı'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'tickets',
                    child: Row(
                      children: [
                        Icon(Icons.confirmation_number, color: Colors.deepPurple),
                        SizedBox(width: 12),
                        Text('Biletlerim'),
                      ],
                    ),
                  ),

                  // 🔐 SADECE ADMIN GÖRÜR
                  if (authProvider.isAdmin)
                    const PopupMenuItem<String>(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(Icons.admin_panel_settings,
                              color: Colors.deepPurple),
                          SizedBox(width: 12),
                          Text('Admin Panel'),
                        ],
                      ),
                    ),

                  const PopupMenuDivider(),

                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Çıkış Yap',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ];
              },
            );
          },
        ),

        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
