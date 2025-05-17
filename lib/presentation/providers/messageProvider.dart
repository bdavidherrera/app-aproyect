import 'package:flutter/foundation.dart';
import 'package:flutter_application_4_geodesica/data/database_helper.dart';
import 'package:flutter_application_4_geodesica/model/user_message_model.dart';
import 'package:flutter_application_4_geodesica/model/chat_message_model.dart';
import 'package:flutter_application_4_geodesica/services/gemini_service.dart';
import 'package:sqflite/sqflite.dart';

class ChatProvider with ChangeNotifier {
  List<UserMessageModel> _messages = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GeminiService _geminiService = GeminiService();

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

  Future<String> processNaturalLanguageQuery(String query) async {
    try {
      // 1. Traducir la pregunta a SQL usando Gemini
      final sqlQuery = await _geminiService.translateToSQL(query);
      
      // 2. Ejecutar la consulta SQL en la base de datos local
      final results = await _executeSQLQuery(sqlQuery);
      
      // 3. Formatear los resultados para mostrarlos al usuario
      return _formatResults(results);
    } catch (e) {
      return 'Lo siento, ocurrió un error al procesar tu consulta: $e';
    }
  }

  Future<List<Map<String, dynamic>>> _executeSQLQuery(String sqlQuery) async {
    Database db = await _dbHelper.database;
    
    // Verificar que la consulta sea segura (solo SELECT)
    if (!sqlQuery.trim().toUpperCase().startsWith('SELECT')) {
      throw Exception('Solo se permiten consultas SELECT');
    }
    
    return await db.rawQuery(sqlQuery);
  }

  String _formatResults(List<Map<String, dynamic>> results) {
    if (results.isEmpty) {
      return 'No se encontraron resultados para tu consulta.';
    }

    String response = 'Resultados de tu consulta:\n\n';
    
    // Mostrar las columnas
    final columns = results.first.keys.toList();
    response += '| ${columns.join(' | ')} |\n';
    
    // Mostrar los datos
    for (var row in results) {
      response += '| ${columns.map((col) => row[col].toString()).join(' | ')} |\n';
    }
    
    return response;
  }

  // Procesa una pregunta relacionada con contabilidad usando el nuevo sistema basado en NLP
  Future<String> processAccountingQuery(String query) async {
    try {
      return await processNaturalLanguageQuery(query);
    } catch (e) {
      return 'Lo siento, ocurrió un error al procesar tu consulta: $e';
    }
  }
}