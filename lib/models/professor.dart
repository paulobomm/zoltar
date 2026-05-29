class Professor {
  final String name;
  final String discipline;
  final String imagePath;
  // trait values: 1.0 = yes, 0.0 = no, 0.5 = uncertain
  final Map<String, double> traits;

  const Professor({
    required this.name,
    required this.discipline,
    required this.imagePath,
    required this.traits,
  });

  double traitFor(String questionId) => traits[questionId] ?? 0.5;
}
