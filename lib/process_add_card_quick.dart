class Quiz {
  String question;
  String answer;
  String comment;

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'comment': comment,
    };
  }

  Quiz(
    this.question,
    this.answer,
    this.comment,
  );
}

Future<List<Map>> getData(String original) async {
  List<Map> quizList = [];
  List<String> lines = original.split("\n");

  for (String line in lines) {
    //print("here0");
    if (quizList.length == original.split("\n").length) {
      //ここquiz.length+1にしてたら最後改行必須みたいになる
      break;
    }
    List<String> parts = line.split(':');
    List<String> rows = [];
    //print("here1");

    if (parts.length == 2) {
      rows.add(parts[0].trim());
      rows.add(parts[1].trim());
      rows.add("");
    } else if (parts.length == 3) {
      rows.add(parts[0].trim());
      rows.add(parts[1].trim());
      rows.add(parts[2].trim());
    } else {
      // エラー処理：コロンの数が0個または3個以上の場合
      throw FormatException("Invalid input format: $line");
    }
    //print("here2");

    final disallowedChars = ['<', '>', '&', '"', "'", '\\', '='];
    for (int i = 0; i < rows.length; i++) {
      rows[i] = rows[i].replaceAll(RegExp(disallowedChars.join('|')), '');
    }
    //print("here3");
    bool inParentheses = false;
    bool inBrackets = false;
    List<String> splittedAnswer = rows[1].split('');
    List<String> ckets = ['(', ')', '[', ']'];
    for (int i = 0; i < splittedAnswer.length; i++) {
      if (ckets.contains(splittedAnswer[i])) {
        if (splittedAnswer[i] == '(' && !inParentheses && !inBrackets) {
          inParentheses = true;
        } else if (splittedAnswer[i] == '[' && !inParentheses && !inBrackets) {
          inBrackets = true;
        } else if (splittedAnswer[i] == ')' && inParentheses) {
          inParentheses = false;
        } else if (splittedAnswer[i] == ']' && inBrackets) {
          inBrackets = false;
        } else {
          throw FormatException("Invalid answer format: $line");
        }
      }
    }
    if (!inParentheses && !inBrackets) {
      Quiz quiz = Quiz(rows[0], rows[1], rows[2]);
      quizList.add(quiz.toMap());
    }else{
      throw FormatException("Invalid answer format: $line");
    }
    //print("here4");
  }
  //print("here4");
  return quizList;
}
