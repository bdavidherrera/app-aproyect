/// Modelo que representa un mensaje de chat .
/// Almacena la información de cada mensaje enviado en una conversación.
class ChatMessageModel {
  final int? id;
  final int chatId;
  final String rol;
  final String message;
  final String? timestamp;

  /// Constructor principal del modelo de los mensajes.
  ChatMessageModel({
    this.id,
    required this.chatId,
    required this.rol,
    required this.message,
    this.timestamp,
  });

  /// Crea una instancia del modelo a partir de un Map (Leer de la BD).
  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'],
      chatId: map['chat_id'],
      rol: map['rol'],
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }
/// Convierte el modelo a un Map (usado para insertar en la BD).
/// Las claves del Map corresponden a los nombres de columnas en la BD.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chat_id': chatId,
      'rol': rol,
      'message': message,
      'timestamp': timestamp,
    };
  }
}