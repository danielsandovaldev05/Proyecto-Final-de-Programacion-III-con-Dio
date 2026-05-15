import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login_page.dart';

void main() async {
  // Asegura la inicialización de bindings de Flutter para variables asíncronas
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargamos el archivo .env antes de iniciar la app (Requisito Nuevo)
  await dotenv.load(fileName: ".env");

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Final UMG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      // La aplicación arranca obligatoriamente en el Login
      home: const LoginPage(),
    );
  }
}