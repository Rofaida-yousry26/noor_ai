import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static const Duration timeout = Duration(seconds: 60);

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static dynamic _decodeJson(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed: ${response.statusCode}';

      try {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded is Map && decoded['detail'] != null) {
          message = decoded['detail'].toString();
        }
      } catch (_) {
        // Keep the default error message.
      }

      throw Exception(message);
    }

    if (response.bodyBytes.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw Exception('The server returned an invalid response.');
    }
  }

  static Map<String, dynamic> _decodeMap(http.Response response) {
    final decoded = _decodeJson(response);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected response format.');
    }

    return decoded;
  }

  // Test the backend connection.
  static Future<Map<String, dynamic>> checkConnection() async {
    final response = await http
        .get(_uri('/hello'))
        .timeout(timeout);

    return _decodeMap(response);
  }

  // Upload a PDF document.
  static Future<Map<String, dynamic>> uploadPdf(
    String filePath, {
    bool forceOcr = false,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/upload'),
    );

    request.fields['force_ocr'] = forceOcr.toString();

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType('application', 'pdf'),
      ),
    );

    final streamedResponse = await request.send().timeout(timeout);

    final response = await http.Response.fromStream(streamedResponse);

    return _decodeMap(response);
  }

  // Get uploaded documents.
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    final response = await http
        .get(_uri('/documents'))
        .timeout(timeout);

    final decoded = _decodeJson(response);

    if (decoded is! List) {
      throw Exception('Expected a list of documents from the server.');
    }

    return decoded.map((item) {
      if (item is! Map) {
        throw Exception('Invalid document data received.');
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }

  // Delete a document.
  static Future<void> deleteDocument(String filename) async {
    final encodedFilename = Uri.encodeComponent(filename);

    final response = await http
        .delete(_uri('/documents/$encodedFilename'))
        .timeout(timeout);

    _decodeJson(response);
  }

  // Ask the AI about uploaded documents.
 static Future<Map<String, dynamic>> askQuestion({
  required String question,
  String answerLanguage = 'auto',
  String? document,
}) async {
  final body = <String, dynamic>{
    'question': question,
    'answer_language': answerLanguage,
  };

  if (document != null && document.isNotEmpty) {
    body['document'] = document;
  }

  final uri = _uri('/ask');

  print('Sending question to: $uri');
  print('Question: $question');

  try {
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(minutes: 3));

    print('Ask API status: ${response.statusCode}');
    print('Ask API response: ${response.body}');

    return _decodeMap(response);
  } catch (error) {
    print('Ask API error: $error');
    rethrow;
  }
}
}