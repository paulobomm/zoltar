import 'dart:math';
import '../models/answer.dart';
import '../models/professor.dart';
import '../models/question.dart';
import '../data/professors_data.dart';
import '../data/questions_data.dart';

class GameEngine {
  final List<Professor> _professors = List.from(allProfessors);
  final List<Question> _remainingQuestions = List.from(allQuestions);
  final Map<String, double> _scores = {};
  final List<Question> _askedQuestions = [];
  final int _maxQuestions = 10;
  final Random _random = Random();

  GameEngine() {
    _remainingQuestions.shuffle();
    for (final p in _professors) {
      _scores[p.name] = 0.0;
    }
  }

  bool get hasMoreQuestions =>
      _remainingQuestions.isNotEmpty && _askedQuestions.length < _maxQuestions;

  bool get shouldGuess {
    if (_askedQuestions.isEmpty) return false;
    if (!hasMoreQuestions) return true;
    final sorted = sortedProfessors;
    if (sorted.length < 2) return true;
    // guess if top candidate leads by a large margin after enough questions
    final diff = sorted[0].value - sorted[1].value;
    return diff > 3.0 && _askedQuestions.length >= 5;
  }

  List<MapEntry<String, double>> get sortedProfessors {
    final entries = _scores.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  Professor get topGuess {
    final top = sortedProfessors.first;
    return _professors.firstWhere((p) => p.name == top.key);
  }

  Question nextQuestion() {
    if (_remainingQuestions.isEmpty) throw StateError('No questions left');

    if (_askedQuestions.isEmpty) {
      // start with the most discriminating question overall
      final q = _remainingQuestions.removeAt(0);
      _askedQuestions.add(q);
      return q;
    }

    // Pick the question that maximises variance across current top-5 candidates
    final top5 = sortedProfessors.take(5).map((e) => e.key).toSet();
    final topProfessors = _professors.where((p) => top5.contains(p.name)).toList();

    Question best = _remainingQuestions.first;
    double bestVariance = -1;

    for (final q in _remainingQuestions) {
      final values = topProfessors.map((p) => p.traitFor(q.id)).toList();
      // small random jitter breaks ties so equal-variance questions rotate
      final variance = _variance(values) + _random.nextDouble() * 0.01;
      if (variance > bestVariance) {
        bestVariance = variance;
        best = q;
      }
    }

    _remainingQuestions.remove(best);
    _askedQuestions.add(best);
    return best;
  }

  void recordAnswer(Question question, Answer answer) {
    for (final professor in _professors) {
      final trait = professor.traitFor(question.id);
      // trait is 0..1; centre it at 0 → -0.5..0.5
      final centredTrait = trait - 0.5;
      _scores[professor.name] = (_scores[professor.name] ?? 0) +
          centredTrait * answer.weight * 2;
    }
  }

  int get questionsAsked => _askedQuestions.length;

  double _variance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final sq = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b);
    return sq / values.length;
  }
}
