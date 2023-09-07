// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:sqflite/sqflite.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import './bookshelf.dart';
import './login_page.dart';
import 'dart:math' as math;
import 'process_string.dart';
import 'process_quiz.dart';

class MemoriaGame extends StatefulWidget {
  final User user;
  final DocumentSnapshot<Object?> bookInfo;
  final String tag;
  final bool? shuffle;
  MemoriaGame(this.user, this.bookInfo, this.tag, this.shuffle);
  @override
  _MemoriaGameState createState() => _MemoriaGameState();
}

class _MemoriaGameState extends State<MemoriaGame> {
  // var _progress = '';
  var db = FirebaseFirestore.instance;
  List<List<dynamic>> splittedAnswer =
      []; //面倒だから、問題番号ごとにquizを0,一文字ずつanswer配列を1、元answerを2,List<List>選択肢を3,answerIndex配列を4の単純配列にしちゃおう
  List<List<dynamic>> originalQuizList = []; //こっちは元answerまで
  List<List<List<dynamic>>> selectionsAndAnswer = [];
  // List<List<int>> answerIndex = [[]];
  int typedLength = 0; //
  int showedLength = 0;
  int quizNumber = 0; //
  List<bool> result = [];
  bool isSelectNow = true;
  int count = 0;
  bool inParentheses = false;
  bool inBrackets = false;
  void gameInitializer() {
    result = List.filled(originalQuizList.length, true);
  }

  void initializeValiables() {
    //print("valiables initialized");
    setState(() {
      inParentheses = false;
      inBrackets = false;
      typedLength = 0; //打ち込んだ文字の数
      showedLength = 0; //表示されている文字の数
    });
    skipLetter();
    for (int i = showedLength; i < splittedAnswer[quizNumber].length; i++) {
      if (splittedAnswer[quizNumber][i] == '(') {
        inParentheses = true;
      } else if (splittedAnswer[quizNumber][i] == '[') {
        inBrackets = true;
      } else if (splittedAnswer[quizNumber][i] == ')' && inParentheses) {
        inParentheses = false;
      } else if (splittedAnswer[quizNumber][i] == ']' && inBrackets) {
        inBrackets = false;
      } else if (inParentheses || inBrackets) {
        //answerの最初の括弧に入る
        break;
      }
      if (showedLength < splittedAnswer[quizNumber].length - 1) {
        setState(() {
          showedLength++;
        });
      }
    }
  }

  void skipLetter() {
    int flag = 0;
    while (flag == 0 &&
        typedLength < selectionsAndAnswer[quizNumber].length &&
        showedLength < splittedAnswer[quizNumber].length) {
      if (splittedAnswer[quizNumber][showedLength] == ' ' ||
          splittedAnswer[quizNumber][showedLength] == '　' ||
          splittedAnswer[quizNumber][showedLength] == '/' ||
          splittedAnswer[quizNumber][showedLength] == '・' ||
          splittedAnswer[quizNumber][showedLength] == ',' ||
          splittedAnswer[quizNumber][showedLength] == '.' ||
          splittedAnswer[quizNumber][showedLength] == ':' ||
          splittedAnswer[quizNumber][showedLength] == '。' ||
          splittedAnswer[quizNumber][showedLength] == '、') {
        setState(() {
          typedLength++;
          showedLength++;
        });
      } else {
        flag = 1;
      }
    }
  }

  Future<void> updateQuiz(BuildContext context, int typedAnswerKey) async {
    //print(typedAnswerKey);
    setState(() {
      isSelectNow = false; //falseの間は計算してるから待ってねって感じ
    });
//その選択肢が正解なのかどうか。最後の文字かどうかをtypedLengthでやると後でクールタイムつける時に困るなって思ったけど、その時はshowedLengthを最大値にすればいいだけの話だからそうする。
//if正解{i
//  1文字更新
//  if括弧閉じ{ii
//    if最後の文字typedLength{iii
//      if最後の問題{iv
//        結果画面へ
//      }
//      次の問題へ
//    }else{v
//      while次の括弧まで文字を進める{vi
//        if括弧発見{vii
//          選択肢を更新してwhileを抜ける
//        }//上の条件でtypedLengthが最大値ではないため、括弧がないことはない
//      }
//    }
//  }else{viii
//    選択肢を更新
//  }
//}else{ix
//  if答えが4ではない{
//    resultに不正解を入力
//  }
//  while括弧の閉じまで文字を進める{x
//    typedLength++;
//  }
//  if最後の文字typedLength{xi
//    if最後の問題{xii
//      結果画面へ
//    }
//    次の問題へ
//  }else{xiii
//    while次の括弧まで文字を進める{ixv
//      if括弧発見{xv
//        選択肢を更新してwhileを抜ける
//      }//上の条件でtypedLengthが最大値ではないため、括弧がないことはない
//    }
//  }
//}
//
//表示されているのが[0~showedLength-1]で個数はshowedLength, [showedLength]を答えて正解すると+1して括弧審査で[showedLength](つまりさっき答えたものの次)を見る
    if (int.parse(selectionsAndAnswer[quizNumber][typedLength][4]) ==
        typedAnswerKey) {
      //i
      setState(() {
        showedLength++;
      });
      if (splittedAnswer[quizNumber][showedLength] == ')' && inParentheses) {
        //ii
        inParentheses = false;
        if (typedLength == selectionsAndAnswer[quizNumber].length - 1) {
          //iii
          if (quizNumber == originalQuizList.length - 1) {
            //iv
            await goToResult(context, originalQuizList, result);
            return;
          }
          setState(() {
            quizNumber++;
          });
          //print("before initialize1");
          initializeValiables();
          //print("after initialize1");
          isSelectNow = true;
          return;
        } else {
          //v
          while (showedLength < splittedAnswer[quizNumber].length) {
            //vi
            setState(() {
              showedLength++;
            });
            if (splittedAnswer[quizNumber][showedLength] == '(') {
              //vii
              inParentheses = true;
              setState(() {
                showedLength++;
                typedLength++;
              });
              break;
            } else if (splittedAnswer[quizNumber][showedLength] == '[') {
              //vii
              inBrackets = true;
              setState(() {
                showedLength++;
                typedLength++;
              });
              break;
            }
          }
        }
      } else if (splittedAnswer[quizNumber][showedLength] == ']' &&
          inBrackets) {
        //ii//上と合体してもいいけど今後用途が広がるかもしれないから分ける
        inBrackets = false;
        if (typedLength == selectionsAndAnswer[quizNumber].length - 1) {
          //iii
          if (quizNumber == originalQuizList.length - 1) {
            //iv
            await goToResult(context, originalQuizList, result);
            return;
          }
          setState(() {
            quizNumber++;
          });
          //print("before initialize2");
          initializeValiables();
          //print("after initialize2");
          isSelectNow = true;
          return;
        } else {
          //v
          while (showedLength < splittedAnswer[quizNumber].length) {
            //vi
            setState(() {
              showedLength++;
            });
            if (splittedAnswer[quizNumber][showedLength] == '(') {
              //vii
              inParentheses = true;
              setState(() {
                showedLength++;
                typedLength++;
              });
              break;
            } else if (splittedAnswer[quizNumber][showedLength] == '[') {
              //vii
              inBrackets = true;
              setState(() {
                showedLength++;
                typedLength++;
              });
              break;
            }
          }
        }
      } else {
        //viii
        skipLetter();
        setState(() {
          typedLength++;
        });
      }
    } else {
      //ix
      if (typedAnswerKey != 4) {
        result[quizNumber] = false;
      }
      setState(() {
        showedLength++;
      });
      while (showedLength < splittedAnswer[quizNumber].length &&
          typedLength < selectionsAndAnswer[quizNumber].length - 1) {
        //x
        if (splittedAnswer[quizNumber][showedLength] == ')' && inParentheses) {
          inParentheses = false;
          setState(() {
            showedLength++;
          });
          break;
        } else if (splittedAnswer[quizNumber][showedLength] == ']' &&
            inBrackets) {
          inBrackets = false;
          setState(() {
            showedLength++;
          });
          break;
        }
        setState(() {
          showedLength++;
          typedLength++;
        });
      }
      if (typedLength == selectionsAndAnswer[quizNumber].length - 1) {
        //xiここ際どい
        if (quizNumber == originalQuizList.length - 1) {
          //xii
          await goToResult(context, originalQuizList, result);
          return;
        }
        setState(() {
          quizNumber++;
        });
        //print("before initialize3");
        initializeValiables();
        //print("after initialize3");
        isSelectNow = true;
        return;
      } else {
        //xiii
        while (showedLength < splittedAnswer[quizNumber].length) {
          //ixv
          setState(() {
            showedLength++;
          });
          if (splittedAnswer[quizNumber][showedLength] == '(') {
            //xv
            inParentheses = true;
            setState(() {
              showedLength++;
              typedLength++;
            });
            break;
          } else if (splittedAnswer[quizNumber][showedLength] == '[') {
            //xv
            inBrackets = true;
            setState(() {
              showedLength++;
              typedLength++;
            });
            break;
          }
        }
      }
    }

    // bool A = originalQuizList.length - 1 == quizNumber; //最終問題だったらtrue
    // bool B = int.parse(selectionsAndAnswer[quizNumber][typedLength][4]) ==
    //     typedAnswerKey; //選んだ文字が正解だったらtrue
    // bool C = showedLength == splittedAnswer[quizNumber].length - 1;//最後の文字だったらtrue

    // if (A && (B == false || ((B || typedAnswerKey == 4) && C))) {//ごちゃってしてるけどつまり最終問題のとき
    //   if (B || typedAnswerKey == 4) {
    //     result.add(true);
    //     print("here1");
    //   }else{

    //   }
    //   await goToResult(context, originalQuizList, result);
    // } else if (B && C == false) {
    //   typedLength++;
    //   print("here2");
    // } else if (B || typedAnswerKey == 4) {
    //   result++;
    //   typedLength = 0;
    //   quizNumber++;
    //   print("here3");
    // } else {
    //   typedLength = 0;
    //   quizNumber++;
    //   print("here4");
    // }
    // await Future.delayed(const Duration(seconds: 1));
    isSelectNow = true;
    setState(() {});
    // typedLength++;
    // if (quizNumber == originalQuizList.length - 1) {
    //   // await goToResult(context, originalQuizList, result);
    //   print("OKquiz");
    //   await goToResult(context, originalQuizList, result);
    // }
    setState(() {});
  }

  Future<void> goToResult(BuildContext context, quizList, result) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Result(result, quizList)));
  }

  @override
  //
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(widget.bookInfo['name'] + '【' + widget.tag + '】'),
  //     ),
  //     body: Center(
  //       child: Container(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           // mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             const SizedBox(height: 100, width: 20),
  //             // Text(_progress),
  //             Text('Bold34567890-098765432',
  //                 style: const TextStyle(
  //                     // fontWeight: FontWeight.bold,
  //                     fontSize: 36)),
  //             const SizedBox(height: 60, width: 20),
  //             Text('Bold34567890-098765432',
  //                 style: const TextStyle(
  //                     // fontWeight: FontWeight.bold,
  //                     fontSize: 36)),
  //             const SizedBox(height: 60, width: 20),
  //             Flexible(
  //                 child: widget.tag != 'All'
  //                     ? StreamBuilder<QuerySnapshot>(
  //                         stream: FirebaseFirestore.instance
  //                             .collection('books')
  //                             .doc(widget.bookInfo.id)
  //                             .collection(widget.bookInfo['name'])
  //                             .orderBy('date')
  //                             .where('tag', isEqualTo: widget.tag)
  //                             .snapshots(),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.hasData) {
  //                             final List<DocumentSnapshot> documents =
  //                                 snapshot.data!.docs;
  //                             final quizGenerator(documents);
  //                             return Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: <Widget>[
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20)
  //                               ],
  //                             );
  //                           }
  //                         },
  //                       )
  //                     : StreamBuilder<QuerySnapshot>(
  //                         stream: FirebaseFirestore.instance
  //                             .collection('books')
  //                             .doc(widget.bookInfo.id)
  //                             .collection(widget.bookInfo['name'])
  //                             .orderBy('date')
  //                             .snapshots(),
  //                         builder: (context, snapshot) {
  //                           if (snapshot.hasData) {
  //                             final List<DocumentSnapshot> documents =
  //                                 snapshot.data!.docs;
  //                             final quizGenerator(documents);
  //                             return Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: <Widget>[
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20),
  //                                 const SizedBox(height: 20, width: 20)
  //                               ],
  //                             );
  //                           }
  //                         },
  //                       ))
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    return Flex(direction: Axis.horizontal, children: [
      Flexible(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc('8ETzTCzHEj5N1zynrI89')
                  .collection('books')
                  .doc(widget.bookInfo.id)
                  .collection('content')
                  .orderBy('number')
                  // .endBefore(["中枢神経", "questoion"])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    final Iterable<QueryDocumentSnapshot<Object?>> documents =
                        snapshot.data!.docs;
                    // print("OKK1");
                    // var tagList = <String>[""];
                    // List<String> thisAnswer = [];
                    if (count == 0) {
                      for (var value in documents) {
                        // thisAnswer.add(value["answer"]);
                        if (widget.tag == 'All') {
                          originalQuizList
                              .add([value['question'], value['answer']]);
                        } else if (value["tag"] == widget.tag) {
                          originalQuizList
                              .add([value['question'], value['answer']]);
                        }
                      }
                      //シャッフル
                      if (widget.shuffle == true) {
                        final random = math.Random();

                        for (var i = originalQuizList.length - 1; i > 0; i--) {
                          final j = random.nextInt(i + 1);
                          final temp = originalQuizList[i];
                          originalQuizList[i] = originalQuizList[j];
                          originalQuizList[j] = temp;
                        }
                      }
                      for (List originalQuiz in originalQuizList) {
                        splittedAnswer.add(originalQuiz[1].split(''));
                      }
                      // print("OKquiz");
                      // splittedAnswer.removeAt(0);
                      // originalQuizList.removeAt(0);
                      // selectionsAndAnswer.removeAt(0);
                      selectionsAndAnswer = quizGenerator(splittedAnswer);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        gameInitializer();
                        initializeValiables();
                      });
                      count++;
                    }
                    // print("OKquiz");
                    // tagList.toSet().toList();
                    // tagList = tagList.toSet().toList();
                    // print(tagList);
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(
                            widget.bookInfo['name'] + '【' + widget.tag + '】'),
                      ),
                      body: quizNumber < originalQuizList.length
                          ? Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                  Text(
                                    //問題番号
                                    "${quizNumber+1}/${originalQuizList.length}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                    //問題
                                    originalQuizList[quizNumber][0],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Text(
                                    //回答途中経過
                                    processString(originalQuizList[quizNumber]
                                            [1]
                                        .substring(0, showedLength)),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      4,
                                      (index) => Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (!isSelectNow) return;
                                            await updateQuiz(context, index);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  8.0), // Adjust the radius as needed
                                            ),
                                            backgroundColor: Colors.purple[200],
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 12),
                                            minimumSize: Size(60, 60),
                                          ),
                                          child: Text(
                                            selectionsAndAnswer[quizNumber]
                                                [typedLength][index],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (!isSelectNow) return;
                                          await updateQuiz(
                                              context, 4); //4を送ると正解になる
                                        },
                                        child: Text('OK'),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(120,
                                              40), // Adjust width and height as needed
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (!isSelectNow) return;
                                          await updateQuiz(
                                              context, 5); //5を送ると不正解になる
                                        },
                                        child: Text('Skip'),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(120,
                                              40), // Adjust width and height as needed
                                        ),
                                      ),
                                    ],
                                  ),
                                ]))
                          //以下、選択肢縦並びバージョン
                          // ? CustomScrollView(
                          //     slivers: <Widget>[
                          //       SliverList(
                          //           delegate: SliverChildListDelegate([
                          //         Padding(
                          //             padding: EdgeInsets.only(
                          //                 top: MediaQuery.of(context)
                          //                         .size
                          //                         .height /
                          //                     4)),
                          //         Text(
                          //           originalQuizList[quizNumber][0],
                          //           textAlign: TextAlign.center,
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 30,
                          //             color: Theme.of(context).primaryColor,
                          //           ),
                          //         ),
                          //         Text(
                          //           originalQuizList[quizNumber][1]
                          //               .substring(0, typedLength),
                          //           textAlign: TextAlign.center,
                          //           style: TextStyle(
                          //             fontWeight: FontWeight.bold,
                          //             fontSize: 20,
                          //             color: Theme.of(context).primaryColor,
                          //           ),
                          //         ),
                          //         Container(
                          //           height: 80,
                          //         ),
                          //       ])),
                          //       SliverList(
                          //           delegate: SliverChildBuilderDelegate(
                          //         (context, key) {
                          //           return ClipRRect(
                          //               borderRadius: BorderRadius.circular(4),
                          //               child: Column(
                          //                   // mainAxisSize: MainAxisSize.min,
                          //                   children: <Widget>[
                          //                     Stack(
                          //                       alignment: Alignment.center,
                          //                       children: <Widget>[
                          //                         // Positioned.fill(
                          //                         // child:
                          //                         Container(
                          //                           height: 40,
                          //                           width: 40,
                          //                           decoration: BoxDecoration(
                          //                             borderRadius:
                          //                                 BorderRadius.circular(
                          //                                     10),
                          //                             gradient:
                          //                                 const LinearGradient(
                          //                               colors: <Color>[
                          //                                 Color(0xFF0D47A1),
                          //                                 Color(0xFF1976D2),
                          //                                 Color(0xFF42A5F5),
                          //                               ],
                          //                             ),
                          //                           ),
                          //                         ),
                          //                         // ),
                          //                         TextButton(
                          //                             style:
                          //                                 TextButton.styleFrom(
                          //                               foregroundColor:
                          //                                   Colors.white,
                          //                               padding:
                          //                                   const EdgeInsets
                          //                                       .all(16.0),
                          //                               textStyle:
                          //                                   const TextStyle(
                          //                                       fontSize: 20),
                          //                             ),
                          //                             onPressed: () async {
                          //                               if (!isSelectNow)
                          //                                 return;
                          //                               await updateQuiz(
                          //                                   context, key);
                          //                             },
                          //                             child: key != 4
                          //                                 ? Text(selectionsAndAnswer[
                          //                                         quizNumber][
                          //                                     typedLength][key])
                          //                                 // : selectionsAndAnswer[quizNumber]
                          //                                 //                 [typedLength]
                          //                                 //             [key] ==
                          //                                 //         key
                          //                                 //     ? Text(selectionsAndAnswer[quizNumber]
                          //                                 //                 [typedLength]
                          //                                 //             [key] +
                          //                                 //         "○")
                          //                                 //     : Text(selectionsAndAnswer[quizNumber]
                          //                                 //                 [typedLength]
                          //                                 //             [key] +
                          //                                 //         "×")),
                          //                                 : Text("OK")),
                          //                       ],
                          //                     ),
                          //                   ]));
                          //           // //
                          //           // TextButton(
                          //           //     style: TextButton.styleFrom(
                          //           //       foregroundColor: Colors.white,
                          //           //       padding: const EdgeInsets.all(16.0),
                          //           //       textStyle: const TextStyle(fontSize: 20),
                          //           //     ),
                          //           //     onPressed: () async {
                          //           //       if (!isSelectNow) return;
                          //           //       await updateQuiz(context, key);
                          //           //     },
                          //           //     child: isSelectNow ||
                          //           //             typedLength !=
                          //           //                 originalQuizList[quizNumber]
                          //           //                     .length
                          //           //         ? Text(selectionsAndAnswer[quizNumber]
                          //           //             [typedLength][key])
                          //           //         : selectionsAndAnswer[quizNumber]
                          //           //                     [typedLength][key] ==
                          //           //                 key
                          //           //             ? Text(
                          //           //                 selectionsAndAnswer[quizNumber]
                          //           //                         [typedLength][key] +
                          //           //                     "○")
                          //           //             : Text(
                          //           //                 selectionsAndAnswer[quizNumber]
                          //           //                         [typedLength][key] +
                          //           //                     "×"));
                          //           // //
                          //         },
                          //         childCount: 5,
                          //       )),
                          //     ],
                          //   )
                          : Container(),
                    );
                  } else {
                    return Container();
                  }
                }
                return const Center(
                  child: Text('読み込み中...'),
                );
              }))
    ]);
  }
}

class Result extends StatelessWidget {
  Result(this.result, this.quizList, {Key? key}) : super(key: key);
  List<bool> result;
  List<List<dynamic>> quizList;
  late String comment;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> goToTop(BuildContext context) async {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    int trueCount = result.where((element) => element == true).length.toInt();
    int totalCount = result.length.toInt();
    double truePercentage = (trueCount / totalCount) * 100;

    return Scaffold(
      body: Center(
        child: Column(
          //Columnの中に入れたものは縦に並べられる．Rowだと横に並べられる
          mainAxisAlignment: MainAxisAlignment.center, //Coloumの中身を真ん中に配置
          children: <Widget>[
            //Text(comment),
            Padding(
              padding: const EdgeInsets.all(54.0),
            ),
            Text('正答数${trueCount}/${totalCount}'),
            Text('正答率${truePercentage.round()}%'),
            Expanded(
              child: ListView.builder(
                itemCount: quizList.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    //actionPane: SlidableDrawerActionPane(),
                    //actionExtentRatio: 0.25,
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(quizList[index][0]),
                        onTap: () async {
                          // 投稿画面に遷移
                          // await Navigator.of(context).push(
                          //   MaterialPageRoute(builder: (context) {
                          //
                          await showDialog<int>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(quizList[index][0]),
                                  content:
                                      Text(processString(quizList[index][1])),
                                  actions: <Widget>[
                                    // ボタン領域
                                    // TextButton(
                                    //   child: Text("Cancel"),
                                    //   onPressed: () => Navigator.pop(context),
                                    // ),
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                );
                                //   }),
                                // );
                              });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
                onPressed: () async {
                  await goToTop(context);
                },
                child: const Text('トップへ戻る')),
            Padding(
              padding: const EdgeInsets.all(32.0),
            ),
          ],
        ),
      ),
    );
  }
}
