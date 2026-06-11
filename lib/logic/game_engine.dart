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
  final Random _random;

  GameEngine({Random? random}) : _random = random ?? Random() {
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

    final scoredQuestions =
        _remainingQuestions.map((q) => MapEntry(q, _questionScore(q))).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final bestScore = scoredQuestions.first.value;
    final goodOptions =
        scoredQuestions
            .where((entry) => entry.value >= bestScore * 0.9)
            .take(4)
            .map((entry) => entry.key)
            .toList()
          ..shuffle(_random);

    final question = goodOptions.first;
    _remainingQuestions.remove(question);
    _askedQuestions.add(question);
    return question;
  }

  void recordAnswer(Question question, Answer answer) {
    for (final professor in _professors) {
      final trait = professor.traitFor(question.id);
      // trait is 0..1; centre it at 0 → -0.5..0.5
      final centredTrait = trait - 0.5;
      _scores[professor.name] =
          (_scores[professor.name] ?? 0) + centredTrait * answer.weight * 2;
    }
  }

  int get questionsAsked => _askedQuestions.length;

  double _questionScore(Question question) {
    final weights = _candidateWeights();
    var weightedMean = 0.0;

    for (final professor in _professors) {
      weightedMean +=
          weights[professor.name]! * professor.traitFor(question.id);
    }

    var weightedVariance = 0.0;
    for (final professor in _professors) {
      final distance = professor.traitFor(question.id) - weightedMean;
      weightedVariance += weights[professor.name]! * distance * distance;
    }

    final splitBalance = 1 - (weightedMean - 0.5).abs() * 2;
    final certainty = (weightedMean - 0.5).abs() * 2;

    return weightedVariance * 0.7 + splitBalance * 0.25 + certainty * 0.05;
  }

  Map<String, double> _candidateWeights() {
    if (_askedQuestions.isEmpty) {
      final equalWeight = 1 / _professors.length;
      return {for (final professor in _professors) professor.name: equalWeight};
    }

    final topScore = _scores.values.reduce(max);
    final rawWeights = <String, double>{};
    var total = 0.0;

    for (final professor in _professors) {
      final score = _scores[professor.name] ?? 0.0;
      final weight = exp(score - topScore);
      rawWeights[professor.name] = weight;
      total += weight;
    }

    return rawWeights.map((name, weight) => MapEntry(name, weight / total));
  }
}
