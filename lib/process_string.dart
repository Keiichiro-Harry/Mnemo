String processString(String input) {
  List<String> splittedText = input.split('');
  List removed = [];
  // "("と")"で囲まれる部分を削除
  bool mightInParen = false;
  int startParen = 0;
  for (int i = 0; i < splittedText.length; i++) {
    if (splittedText[i] == '(') {
      mightInParen = true;
      startParen = i;
    } else if (splittedText[i] == ')') {
      mightInParen = false;
      startParen = 0;
    } else if (!mightInParen) {
      removed.add(splittedText[i]);
    }
  }
  if (mightInParen) {
    for (int i = startParen + 1; i < splittedText.length; i++) {
      //'('で終わったら一回も入らないだけでエラーは起きない
      removed.add(splittedText[i]);
    }
  }
  // "["と"]"を削除
  List<String> removedBrackets = [];
  for (var character in removed) {
    if (character != "[" && character != "]") {
      removedBrackets.add(character);
    }
  }
  //配列を連結して文字列にし、 "/"を改行に置換
  String result = removedBrackets.join().replaceAll(RegExp(r'/'), '\n');
  return result;
}
