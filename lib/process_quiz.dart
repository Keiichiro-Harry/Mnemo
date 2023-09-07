import 'dart:math' as math;
class Quiz {
  // String question;
  List<List<dynamic>> splittedAnswer = [];
  List<List<List<dynamic>>> selectionsAndAnswer = [];
  // String answerAll;
  List<List<int>> answerIndex = [];
  Quiz(
    this.splittedAnswer,
  );

  // List<String> select1 = [];
  // List<String> select2 = [];
  // List<String> select3 = [];
  // List<List<String>> selection;
  List<String> hiragana = [
    'あ',
    'い',
    'う',
    'え',
    'お',
    'か',
    'き',
    'く',
    'け',
    'こ',
    'さ',
    'し',
    'す',
    'せ',
    'そ',
    'た',
    'ち',
    'つ',
    'て',
    'と',
    'な',
    'に',
    'ぬ',
    'ね',
    'の',
    'は',
    'ひ',
    'ふ',
    'へ',
    'ほ',
    'ま',
    'み',
    'む',
    'め',
    'も',
    'や',
    'ゆ',
    'よ',
    'ら',
    'り',
    'る',
    'れ',
    'ろ',
    'わ',
    'を',
    'ん',
    'が',
    'ぎ',
    'ぐ',
    'げ',
    'ご',
    'ざ',
    'じ',
    'ず',
    'ぜ',
    'ぞ',
    'だ',
    'ぢ',
    'づ',
    'で',
    'ど',
    'ば',
    'び',
    'ぶ',
    'べ',
    'ぼ',
    'ぱ',
    'ぴ',
    'ぷ',
    'ぺ',
    'ぽ',
    'ぁ',
    'ぃ',
    'ぅ',
    'ぇ',
    'ぉ',
    'っ',
    'ゃ',
    'ゅ',
    'ょ',
  //  '、',
  //  '。'
  ]; //80こ
  List<String> katakana = [
    'ア',
    'イ',
    'ウ',
    'エ',
    'オ',
    'カ',
    'キ',
    'ク',
    'ケ',
    'コ',
    'サ',
    'シ',
    'ス',
    'セ',
    'ソ',
    'タ',
    'チ',
    'ツ',
    'テ',
    'ト',
    'ナ',
    'ニ',
    'ヌ',
    'ネ',
    'ノ',
    'ハ',
    'ヒ',
    'フ',
    'ヘ',
    'ホ',
    'マ',
    'ミ',
    'ム',
    'メ',
    'モ',
    'ヤ',
    'ユ',
    'ヨ',
    'ラ',
    'リ',
    'ル',
    'レ',
    'ロ',
    'ワ',
    'ヲ',
    'ン',
    'ガ',
    'ギ',
    'グ',
    'ゲ',
    'ゴ',
    'ザ',
    'ジ',
    'ズ',
    'ゼ',
    'ゾ',
    'ダ',
    'ヂ',
    'ヅ',
    'デ',
    'ド',
    'バ',
    'ビ',
    'ブ',
    'ベ',
    'ボ',
    'パ',
    'ピ',
    'プ',
    'ペ',
    'ポ',
    'ァ',
    'ィ',
    'ゥ',
    'ェ',
    'ォ',
    'ッ',
    'ャ',
    'ュ',
    'ョ',
  ]; //80こ
  List<String> alphabetSmall = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
    //',',
    //'.'
  ]; //26こ
  List<String> alphabetCapital = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ]; //26こ
  List<String> number = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ]; //10こ
  //ここ、後で削って復活みたいなの繰り返してるけど、バックアップ用でhiragana_subとか作って元に戻した方が後の無駄な行数減らせる

  // List<List<List<dynamic>>> toMap(List<List<dynamic>> splittedAnswer) {
  List<List<List<dynamic>>> toMap() {
    List<List<List<dynamic>>> select = []; //これは問題ごとの選択肢群をまとめて、ゲームの選択肢群(3次元)
    List<dynamic> selectProgress1 = []; //これは文字ごとの選択肢(1次元)
    List<List<dynamic>> selectProgress2 = []; //これは文字ごとの選択肢をまとめて、問題ごとの選択肢群(2次元)
    List<int> answerIndexProgress = [];
   //print("splittedAnswer$splittedAnswer");
    // print("OKquiz1");
    for (var a = 0; a < splittedAnswer.length; a++) {
      // print(splittedAnswer);
      selectProgress2 = [];
      answerIndexProgress = [];
      int count = 0;
      bool inParentheses = false;
      bool inBrackets = false;
      for (var b = 0; b < splittedAnswer[a].length; b++) {
        if (splittedAnswer[a][b] == '(') {
          inParentheses = true;
          continue;
        } else if (splittedAnswer[a][b] == '[') {
          inBrackets = true;
          continue;
        } else if (splittedAnswer[a][b] == ')' && inParentheses) {
          inParentheses = false;
          continue;
        } else if (splittedAnswer[a][b] == ']' && inBrackets) {
          inBrackets = false;
          continue;
        } else if (inParentheses || inBrackets) {
          count++;
        } else {
          continue;
        }
       //print("a:$a");
       //print("b:$b");
        // print("OKquiz2");
        if (splittedAnswer[a][b] == 'あ' ||
            splittedAnswer[a][b] == 'い' ||
            splittedAnswer[a][b] == 'う' ||
            splittedAnswer[a][b] == 'え' ||
            splittedAnswer[a][b] == 'お' ||
            splittedAnswer[a][b] == 'か' ||
            splittedAnswer[a][b] == 'き' ||
            splittedAnswer[a][b] == 'く' ||
            splittedAnswer[a][b] == 'け' ||
            splittedAnswer[a][b] == 'こ' ||
            splittedAnswer[a][b] == 'さ' ||
            splittedAnswer[a][b] == 'し' ||
            splittedAnswer[a][b] == 'す' ||
            splittedAnswer[a][b] == 'せ' ||
            splittedAnswer[a][b] == 'そ' ||
            splittedAnswer[a][b] == 'た' ||
            splittedAnswer[a][b] == 'ち' ||
            splittedAnswer[a][b] == 'つ' ||
            splittedAnswer[a][b] == 'て' ||
            splittedAnswer[a][b] == 'と' ||
            splittedAnswer[a][b] == 'な' ||
            splittedAnswer[a][b] == 'に' ||
            splittedAnswer[a][b] == 'ぬ' ||
            splittedAnswer[a][b] == 'ね' ||
            splittedAnswer[a][b] == 'の' ||
            splittedAnswer[a][b] == 'は' ||
            splittedAnswer[a][b] == 'ひ' ||
            splittedAnswer[a][b] == 'ふ' ||
            splittedAnswer[a][b] == 'へ' ||
            splittedAnswer[a][b] == 'ほ' ||
            splittedAnswer[a][b] == 'ま' ||
            splittedAnswer[a][b] == 'み' ||
            splittedAnswer[a][b] == 'む' ||
            splittedAnswer[a][b] == 'め' ||
            splittedAnswer[a][b] == 'も' ||
            splittedAnswer[a][b] == 'や' ||
            splittedAnswer[a][b] == 'ゆ' ||
            splittedAnswer[a][b] == 'よ' ||
            splittedAnswer[a][b] == 'ら' ||
            splittedAnswer[a][b] == 'り' ||
            splittedAnswer[a][b] == 'る' ||
            splittedAnswer[a][b] == 'れ' ||
            splittedAnswer[a][b] == 'ろ' ||
            splittedAnswer[a][b] == 'わ' ||
            splittedAnswer[a][b] == 'を' ||
            splittedAnswer[a][b] == 'ん' ||
            splittedAnswer[a][b] == 'が' ||
            splittedAnswer[a][b] == 'ぎ' ||
            splittedAnswer[a][b] == 'ぐ' ||
            splittedAnswer[a][b] == 'げ' ||
            splittedAnswer[a][b] == 'ご' ||
            splittedAnswer[a][b] == 'ざ' ||
            splittedAnswer[a][b] == 'じ' ||
            splittedAnswer[a][b] == 'ず' ||
            splittedAnswer[a][b] == 'ぜ' ||
            splittedAnswer[a][b] == 'ぞ' ||
            splittedAnswer[a][b] == 'だ' ||
            splittedAnswer[a][b] == 'ぢ' ||
            splittedAnswer[a][b] == 'づ' ||
            splittedAnswer[a][b] == 'で' ||
            splittedAnswer[a][b] == 'ど' ||
            splittedAnswer[a][b] == 'ば' ||
            splittedAnswer[a][b] == 'び' ||
            splittedAnswer[a][b] == 'ぶ' ||
            splittedAnswer[a][b] == 'べ' ||
            splittedAnswer[a][b] == 'ぼ' ||
            splittedAnswer[a][b] == 'ぱ' ||
            splittedAnswer[a][b] == 'ぴ' ||
            splittedAnswer[a][b] == 'ぷ' ||
            splittedAnswer[a][b] == 'ぺ' ||
            splittedAnswer[a][b] == 'ぽ' ||
            splittedAnswer[a][b] == 'ぁ' ||
            splittedAnswer[a][b] == 'ぃ' ||
            splittedAnswer[a][b] == 'ぅ' ||
            splittedAnswer[a][b] == 'ぇ' ||
            splittedAnswer[a][b] == 'ぉ' ||
            splittedAnswer[a][b] == 'っ' ||
            splittedAnswer[a][b] == 'ゃ' ||
            splittedAnswer[a][b] == 'ゅ' ||
            splittedAnswer[a][b] == 'ょ'){
            //splittedAnswer[a][b] == '、' ||
            //splittedAnswer[a][b] == '。') 
          var rand = math.Random();
          // print("OKquiz3");
          hiragana.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
           //print("i:$i");
            int randomNumber = rand.nextInt(79 - i);
            selectProgress1.add(hiragana[randomNumber]);
            hiragana.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);

          hiragana = [
            'あ',
            'い',
            'う',
            'え',
            'お',
            'か',
            'き',
            'く',
            'け',
            'こ',
            'さ',
            'し',
            'す',
            'せ',
            'そ',
            'た',
            'ち',
            'つ',
            'て',
            'と',
            'な',
            'に',
            'ぬ',
            'ね',
            'の',
            'は',
            'ひ',
            'ふ',
            'へ',
            'ほ',
            'ま',
            'み',
            'む',
            'め',
            'も',
            'や',
            'ゆ',
            'よ',
            'ら',
            'り',
            'る',
            'れ',
            'ろ',
            'わ',
            'を',
            'ん',
            'が',
            'ぎ',
            'ぐ',
            'げ',
            'ご',
            'ざ',
            'じ',
            'ず',
            'ぜ',
            'ぞ',
            'だ',
            'ぢ',
            'づ',
            'で',
            'ど',
            'ば',
            'び',
            'ぶ',
            'べ',
            'ぼ',
            'ぱ',
            'ぴ',
            'ぷ',
            'ぺ',
            'ぽ',
            'ぁ',
            'ぃ',
            'ぅ',
            'ぇ',
            'ぉ',
            'っ',
            'ゃ',
            'ゅ',
            'ょ',
            // '、',
            // '。'
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
          // select[a][b][answerIndex[answerIndex.length - 1]].add(letter);
        } else if (splittedAnswer[a][b] == 'ア' ||
            splittedAnswer[a][b] == 'イ' ||
            splittedAnswer[a][b] == 'ウ' ||
            splittedAnswer[a][b] == 'エ' ||
            splittedAnswer[a][b] == 'オ' ||
            splittedAnswer[a][b] == 'カ' ||
            splittedAnswer[a][b] == 'キ' ||
            splittedAnswer[a][b] == 'ク' ||
            splittedAnswer[a][b] == 'ケ' ||
            splittedAnswer[a][b] == 'コ' ||
            splittedAnswer[a][b] == 'サ' ||
            splittedAnswer[a][b] == 'シ' ||
            splittedAnswer[a][b] == 'ス' ||
            splittedAnswer[a][b] == 'セ' ||
            splittedAnswer[a][b] == 'ソ' ||
            splittedAnswer[a][b] == 'タ' ||
            splittedAnswer[a][b] == 'チ' ||
            splittedAnswer[a][b] == 'ツ' ||
            splittedAnswer[a][b] == 'テ' ||
            splittedAnswer[a][b] == 'ト' ||
            splittedAnswer[a][b] == 'ナ' ||
            splittedAnswer[a][b] == 'ニ' ||
            splittedAnswer[a][b] == 'ヌ' ||
            splittedAnswer[a][b] == 'ネ' ||
            splittedAnswer[a][b] == 'ノ' ||
            splittedAnswer[a][b] == 'ハ' ||
            splittedAnswer[a][b] == 'ヒ' ||
            splittedAnswer[a][b] == 'フ' ||
            splittedAnswer[a][b] == 'ヘ' ||
            splittedAnswer[a][b] == 'ホ' ||
            splittedAnswer[a][b] == 'マ' ||
            splittedAnswer[a][b] == 'ミ' ||
            splittedAnswer[a][b] == 'ム' ||
            splittedAnswer[a][b] == 'メ' ||
            splittedAnswer[a][b] == 'モ' ||
            splittedAnswer[a][b] == 'ヤ' ||
            splittedAnswer[a][b] == 'ユ' ||
            splittedAnswer[a][b] == 'ヨ' ||
            splittedAnswer[a][b] == 'ラ' ||
            splittedAnswer[a][b] == 'リ' ||
            splittedAnswer[a][b] == 'ル' ||
            splittedAnswer[a][b] == 'レ' ||
            splittedAnswer[a][b] == 'ロ' ||
            splittedAnswer[a][b] == 'ワ' ||
            splittedAnswer[a][b] == 'ヲ' ||
            splittedAnswer[a][b] == 'ン' ||
            splittedAnswer[a][b] == 'ガ' ||
            splittedAnswer[a][b] == 'ギ' ||
            splittedAnswer[a][b] == 'グ' ||
            splittedAnswer[a][b] == 'ゲ' ||
            splittedAnswer[a][b] == 'ゴ' ||
            splittedAnswer[a][b] == 'ザ' ||
            splittedAnswer[a][b] == 'ジ' ||
            splittedAnswer[a][b] == 'ズ' ||
            splittedAnswer[a][b] == 'ゼ' ||
            splittedAnswer[a][b] == 'ゾ' ||
            splittedAnswer[a][b] == 'ダ' ||
            splittedAnswer[a][b] == 'ヂ' ||
            splittedAnswer[a][b] == 'ヅ' ||
            splittedAnswer[a][b] == 'デ' ||
            splittedAnswer[a][b] == 'ド' ||
            splittedAnswer[a][b] == 'バ' ||
            splittedAnswer[a][b] == 'ビ' ||
            splittedAnswer[a][b] == 'ブ' ||
            splittedAnswer[a][b] == 'ベ' ||
            splittedAnswer[a][b] == 'ボ' ||
            splittedAnswer[a][b] == 'パ' ||
            splittedAnswer[a][b] == 'ピ' ||
            splittedAnswer[a][b] == 'プ' ||
            splittedAnswer[a][b] == 'ペ' ||
            splittedAnswer[a][b] == 'ポ' ||
            splittedAnswer[a][b] == 'ァ' ||
            splittedAnswer[a][b] == 'ィ' ||
            splittedAnswer[a][b] == 'ゥ' ||
            splittedAnswer[a][b] == 'ェ' ||
            splittedAnswer[a][b] == 'ォ' ||
            splittedAnswer[a][b] == 'ッ' ||
            splittedAnswer[a][b] == 'ャ' ||
            splittedAnswer[a][b] == 'ュ' ||
            splittedAnswer[a][b] == 'ョ') {
          var rand = math.Random();
          // print("OKquiz3");
          katakana.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(79 - i);
            selectProgress1.add(katakana[randomNumber]);
            katakana.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);
          katakana = [
            'ア',
            'イ',
            'ウ',
            'エ',
            'オ',
            'カ',
            'キ',
            'ク',
            'ケ',
            'コ',
            'サ',
            'シ',
            'ス',
            'セ',
            'ソ',
            'タ',
            'チ',
            'ツ',
            'テ',
            'ト',
            'ナ',
            'ニ',
            'ヌ',
            'ネ',
            'ノ',
            'ハ',
            'ヒ',
            'フ',
            'ヘ',
            'ホ',
            'マ',
            'ミ',
            'ム',
            'メ',
            'モ',
            'ヤ',
            'ユ',
            'ヨ',
            'ラ',
            'リ',
            'ル',
            'レ',
            'ロ',
            'ワ',
            'ヲ',
            'ン',
            'ガ',
            'ギ',
            'グ',
            'ゲ',
            'ゴ',
            'ザ',
            'ジ',
            'ズ',
            'ゼ',
            'ゾ',
            'ダ',
            'ヂ',
            'ヅ',
            'デ',
            'ド',
            'バ',
            'ビ',
            'ブ',
            'ベ',
            'ボ',
            'パ',
            'ピ',
            'プ',
            'ペ',
            'ポ',
            'ァ',
            'ィ',
            'ゥ',
            'ェ',
            'ォ',
            'ッ',
            'ャ',
            'ュ',
            'ョ',
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
          // select[answerIndex[answerIndex.length - 1]].add(letter);
        } else if (splittedAnswer[a][b] == 'a' ||
            splittedAnswer[a][b] == 'b' ||
            splittedAnswer[a][b] == 'c' ||
            splittedAnswer[a][b] == 'd' ||
            splittedAnswer[a][b] == 'e' ||
            splittedAnswer[a][b] == 'f' ||
            splittedAnswer[a][b] == 'g' ||
            splittedAnswer[a][b] == 'h' ||
            splittedAnswer[a][b] == 'i' ||
            splittedAnswer[a][b] == 'j' ||
            splittedAnswer[a][b] == 'k' ||
            splittedAnswer[a][b] == 'l' ||
            splittedAnswer[a][b] == 'm' ||
            splittedAnswer[a][b] == 'n' ||
            splittedAnswer[a][b] == 'o' ||
            splittedAnswer[a][b] == 'p' ||
            splittedAnswer[a][b] == 'q' ||
            splittedAnswer[a][b] == 'r' ||
            splittedAnswer[a][b] == 's' ||
            splittedAnswer[a][b] == 't' ||
            splittedAnswer[a][b] == 'u' ||
            splittedAnswer[a][b] == 'v' ||
            splittedAnswer[a][b] == 'w' ||
            splittedAnswer[a][b] == 'x' ||
            splittedAnswer[a][b] == 'y' ||
            splittedAnswer[a][b] == 'z'){
            // splittedAnswer[a][b] == ',' ||
            // splittedAnswer[a][b] == '.') {
          var rand = math.Random();
          alphabetSmall.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(25 - i);
            selectProgress1.add(alphabetSmall[randomNumber]);
            alphabetSmall.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);
          alphabetSmall = [
            'a',
            'b',
            'c',
            'd',
            'e',
            'f',
            'g',
            'h',
            'i',
            'j',
            'k',
            'l',
            'm',
            'n',
            'o',
            'p',
            'q',
            'r',
            's',
            't',
            'u',
            'v',
            'w',
            'x',
            'y',
            'z',
            // ',',
            // '.'
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
          // select[answerIndex[answerIndex.length - 1]].add(letter);
        } else if (splittedAnswer[a][b] == 'A' ||
            splittedAnswer[a][b] == 'B' ||
            splittedAnswer[a][b] == 'C' ||
            splittedAnswer[a][b] == 'D' ||
            splittedAnswer[a][b] == 'E' ||
            splittedAnswer[a][b] == 'F' ||
            splittedAnswer[a][b] == 'G' ||
            splittedAnswer[a][b] == 'H' ||
            splittedAnswer[a][b] == 'I' ||
            splittedAnswer[a][b] == 'J' ||
            splittedAnswer[a][b] == 'K' ||
            splittedAnswer[a][b] == 'L' ||
            splittedAnswer[a][b] == 'M' ||
            splittedAnswer[a][b] == 'N' ||
            splittedAnswer[a][b] == 'O' ||
            splittedAnswer[a][b] == 'P' ||
            splittedAnswer[a][b] == 'Q' ||
            splittedAnswer[a][b] == 'R' ||
            splittedAnswer[a][b] == 'S' ||
            splittedAnswer[a][b] == 'T' ||
            splittedAnswer[a][b] == 'U' ||
            splittedAnswer[a][b] == 'V' ||
            splittedAnswer[a][b] == 'W' ||
            splittedAnswer[a][b] == 'X' ||
            splittedAnswer[a][b] == 'Y' ||
            splittedAnswer[a][b] == 'Z') {
          var rand = math.Random();
          alphabetCapital.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(25 - i);
            selectProgress1.add(alphabetCapital[randomNumber]);
            alphabetCapital.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);

          alphabetCapital = [
            'A',
            'B',
            'C',
            'D',
            'E',
            'F',
            'G',
            'H',
            'I',
            'J',
            'K',
            'L',
            'M',
            'N',
            'O',
            'P',
            'Q',
            'R',
            'S',
            'T',
            'U',
            'V',
            'W',
            'X',
            'Y',
            'Z',
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
        } else if (splittedAnswer[a][b] == '0' ||
            splittedAnswer[a][b] == '1' ||
            splittedAnswer[a][b] == '2' ||
            splittedAnswer[a][b] == '3' ||
            splittedAnswer[a][b] == '4' ||
            splittedAnswer[a][b] == '5' ||
            splittedAnswer[a][b] == '6' ||
            splittedAnswer[a][b] == '7' ||
            splittedAnswer[a][b] == '8' ||
            splittedAnswer[a][b] == '9') {
          var rand = math.Random();
          number.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            int randomNumber = rand.nextInt(9 - i);
            selectProgress1.add(number[randomNumber]);
            number.removeAt(randomNumber);
          }
          selectProgress2.add(selectProgress1);

          number = [
            '0',
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
          ];
          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
        } else {
          var rand = math.Random();
          // hiragana.remove(splittedAnswer[a][b]);
          selectProgress1 = [];
          for (var i = 0; i < 4; i++) {
            selectProgress1.add('?');
          }
          selectProgress2.add(selectProgress1);

          answerIndexProgress.add(rand.nextInt(4));
          // answerIndex[a].add(rand.nextInt(4));
          selectProgress2[selectProgress2.length - 1]
                  [answerIndexProgress[answerIndexProgress.length - 1]] =
              splittedAnswer[a][b];
        }
      }
      select.add(selectProgress2);
      answerIndex.add(answerIndexProgress);
    }
    selectionsAndAnswer = select;
    // selectionsAndAnswer[a][b].add(answerIndex);
    for (var a = 0; a < selectionsAndAnswer.length; a++) {
      for (var b = 0; b < selectionsAndAnswer[a].length; b++) {
        selectionsAndAnswer[a][b].add(answerIndex[a][b].toString());
      }
    }
    for (var value in selectionsAndAnswer) {
     //print(value);
    }
    // print("quizisOK");
    // selectionsAndAnswer.add(answerIndex);
    return selectionsAndAnswer;
  }
}

List<List<List<dynamic>>> quizGenerator(List<List<dynamic>> splittedAnswer) {
  List<List<List<dynamic>>> selectionsAndAnswer = [];
  // late List<List<String>> selection;

  // for (var value in splittedAnswer) {
  //   // String answer = value['answer'];

  //   Quiz quiz = Quiz(
  //     value, //question
  //     // value[1], //splitted answer
  //     // value[2],
  //   );
  //   // quizList.add(Quiz(value[0],value[1],value[2]));

  //   selectionsAndAnswer.add(quiz);
  // }
  // var quiz = Quiz(splittedAnswer);
  var quiz = Quiz(splittedAnswer);
  // print('四角形の面積は${rect.getArea()}㎠'); // メソッドの呼び出し
  // List<List<List<dynamic>>> quiz = Quiz.toMap(splittedAnswer);
  selectionsAndAnswer = quiz.toMap();
  return selectionsAndAnswer;
}
