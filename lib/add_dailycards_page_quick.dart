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
import 'process_add_card_quick.dart';
import 'rule_quick.dart';

//https://zenn.dev/maropook/articles/4bfa59b464520c

class AddDailyCardsPageQuick extends StatefulWidget {
  AddDailyCardsPageQuick(this.user, this.bookInfo);
  final User user;
  final DocumentSnapshot<Object?> bookInfo;

  @override
  _AddDailyCardsPageQuickState createState() => _AddDailyCardsPageQuickState();
}

class _AddDailyCardsPageQuickState extends State<AddDailyCardsPageQuick> {
  // List<String> questionText = [];
  // List<String> answerText = [];
  String nameText = '';
  // List<String> commentText = [];
  String originalText = '';
  late List<Map> quizList = [];
  String tagText = '';
  String newTagText = '';
  var _selectedValue = ""; //ここに移動させたらちゃんと反映されるようになった！
  var isSelectedItem = "None";
  bool _isProcessing = false;
  ScrollController _scrollController = ScrollController();

  Future<void> addCards() async {
    int number = widget.bookInfo['next_num'];
    final Timestamp date = Timestamp.fromDate(DateTime.now()); // 現在の日時
    final email = widget.user.email; // AddPostPage のデータを参照
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // ドキュメントの参照を作成
    DocumentReference documentReference = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('daily_memory')
        .doc(widget.bookInfo.id);
    try {
      int number = 0;
      // ドキュメントのデータを取得
      await documentReference.get().then((documentSnapshot) {
        if (documentSnapshot.exists) {
          // ドキュメントが存在する場合
          var data = documentSnapshot.data() as Map<String, dynamic>;
          number = data['next_num'];
        } else {
          print('ドキュメントが存在しません。');
        }
      });
      quizList = await getData(originalText);
      // final disallowedChars = ['<', '>', '&', '"', "'", '\\', '='];
      // newTagText.trim().replaceAll(RegExp(disallowedChars.join('|')), '');
      // 投稿メッセージ用ドキュメント作成
      for (var value in quizList) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .collection('daily_memory') // コレクションID指定
            .doc(widget.bookInfo.id)
            .collection(
                'content') //collectionの使いわけがあまり分かってないけど、とりあえずcontentに入れておく。他のcollectionが増えたり(ユーザーごとにイイネを記録するなど)するかも。
            .doc() // ドキュメントID自動生成
            .set({
          // 'question': questionText,
          // 'answer': answerText,
          // 'email': email,
          'number': number,
          'comment': value['comment'].trim(),
          'tag': newTagText.trim() != "" ? newTagText.trim() : tagText,
          'date': date,
          'isArchived': false,
          'isChecked': false,
          'question': value['question'].trim(),
          'answer': value["answer"].trim(),
          'stage': 1,
        });
        //print(value);
        number++;
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .collection('daily_memory')
          .doc(widget.bookInfo.id)
          .update({'next_num': number});
    } catch (e) {
      throw Exception('エラーが発生しました');
    }
  }

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
              Scrollbar(
                controller: _scrollController,
                child: TextFormField(
                  decoration: InputDecoration(labelText: '問題;答え;コメント'),
                  // 複数行のテキスト入力
                  keyboardType: TextInputType.multiline,
                  // 最大8行
                  maxLines: 8,
                  onChanged: (String value) {
                    setState(() {
                      originalText = value;
                    });
                  },
                ),
              ),

              Row(children: <Widget>[
                Text('タグ'),
                Container(height: 20, width: 20),
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user.uid)
                          .collection('daily_memory')
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
                decoration: InputDecoration(labelText: '新しいタグ'),
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
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          setState(() {
                            _isProcessing = true; // ここでフラグを設定
                          }); // フラグの変更を反映
                          addCards().then((_) {
                            // 正常に終了した場合の処理
                            Navigator.of(context).pop();
                          }).catchError((error) {
                            // エラーが発生した場合の処理
                            print('エラーが発生しました: $error');
                            setState(() {
                              _isProcessing = false; // エラー時にフラグを設定
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("構文エラーまたは接続エラー"),
                              ),
                            );
                          });
                        },
                ),
              ),
              if (_isProcessing) CircularProgressIndicator(),
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
              return RuleQuickPage();
            }),
          );
        },
      ),
    );
  }
}

// class Quiz {
//   String question;
//   String answer;
//   String comment;

//   Map<String, dynamic> toMap() {
//     return {
//       'question': question,
//       'answer': answer,
//       'comment': comment,
//     };
//   }

//   Quiz(
//     this.question,
//     this.answer,
//     this.comment,
//   );
// }
