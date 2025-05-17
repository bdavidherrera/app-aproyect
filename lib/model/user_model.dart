/// Modelo que representa un usuario.
class UserModel {
    // Propiedades que almacenan la información del usuario
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final String? birthDate;
  final String? document;
  final String? createdAt;

  // Constructor principal que inicializa todas las propiedades
  // Los campos marcados con required son obligatorios al crear una instancia

  UserModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    this.birthDate,
    this.document,
    this.createdAt,
  });

  // Constructor factory que convierte un Map ( JSON) a un objeto UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      fullName: map['fullName'],
      email: map['email'],
      password: map['password'],
      birthDate: map['birthDate'],
      document: map['document'],
      createdAt: map['created_at'],
    );
  }
  // Método que convierte el objeto UserModel a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password, // Nota: en producción deberías almacenar contraseñas hasheadas
      'birthDate': birthDate,
      'document': document,
      'created_at': createdAt,
    };
  }
}