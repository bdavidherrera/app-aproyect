/// Modelo que representa una conversación (chat) en la aplicación.
/// Contiene la información básica de un hilo de conversación entre el usuario y el sistema.
class ChatModel {
 
  final int? id;
  final int userId;
  final String title;
  final String? createdAt;
/// Constructor principal del modelo de chat.
  ChatModel({
    this.id,
    required this.userId,
    required this.title,
    this.createdAt,
  });

  /// instancia de ChatModel a partir de un mapa de datos.
  /// [map]: Mapa con las claves correspondientes a las columnas de la tabla chats
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      createdAt: map['created_at'],
    );
  }
  /// modelo a un mapa de datos compatible con la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt,
    };
  }
}