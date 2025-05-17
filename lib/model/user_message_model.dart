/// Modelo que representa un mensaje de usuario en el sistema de chat.
/// /// Se utiliza para intercambiar mensajes entre el cliente y el servidor.
class UserMessageModel {
  final String rol;
  final String message;
  final int id;
// Constructor principal para crear instancias de mensajes de usuario.
  UserMessageModel({
    required this.rol,
    required this.message,
    required this.id,
  });
  /// Constructor factory que crea una instancia a partir de un mapa JSON.
  factory UserMessageModel.fromJson(Map<String, dynamic> json) {
    return UserMessageModel(
      rol: json['rol'],
      message: json['message'],
      id: json['id'],
    );
  }
  /// Convierte el modelo a un mapa compatible con JSON.
  Map<String, dynamic> toJson() {
    return {'rol': rol, 'message': message, 'id': id};
  }
}
