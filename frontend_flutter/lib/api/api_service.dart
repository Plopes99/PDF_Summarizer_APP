import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> uploadPdf(String filePath) async {
    var request = MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.files.add(await MultipartFile.fromPath('file', filePath));
    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      print('Upload Response: $responseData');
      return json.decode(responseData);
    } else {
      print('Erro ao carregar o PDF: ${response.statusCode}');
      throw Exception('Erro ao carregar o PDF');
    }
  }

  Future<Map<String, dynamic>> askQuestions(String fileId, List<String> questions) async {
    var response = await http.post(
      Uri.parse('$baseUrl/questions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'file_id': fileId, 'questions': questions}),
    );

    if (response.statusCode == 200) {
      print('Questions Response: ${response.body}');
      return json.decode(response.body);
    } else {
      print('Erro ao fazer perguntas: ${response.statusCode}');
      throw Exception('Erro ao fazer perguntas');
    }
  }
}

