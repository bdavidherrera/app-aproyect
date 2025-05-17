// gemini_service.dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyD1b8354ZDvTxFjg778GGpc3eUmUA8Ji0U'; // Reemplaza con tu API key real
  final GenerativeModel _model;

  GeminiService() : _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
  );

  Future<String> translateToSQL(String naturalLanguageQuery) async {
    try {
      final prompt = """
      Eres un asistente especializado en traducir preguntas en lenguaje natural a consultas SQL válidas.
      La base de datos tiene una tabla llamada 'contabilidad' con las siguientes columnas:
      - id (INTEGER, PRIMARY KEY)
      - fecha (TEXT, formato YYYY-MM-DD)
      - tipo (TEXT, 'Ingreso' o 'Gasto')
      - descripcion (TEXT)
      - monto (REAL)
      - categoria (TEXT)
      - created_at (TIMESTAMP)

      Traduce la siguiente pregunta a SQL: "$naturalLanguageQuery"

      Devuelve SOLO la consulta SQL, sin explicaciones ni texto adicional.
      """;

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Error al traducir a SQL: $e');
    }
  }
}