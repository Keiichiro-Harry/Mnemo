import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:sqflite/sqflite.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import './bookcards.dart';
import './bookshelf.dart';
import 'rule.dart';

class AddBookCardsPage extends StatefulWidget {
  final User user;
  final DocumentSnapshot<Object?> bookInfo;
  AddBookCardsPage(this.user, this.bookInfo);

  @override
  _AddBookCardsPageState createState() => _AddBookCardsPageState();
}

class _AddBookCardsPageState extends State<AddBookCardsPage> {
  String _accountName = '';

  @override
  void initState() {
    super.initState();
    loadAccountName();
  }

  Future<void> loadAccountName() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      setState(() {
        _accountName = doc.get('account_name');
      });
    } catch (e) {
      print('Error loading account name: $e');
    }
  }

  String questionText = '';
  String answerText = '';
  String nameText = '';
  String commentText = '';
  String tagText = '';
  String newTagText = '';
  var _selectedValue = ""; //ここに移動させたらちゃんと反映されるようになった！
  var isSelectedItem = "None";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('カードを追加'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 投稿メッセージ入力
              // TextFormField(
              //   decoration: InputDecoration(labelText: '問題'),
              //   // 複数行のテキスト入力
              //   keyboardType: TextInputType.multiline,
              //   // 最大3行
              //   maxLines: 3,
              //   onChanged: (String value) {
              //     setState(() {
              //       questionText = value;
              //     });
              //   },
              // ),
              // TextFormField(
              //   decoration: InputDecoration(labelText: '答え'),
              //   // 複数行のテキスト入力
              //   keyboardType: TextInputType.multiline,
              //   // 最大3行
              //   maxLines: 3,
              //   onChanged: (String value) {
              //     setState(() {
              //       answerText = value;
              //     });
              //   },
              // ),
              TextFormField(
                decoration: InputDecoration(labelText: '問題'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    questionText = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '答え'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    answerText = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'コメント'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    commentText = value;
                  });
                },
              ),

              Row(children: <Widget>[
                Text('タグ'),
                Container(height: 20, width: 20),
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user.uid)
                          .collection('books')
                          .doc(widget.bookInfo.id)
                          .collection("content")
                          .orderBy('date')
                          // .endBefore(["中枢神経", "questoion"])
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data != null) {
                            final List<DocumentSnapshot> documents =
                                snapshot.data!.docs;
                            //print("OKK1");
                            var tagList = <String>[""];
                            for (var value in documents) {
                              tagList.add(value['tag']);
                            }
                            // tagList.toSet().toList();
                            tagList = tagList.toSet().toList();
                            //print(tagList);
                            return DropdownButton<String>(
                              value: _selectedValue,
                              items: tagList
                                  .map((String list) => DropdownMenuItem(
                                      value: list, child: Text(list)))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedValue = value!;
                                  //print(value);
                                  //print(_selectedValue);
                                  tagText = _selectedValue;
                                  //print("OKK2");
                                });
                              },
                            );
                          } else {
                            return Container();
                          }
                        }
                        return const Center(
                          child: Text('読み込み中...'),
                        );
                      }),
                ),
              ]),

              TextFormField(
                decoration: InputDecoration(labelText: '新しいタグ("All"は使えません)'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String? value) {
                  setState(() {
                    newTagText = value!;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('カードを追加'),
                  onPressed: () async {
                    final disallowedChars = [
                      '<',
                      '>',
                      '&',
                      '"',
                      "'",
                      '\\',
                      '='
                    ];
                    commentText
                        .trim()
                        .replaceAll(RegExp(disallowedChars.join('|')), '');
                    questionText
                        .trim()
                        .replaceAll(RegExp(disallowedChars.join('|')), '');
                    answerText
                        .trim()
                        .replaceAll(RegExp(disallowedChars.join('|')), '');
                    newTagText
                        .trim()
                        .replaceAll(RegExp(disallowedChars.join('|')), '');
                    bool inParentheses = false;
                    bool inBrackets = false;
                    List<String> splittedAnswer = answerText.split('');
                    List<String> ckets = ['(', ')', '[', ']'];
                    // Firestoreのインスタンスを取得
                    final FirebaseFirestore _firestore =
                        FirebaseFirestore.instance;
                    // ドキュメントの参照を作成
                    DocumentReference documentReference = _firestore
                        .collection('users')
                        .doc(widget.user.uid)
                        .collection('books')
                        .doc(widget.bookInfo.id);
                    try {
                      for (int i = 0; i < splittedAnswer.length; i++) {
                        if (ckets.contains(splittedAnswer[i])) {
                          if (splittedAnswer[i] == '(' &&
                              !inParentheses &&
                              !inBrackets) {
                            inParentheses = true;
                          } else if (splittedAnswer[i] == '[' &&
                              !inParentheses &&
                              !inBrackets) {
                            inBrackets = true;
                          } else if (splittedAnswer[i] == ')' &&
                              inParentheses) {
                            inParentheses = false;
                          } else if (splittedAnswer[i] == ']' && inBrackets) {
                            inBrackets = false;
                          } else {
                            throw FormatException(
                                "Invalid answer format: $answerText");
                          }
                        }
                      }
                      if (!inParentheses && !inBrackets) {
                        int number = 0;
                        // ドキュメントのデータを取得
                        await documentReference.get().then((documentSnapshot) {
                          if (documentSnapshot.exists) {
                            // ドキュメントが存在する場合
                            var data =
                                documentSnapshot.data() as Map<String, dynamic>;
                            number = data['next_num'];
                          } else {
                            print('ドキュメントが存在しません。');
                          }
                        });
                        final Timestamp date =
                            Timestamp.fromDate(DateTime.now()); // 現在の日時
                        final email = widget.user.email; // AddPostPage のデータを参照
                        // 投稿メッセージ用ドキュメント作成
                        DocumentReference destinationDocRef =
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.user.uid)
                                .collection('books') // コレクションID指定
                                .doc(widget.bookInfo.id)
                                .collection("content")
                                .doc(); // ドキュメントID自動生成
                        await destinationDocRef.set({
                          // 'question': questionText,
                          // 'answer': answerText,
                          // 'email': email,
                          'number': number,
                          'comment': commentText,
                          'tag': newTagText != "" ? newTagText : tagText,
                          'date': date,
                          'isArchived': false,
                          'isChecked': false,
                          'question': questionText,
                          'answer': answerText,
                          'stage': 1,
                          'creatorID': widget.user.uid
                        });
                        if (widget.bookInfo['isPublic'] == true) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc('8ETzTCzHEj5N1zynrI89')
                              .collection('books')
                              .doc(widget.bookInfo['publicID'])
                              .update({'next_num': number + 1});
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc("8ETzTCzHEj5N1zynrI89")
                              .collection('books') // コレクションID指定
                              .doc(widget.bookInfo["publicID"])
                              .collection("content")
                              .doc(destinationDocRef.id) // ドキュメントID自動生成
                              .set({
                            // 'question': questionText,
                            // 'answer': answerText,
                            'number': number,
                            'tag': newTagText != "" ? newTagText : tagText,
                            'date': date,
                            'question': questionText,
                            'answer': answerText,
                            'comment': commentText,
                            'creatorID': widget.user.uid
                          });
                          final DocumentReference documentReference =
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc('8ETzTCzHEj5N1zynrI89')
                                  .collection('books')
                                  .doc(widget.bookInfo['publicID']);
                          final QuerySnapshot querySnapshot =
                              await documentReference
                                  .collection('readers')
                                  .get();
                          for (QueryDocumentSnapshot doc
                              in querySnapshot.docs) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(doc.id)
                                .collection('books')
                                .doc(doc['destinationID'])
                                .update({'isLatest': false});
                          }
                        }
                        number++;
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user.uid)
                            .collection('books')
                            .doc(widget.bookInfo.id)
                            .update({'next_num': number});
                        setState(() {});
                        // 1つ前の画面に戻る
                        Navigator.of(context).pop();
                      } else {
                        throw FormatException(
                            "Invalid answer format: $answerText");
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text("構文エラー")));
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.question_mark_rounded),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return RulePage();
            }),
          );
        },
      ),
    );
  }
}
