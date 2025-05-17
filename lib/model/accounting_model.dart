/// Modelo que representa un registro de contabilidad.
/// Contiene los datos básicos de un movimiento financiero (ingreso o gasto).
class AccountingModel {
    /// ID único del registro (autoincremental en la base de datos).
  final int? id;

  /// Fecha del movimiento en formato YYYY-MM-DD.
  final String fecha;

  /// Tipo de movimiento: 'Ingreso' o 'Gasto'.
  final String tipo;

  /// Descripción detallada del movimiento.
  final String descripcion;

  /// Monto del movimiento (valor positivo).
  final double monto;

  /// Categoría del movimiento (ej: 'Ventas', 'Alquiler', 'Salarios').
  final String categoria;

  /// Fecha de creación del registro en la base de datos (timestamp automático).
  final String? createdAt;

  /// Constructor principal del modelo.

  AccountingModel({
    this.id,
    required this.fecha,
    required this.tipo,
    required this.descripcion,
    required this.monto,
    required this.categoria,
    this.createdAt,
  });
  /// Constructor factory que crea una instancia del modelo a partir de un Map
  factory AccountingModel.fromMap(Map<String, dynamic> map) {
    return AccountingModel(
      id: map['id'],
      fecha: map['fecha'],
      tipo: map['tipo'],
      descripcion: map['descripcion'],
      monto: map['monto'],
      categoria: map['categoria'],
      createdAt: map['created_at'],
    );
  }
 /// Convierte el modelo a un Map
 /// Las claves del Map corresponden a los nombres de columnas en la BD.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'tipo': tipo,
      'descripcion': descripcion,
      'monto': monto,
      'categoria': categoria,
      'created_at': createdAt,
    };
  }
}