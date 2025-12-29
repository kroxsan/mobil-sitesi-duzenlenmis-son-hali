import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;
      
      // Admin paneline değil, ana sayfaya yönlendir
      Navigator.pushReplacementNamed(context, '/');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş başarılı!')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Giriş başarısız: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giriş Yap'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hoş Geldiniz',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // USERNAME
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Kullanıcı adı gerekli" : null,
                ),
                const SizedBox(height: 16),

                // PASSWORD
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Şifre gerekli" : null,
                ),

                const SizedBox(height: 24),

                // ERROR MESSAGE
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // LOGIN BUTTON
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Giriş Yap', style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),

                // REGISTER
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text("Hesabın yok mu? Kayıt Ol"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
