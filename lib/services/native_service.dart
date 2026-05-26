import 'dart:ffi'; // Para el FFI
import 'dart:io';
import 'package:ffi/ffi.dart'; // Para manejar strings entre Dart y C++

// Definición de las funciones que llamaremos de C++
typedef CrearManagerFunc = Pointer<Void> Function();
typedef CrearManager = Pointer<Void> Function();

typedef InsertarFunc = Void Function(Pointer<Void>, Int32, Int32, Pointer<Utf8>, Bool);
typedef Insertar = void Function(Pointer<Void>, int, int, Pointer<Utf8>, bool);

typedef ConteoFunc = Int32 Function(Pointer<Void>);
typedef Conteo = int Function(Pointer<Void>);

typedef BuscarFunc = Bool Function(Pointer<Void>, Int32);
typedef Buscar = bool Function(Pointer<Void>, int);

typedef EliminarFunc = Bool Function(Pointer<Void>, Int32);
typedef Eliminar = bool Function(Pointer<Void>, int);

class NativeService {
  late DynamicLibrary _nativeLib;
  late Pointer<Void> _manager;

  NativeService() {
    // Cargar la librería compilada por CMake
    _nativeLib = Platform.isAndroid
        ? DynamicLibrary.open("libnative_lib.so")
        : DynamicLibrary.process();

    // Crear la instancia del Manager en C++
    final crear = _nativeLib.lookupFunction<CrearManagerFunc, CrearManager>('crear_manager');
    _manager = crear();
  }

  // Sincronización: Pasa un objeto de Dart a C++
  void insertarTarea(int id, int userId, String title, bool completed) {
    final insertar = _nativeLib.lookupFunction<InsertarFunc, Insertar>('insertar_todo');
    
    // Convertir el String de Dart a un puntero de C (Utf8)
    final titlePtr = title.toNativeUtf8();
    
    insertar(_manager, id, userId, titlePtr, completed);
    
    //Liberar la memoria que pedimos para el string
    malloc.free(titlePtr);
  }

  // Validación: Regresa el conteo real que hay en la memoria de C++
  int obtenerTotalEnMemoria() {
    final contar = _nativeLib.lookupFunction<ConteoFunc, Conteo>('obtener_conteo');
    return contar(_manager);
  }

  bool buscar(int id) {
    final buscar = _nativeLib.lookupFunction<BuscarFunc, Buscar>('buscar_todo');
    return buscar(_manager, id);
  }

  bool eliminar(int id) {
    final eliminar = _nativeLib.lookupFunction<EliminarFunc, Eliminar>('eliminar_todo');
    return eliminar(_manager, id);
  }
}