class TodoModel {
  // Campos del modelo de la tarea
  final int idTarea;
  final int idUsuario;
  final String titulo;
  final bool estaCompletada;

  // Constructor del modelo
  TodoModel({
    required this.idTarea,
    required this.idUsuario,
    required this.titulo,
    required this.estaCompletada,
  });

  // Método de fábrica para crear una instancia de TodoModel a partir de un JSON
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      idTarea: json['id'],
      idUsuario: json['userId'],
      titulo: json['title'],
      estaCompletada: json['completed'],
    );
  }
}