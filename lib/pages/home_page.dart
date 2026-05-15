import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/todo_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<TodoModel>> _futureTodos;

  @override
  void initState() {
    super.initState();
    _futureTodos = _apiService.obtenerTareas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú Principal - Tareas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
            },
          )
        ],
      ),
      body: FutureBuilder<List<TodoModel>>(
        future: _futureTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final tareas = snapshot.data!;
            return ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                return ListTile(
                  leading: CircleAvatar(child: Text('${tarea.idTarea}')),
                  title: Text(tarea.titulo),
                  trailing: Icon(
                    tarea.estaCompletada ? Icons.check_circle : Icons.pending_actions,
                    color: tarea.estaCompletada ? Colors.green : Colors.orange,
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No hay datos disponibles.'));
        },
      ),
    );
  }
}