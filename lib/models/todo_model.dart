class TodoModel {
  final int idTarea;
  final int idUsuario;
  final String titulo;
  final bool estaCompletada;

  TodoModel({
    required this.idTarea,
    required this.idUsuario,
    required this.titulo,
    required this.estaCompletada,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      idTarea: json['id'],
      idUsuario: json['userId'],
      titulo: json['title'],
      estaCompletada: json['completed'],
    );
  }
}