import 'package:flutter/foundation.dart';
import 'package:flutter_application_4_geodesica/data/database_helper.dart';
import 'package:flutter_application_4_geodesica/model/user_message_model.dart';
import 'package:flutter_application_4_geodesica/model/chat_message_model.dart';

class ChatProvider with ChangeNotifier {
  List<UserMessageModel> _messages = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<UserMessageModel> get messages => _messages;

  void addMessage(UserMessageModel message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Carga los mensajes de un chat desde la base de datos
  Future<void> loadMessagesFromChat(int chatId) async {
    final dbMessages = await _dbHelper.getMessagesForChat(chatId);
    _messages =
        dbMessages.map((map) {
          return UserMessageModel(
            id: map['id'],
            rol: map['rol'],
            message: map['message'],
          );
        }).toList();
    notifyListeners();
  }

  // Guarda un mensaje en la base de datos
  Future<void> saveMessageToDatabase(
    int chatId,
    UserMessageModel message,
  ) async {
    final chatMessage = ChatMessageModel(
      chatId: chatId,
      rol: message.rol,
      message: message.message,
    );

    await _dbHelper.insertChatMessage(chatMessage.toMap());
    // No necesitamos llamar a notifyListeners() aquí porque ya se llama en addMessage
  }

  // Opcional: cargar mensajes iniciales y guardarlos en la base de datos si es un chat nuevo
  Future<void> loadInitialMessages(int chatId) async {
    final dbMessages = await _dbHelper.getMessagesForChat(chatId);

    if (dbMessages.isEmpty) {
      // Si no hay mensajes, es un chat nuevo, añadir mensaje de bienvenida
      final welcomeMessage = UserMessageModel(
        rol: 'system',
        message: '¡Hola! ¿En qué puedo ayudarte hoy?',
        id: 1,
      );

      // Guardar en la base de datos
      await saveMessageToDatabase(chatId, welcomeMessage);

      // Añadir a la lista local
      _messages = [welcomeMessage];
    } else {
      // Si hay mensajes, cargarlos de la base de datos
      _messages =
          dbMessages.map((map) {
            return UserMessageModel(
              id: map['id'],
              rol: map['rol'],
              message: map['message'],
            );
          }).toList();
    }

    notifyListeners();
  }

  // Procesa una pregunta relacionada con contabilidad
  Future<String> processAccountingQuery(String query) async {
    query = query.toLowerCase();
    String response = '';

    // Obtener datos de contabilidad
    final dbHelper = DatabaseHelper();

    try {
      // Consultas específicas
      if (query.contains('total de ingresos') ||
          query.contains('cuánto ingresó')) {
        final totalIngresos = await dbHelper.getTotalIngresos();
        response =
            'El total de ingresos es de \$${totalIngresos.toStringAsFixed(2)}.';
      } else if (query.contains('total de gastos') ||
          query.contains('cuánto se gastó')) {
        final totalGastos = await dbHelper.getTotalGastos();
        response =
            'El total de gastos es de \$${totalGastos.toStringAsFixed(2)}.';
      } else if (query.contains('balance') ||
          query.contains('saldo') ||
          query.contains('ganancias')) {
        final totalIngresos = await dbHelper.getTotalIngresos();
        final totalGastos = await dbHelper.getTotalGastos();
        final balance = totalIngresos - totalGastos;
        response =
            'El balance actual es de \$${balance.toStringAsFixed(2)}. ' +
            'Total de ingresos: \$${totalIngresos.toStringAsFixed(2)}. ' +
            'Total de gastos: \$${totalGastos.toStringAsFixed(2)}.';
      } else if (query.contains('gastos por categoría') ||
          query.contains('desglose de gastos')) {
        final gastosPorCategoria = await dbHelper.getGastosPorCategoria();
        response = 'Desglose de gastos por categoría:\n';
        gastosPorCategoria.forEach((categoria, monto) {
          response += '- $categoria: \$${monto.toStringAsFixed(2)}\n';
        });
      } else if (query.contains('último') || query.contains('recientes')) {
        final transacciones = await dbHelper.getAllContabilidadEntries();
        if (transacciones.isNotEmpty) {
          response = 'Últimas transacciones:\n';
          for (
            int i = 0;
            i < (transacciones.length > 5 ? 5 : transacciones.length);
            i++
          ) {
            final t = transacciones[i];
            response +=
                '- ${t['fecha']}: ${t['descripcion']} - \$${t['monto'].toStringAsFixed(2)} (${t['tipo']})\n';
          }
        } else {
          response = 'No hay transacciones registradas.';
        }
      } else if (query.contains('buscar')) {
        // Extraer el término de búsqueda
        final searchTerm = _extractSearchTerm(query);
        if (searchTerm.isNotEmpty) {
          final resultados = await dbHelper.searchContabilidad(searchTerm);
          if (resultados.isNotEmpty) {
            response = 'Resultados para "$searchTerm":\n';
            for (var resultado in resultados) {
              response +=
                  '- ${resultado['fecha']}: ${resultado['descripcion']} - \$${resultado['monto'].toStringAsFixed(2)} (${resultado['tipo']})\n';
            }
          } else {
            response = 'No se encontraron resultados para "$searchTerm".';
          }
        } else {
          response = 'Por favor, especifica qué quieres buscar.';
        }
      } else {
        // Respuesta genérica si no es una consulta específica
        response =
            'Puedo ayudarte con consultas de contabilidad como:\n' +
            '- Total de ingresos\n' +
            '- Total de gastos\n' +
            '- Balance actual\n' +
            '- Gastos por categoría\n' +
            '- Últimas transacciones\n' +
            '- Buscar [término]';
      }
    } catch (e) {
      response = 'Lo siento, ocurrió un error al procesar tu consulta: $e';
    }

    return response;
  }

  String _extractSearchTerm(String query) {
    // Eliminar "buscar" de la consulta
    final parts = query.split('buscar');
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return '';
  }
}
