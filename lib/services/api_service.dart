import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/todo_model.dart';

class ApiService {
  // Inicializamos Dio
  final Dio _dio = Dio();

  Future<List<TodoModel>> obtenerTareas() async {
    try {
      // Tomamos la URL directamente del archivo .env de forma segura
      final String urlApi = dotenv.env['URL_API'] ?? '';
      
      if (urlApi.isEmpty) {
        throw Exception("Error: La URL_API no está configurada en el archivo .env");
      }

      // Petición asíncrona con Dio
      final response = await _dio.get(urlApi);

      if (response.statusCode == 200) {
        List<dynamic> datosJson = response.data; // Dio ya parsea el JSON automáticamente
        return datosJson.map((t) => TodoModel.fromJson(t)).toList();
      } else {
        throw Exception('Error de servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Fallo en la conectividad con Dio: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}