import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/native_service.dart';
import '../models/todo_model.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// Esta clase es el corazón de la aplicación, donde se muestra la lista de tareas y se sincroniza con C++
class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<TodoModel>> _futureTodos;
  final NativeService _nativeService = NativeService();
  List<TodoModel> _listaCompleta =
      []; // Para mantener una copia local de la lista completa de tareas

  @override
  void initState() {
    super.initState();
    // Sincronizar una sola vez al iniciiar la página, para evitar múltiples llamadas a la API cada vez que se reconstruya el widget.
    _futureTodos = _apiService.obtenerTareas().then((tareas) {
      _listaCompleta = List.from(tareas); // Respaldamos
      _sincronizarConNativo(tareas); // Sincronizamos con C++
      return tareas;
    });
  }

  // Función para sincronizar los datos obtenidos de la API con la memoria de C++
  void _sincronizarConNativo(List<TodoModel> tareas) {
    for (var tarea in tareas) {
      _nativeService.insertarTarea(
        tarea.idTarea,
        tarea.idUsuario,
        tarea.titulo,
        tarea.estaCompletada,
      );
    }

    // Validación: Obtener el conteo real que hay en la memoria de C++
    int totalEnC = _nativeService.obtenerTotalEnMemoria();
    print(
      "Sincronización completa: ${tareas.length} items de API vs $totalEnC en C++",
    );

    // Usar WidgetsBinding para evitar un error común en Flutter si se intenta mostrar el SnackBar mientras el árbol de widgets se está construyendo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sincronizado con C++: $totalEnC registros validados.'),
        ),
      );
    });
  }

  // Función de prueba: Buscar en C++ para el botón flotante de la interfaz
  void _testBuscar(int id) {
    bool existe = _nativeService.buscar(
      id,
    ); // Debes añadir esta función en el NativeService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ID $id ${existe ? "encontrado en C++" : "no encontrado"}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Función de prueba: Eliminar en C++
  void _testEliminar(int id) {
    bool eliminado = _nativeService.eliminar(id);
    if (eliminado) {
      // Si se borró en C++, ahora limpiamos la UI
      _futureTodos.then((listaDeTareas) {
        setState(() {
          listaDeTareas.removeWhere((tarea) => tarea.idTarea == id);
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID $id eliminado de RAM y pantalla')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al eliminar en C++')));
    }
  }

  // Método para buscar mediante un ID ingresado manualmente
  void _buscarConDialogo() {
    final TextEditingController idController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buscar Tarea por ID"),
        content: TextField(
          controller: idController,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () {
              int id = int.tryParse(idController.text) ?? 0;

              // Verificar si existe en C++
              bool existe = _nativeService.buscar(id);
              Navigator.pop(context);

              if (existe) {
                // Filtro para  la vista para mostrar solo esa tarea
                setState(() {
                  _futureTodos = Future.value(
                    _listaCompleta
                        .where((tarea) => tarea.idTarea == id)
                        .toList(), // usar la lista completa para filtrar y mostrar solo la tarea buscada, sin perder la referencia original de todas las tareas.
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No encontrada en C++")),
                );
              }
            },
            child: const Text("Filtrar"),
          ),
        ],
      ),
    );
  }

  // Método para reestablecer (Insertar todo de nuevo)
  Future<void> _reestablecerTareas() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Restaurando datos...")));

    // Volvemos a pedir los datos a la API
    List<TodoModel> tareas = await _apiService
        .obtenerTareas(); // Asegura de que retorne la lista
    _sincronizarConNativo(tareas);

    setState(() {
      _futureTodos = Future.value(tareas); // Actualizamos la vista
    });
  }

  // El método build es donde se construye la interfaz de usuario de la página principal, mostrando la lista de tareas y los botones de acción.

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
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
                    tarea.estaCompletada
                        ? Icons.check_circle
                        : Icons.pending_actions,
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
