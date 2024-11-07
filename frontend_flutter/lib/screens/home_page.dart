import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../api/api_service.dart';
import '../widgets/question_widget.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService(baseUrl: 'http://localhost:3000');
  String? fileId;
  String? summary;
  List<String> questions = [];
  Map<String, dynamic>? answers;
  TextEditingController questionController = TextEditingController();
  bool isLoading = false;
  bool isPdfLoaded = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void _pickFile() async {
    setState(() {
      isLoading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      String filePath = result.files.single.path!;
      try {
        var response = await apiService.uploadPdf(filePath);
        setState(() {
          fileId = response['file_id'];
          summary = response['summary'];
          isPdfLoaded = true;
        });
      } catch (e) {
        _showErrorDialog('Erro ao carregar o PDF. Por favor, tente novamente.');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addQuestion() {
    String question = questionController.text;
    if (question.isNotEmpty) {
      setState(() {
        questions.add(question);
        questionController.clear();
      });
    }
  }

  void _removeQuestion(int index) {
    setState(() {
      questions.removeAt(index);
    });
  }

  void _askQuestions() async {
    setState(() {
      isLoading = true;
    });
    if (fileId != null && questions.isNotEmpty) {
      try {
        var response = await apiService.askQuestions(fileId!, questions);
        setState(() {
          answers = response['details'];
        });
      } catch (e) {
        _showErrorDialog('Erro ao fazer perguntas. Por favor, tente novamente.');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _createNewChat() {
    setState(() {
      fileId = null;
      summary = null;
      questions.clear();
      answers = null;
      questionController.clear();
      isPdfLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sumarizador de PDFs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: _createNewChat,
            tooltip: 'Criar Novo Chat',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: Icon(Icons.upload_file),
                label: Text('Carregar PDF'),
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 18,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
              SizedBox(height: 20),
              if (isLoading) CircularProgressIndicator(),
              if (summary != null && !isLoading) ...[
                Text(
                  'Resumo:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(summary!),
                SizedBox(height: 20),
              ],
              if (isPdfLoaded && !isLoading) ...[
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Pergunta',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addQuestion,
                  child: Text('Adicionar Pergunta'),
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 18,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                ),
                SizedBox(height: 20),
                if (questions.isNotEmpty) ...[
                  Text(
                    'Perguntas adicionadas:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(questions[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeQuestion(index),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: questions.isNotEmpty ? _askQuestions : null,
                  child: Text('Fazer Perguntas'),
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 18,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                ),
                if (answers != null) ...[
                  SizedBox(height: 20),
                  Text(
                    'Respostas:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  ...answers!.entries.map((entry) => QuestionWidget(
                    question: entry.key,
                    answer: entry.value.toString(),
                  )).toList(),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
