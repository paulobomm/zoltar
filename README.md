# Zoltar

Projeto Flutter inspirado no Akinator, mas voltado para adivinhar professores da faculdade a partir de perguntas.

## Pre-requisitos

- Flutter instalado
- Dart instalado junto com o Flutter
- Android Studio, emulador Android ou navegador para rodar a versao web

Para conferir se o ambiente esta pronto:

```bash
flutter doctor
```

## Como rodar o projeto

Entre na pasta do projeto:

```bash
cd zoltar
```

Instale as dependencias:

```bash
flutter pub get
```

Veja os dispositivos disponiveis:

```bash
flutter devices
```

Rode o app:

```bash
flutter run
```

Para rodar em um dispositivo especifico, use o id exibido pelo `flutter devices`:

```bash
flutter run -d <id-do-dispositivo>
```

Exemplo para rodar no navegador Chrome:

```bash
flutter run -d chrome
```

Exemplo para rodar como aplicativo Linux desktop:

```bash
flutter run -d linux
```

Se esse comando tentar usar `/snap/flutter/...`, corrija o `PATH` seguindo a secao [Erro do Ninja ao rodar no Linux](#erro-do-ninja-ao-rodar-no-linux).

## Comandos uteis

Analisar o codigo:

```bash
flutter analyze
```

Rodar os testes:

```bash
flutter test
```

Formatar o codigo:

```bash
dart format .
```

Limpar arquivos gerados de build:

```bash
flutter clean
```

Depois do `flutter clean`, rode novamente:

```bash
flutter pub get
```

## Modelagem e Lógica

### Modelos de dados

**`Professor`** — representa cada professor com nome, disciplina, imagem e um mapa de `traits` (características). Cada trait é um número de `0.0` a `1.0`, onde `1.0 = definitivamente tem essa característica` e `0.0 = definitivamente não tem`.

**`Question`** — possui um `id` (ex: `'tem_barba'`) e o texto da pergunta. O `id` é a chave que conecta a pergunta ao trait correspondente de cada professor.

**`Answer`** — enum com 5 valores, cada um com um `weight` (peso) numérico:

| Resposta | Peso |
|---|---|
| Sim | +1.0 |
| Provavelmente sim | +0.6 |
| Não sei | 0.0 |
| Provavelmente não | −0.6 |
| Não | −1.0 |

---

### Lógica do GameEngine

O núcleo é um sistema de **pontuação por acumulação**. Cada professor começa com score `0.0` e as respostas vão somando ou subtraindo pontos.

**1. Como uma resposta afeta os scores**

Para cada resposta, percorre todos os 15 professores e aplica a fórmula:

```
score += (trait - 0.5) × weight × 2
```

O `trait - 0.5` centraliza o valor em zero: um professor com `trait = 1.0` vira `+0.5`, com `trait = 0.0` vira `-0.5`. Multiplicar pelo `weight` da resposta e por 2 significa:

- Respondeu **"Sim"** para "tem barba": quem tem barba (`trait=1.0`) ganha `+1.0`, quem não tem (`trait=0.0`) perde `-1.0`.
- Respondeu **"Não sei"** (`weight=0.0`): nenhum professor é afetado.

**2. Como escolhe a próxima pergunta**

Em vez de ordem fixa, o engine escolhe a pergunta que mais **discrimina** os professores candidatos usando uma métrica de variância ponderada. Perguntas que dividem os candidatos em dois grupos bem separados recebem score alto e são priorizadas — parecido com uma árvore de decisão adaptativa.

**3. Quando parar**

O engine para e chuta quando:
- Não há mais perguntas, **ou**
- O primeiro colocado tem vantagem de mais de 3 pontos sobre o segundo **e** já foram feitas pelo menos 5 perguntas.

**4. Resultado**

Ordena os scores e retorna o `Professor` com maior pontuação acumulada.

---

### Fluxo geral

```
HomeScreen
    ↓ [Começar]
QuestionScreen
    → GameEngine escolhe pergunta mais discriminante
    → usuário responde → scores atualizados
    → repete até shouldGuess == true
    ↓
ResultScreen
    → exibe topGuess (professor com maior score)
    → usuário confirma acerto/erro
    ↓ [Jogar novamente]
HomeScreen
```

A ordem das perguntas muda a cada jogo com base nos scores acumulados, tornando o comportamento dinâmico e mais próximo de um Akinator real.

---

## Problemas comuns

### Erro do Ninja ao rodar no Linux

Se ao escolher a opcao `Linux` aparecer um erro parecido com:

```text
'/snap/flutter/current/usr/bin/ninja' '--version'
failed with:
no such file or directory
```

o terminal provavelmente esta usando o Flutter instalado via Snap. Use o Flutter instalado na pasta do usuario:

```bash
/home/paulo-roberto-bomm/flutter/bin/flutter run -d linux
```

Ou ajuste o `PATH` para priorizar esse Flutter no terminal atual:

```bash
export PATH="$HOME/flutter/bin:$PATH"
hash -r
```

Depois confira:

```bash
which flutter
flutter doctor
```

O `which flutter` precisa mostrar:

```text
/home/paulo-roberto-bomm/flutter/bin/flutter
```

Depois disso, rode:

```bash
flutter clean
flutter pub get
flutter run -d linux
```

Para salvar essa configuracao para novos terminais:

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
hash -r
```

Se o erro continuar mesmo com o `which flutter` correto, limpe o cache antigo do build Linux:

```bash
/home/paulo-roberto-bomm/flutter/bin/flutter clean
/home/paulo-roberto-bomm/flutter/bin/flutter pub get
/home/paulo-roberto-bomm/flutter/bin/flutter run -d linux
```

Se quiser apenas rodar rapidamente sem depender do build Linux desktop, use o Chrome:

```bash
flutter run -d chrome
```
