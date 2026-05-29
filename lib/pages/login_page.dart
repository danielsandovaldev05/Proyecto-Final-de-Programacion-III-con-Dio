import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  void _iniciarSesion() {
    // Validación simple simulada
    if (_usuarioController.text == "admin" && _passwordController.text == "1234") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos (admin / 1234)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('Proyecto Final - Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Usuario', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _iniciarSesion,
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}