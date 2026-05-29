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
      // El AppBar con un botón de logout que regresa al LoginPage
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

      // El cuerpo de la página muestra un FutureBuilder que se encarga de manejar la carga de datos desde la API y mostrar la lista de tareas.
      body: FutureBuilder<List<TodoModel>>(
        future: _futureTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final tareas = snapshot.data!;

            // Activar la sincronización en tiempo real
            // Justo aquí, cuando snapshot.hasData es verdadero, para saber que la API ya respondió con éxito.
            _sincronizarConNativo(tareas);

            return ListView.builder(
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                return ListTile(
                  // El ID de la tarea a la izquierda
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '${tarea.idTarea}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  // 2. Envolvemos el título en un Expanded dentro de una Row para que no empuje a los botones
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tarea.titulo,
                          maxLines:
                              1, // Evita que se desarme el diseño si el título es muy largo
                          overflow: TextOverflow
                              .ellipsis, // Si no cabe, le pone tres puntitos (...)
                        ),
                      ),
                    ],
                  ),

                  // 3. Los botones de acción alineados a la derecha
                  trailing: SizedBox(
                    width:
                        140, // Le damos un ancho fijo al contenedor de botones para que Flutter sepa cuánto espacio reservar
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Icono de estado (Completado/Pendiente)
                        Icon(
                          tarea.estaCompletada
                              ? Icons.check_circle
                              : Icons.pending_actions,
                          color: tarea.estaCompletada
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        // Lupa para Buscar en C++
                        IconButton(
                          constraints:
                              const BoxConstraints(), // Hace el botón más compacto
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(Icons.search, color: Colors.blue),
                          onPressed: () => _testBuscar(tarea.idTarea),
                        ),
                        // Basurero para Eliminar en C++ y UI
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _testEliminar(tarea.idTarea),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No hay datos disponibles.'));
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn_Buscar",
            backgroundColor: Colors.blue,
            onPressed: _buscarConDialogo,
            tooltip: 'Buscar en C++',
            child: const Icon(Icons.search, color: Colors.white),
          ),
          const SizedBox(height: 16), // Espacio entre los botones
          FloatingActionButton(
            heroTag: "btnReestablecer",
            backgroundColor: Colors.green,
            onPressed: _reestablecerTareas,
            tooltip: 'Reestablecer Tareas',
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          const SizedBox(height: 16), // Espacio entre los botones
          // Botón para limpiar filtro (Regresar al inicio)
          FloatingActionButton(
            heroTag: "btn_limpiar",
            backgroundColor: Colors.orange,
            onPressed: () {
              setState(() {
                _futureTodos = Future.value(
                  _listaCompleta,
                ); // Restauramos la vista con el respaldo
              });
            },
            child: const Icon(Icons.home, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
