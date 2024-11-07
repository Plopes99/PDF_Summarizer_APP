import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final String question;
  final String answer;

  QuestionWidget({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pergunta: $question', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Resposta: $answer'),
          Divider(),
        ],
      ),
    );
  }
}
