import 'package:flutter/material.dart';
import '../models/answer.dart';

class AnswerButton extends StatelessWidget {
  final Answer answer;
  final VoidCallback onTap;

  const AnswerButton({super.key, required this.answer, required this.onTap});

  Color get _color {
    switch (answer) {
      case Answer.sim:
        return const Color(0xFF2E7D32);
      case Answer.provavelmenteSim:
        return const Color(0xFF558B2F);
      case Answer.naoSei:
        return const Color(0xFF6A1B9A);
      case Answer.provavelmenteNao:
        return const Color(0xFFBF360C);
      case Answer.nao:
        return const Color(0xFFB71C1C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 4,
          ),
          child: Text(
            answer.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
