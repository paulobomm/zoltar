enum Answer {
  sim,
  nao,
  naoSei,
  provavelmenteSim,
  provavelmenteNao;

  String get label {
    switch (this) {
      case Answer.sim:
        return 'Sim';
      case Answer.nao:
        return 'Não';
      case Answer.naoSei:
        return 'Não sei';
      case Answer.provavelmenteSim:
        return 'Provavelmente sim';
      case Answer.provavelmenteNao:
        return 'Provavelmente não';
    }
  }

  double get weight {
    switch (this) {
      case Answer.sim:
        return 1.0;
      case Answer.provavelmenteSim:
        return 0.6;
      case Answer.naoSei:
        return 0.0;
      case Answer.provavelmenteNao:
        return -0.6;
      case Answer.nao:
        return -1.0;
    }
  }
}
