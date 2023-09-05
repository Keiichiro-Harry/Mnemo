import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//https://zenn.dev/maropook/articles/4bfa59b464520c

class AddBookCardsPageQuick extends StatefulWidget {
  AddBookCardsPageQuick(this.user, this.bookInfo);
  final User user;
  final DocumentSnapshot<Object?> bookInfo;

  @override
  _AddBookCardsPageQuickState createState() => _AddBookCardsPageQuickState();
}

class _AddBookCardsPageQuickState extends State<AddBookCardsPageQuick> {
  // List<String> questionText = [];
  // List<String> answerText = [];
  int number = 0;
  bool _isProcessing = false; // 処理中かどうかを管理するフラグ
  // 非同期関数をシミュレートするメソッド
  Future<void> addCardsQuick() async {
    // 処理中フラグをセットしてUIを更新
    setState(() {
      number = 0;
    });
    //ここから処理開始
    final Timestamp date = Timestamp.fromDate(DateTime.now()); // 現在の日時
    // Firestoreのインスタンスを取得
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // ドキュメントの参照を作成
    DocumentReference documentReference = _firestore
        .collection('users')
        .doc(widget.user.uid)
        .collection('books')
        .doc(widget.bookInfo.id);
    try {
      // ドキュメントのデータを取得
      await documentReference.get().then((documentSnapshot) {
        if (documentSnapshot.exists) {
          // ドキュメントが存在する場合
          var data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            number = data['next_num'];
            print('in setState');
          });
        } else {
          print('ドキュメントが存在しません。');
        }
      });
      print("Start adding");
      print(number);
      DocumentReference destinationDocRef = _firestore
          .collection('users')
          .doc(widget.user.uid)
          .collection('books') // コレクションID指定
          .doc(widget.bookInfo.id)
          .collection(
              'content') //collectionの使いわけがあまり分かってないけど、とりあえずcontentに入れておく。他のcollectionが増えたり(ユーザーごとにイイネを記録するなど)するかも。
          .doc(); //ドキュメントID自動生成
      await destinationDocRef.set({
        // 'question': questionText,
        // 'answer': answerText,
        // 'email': email,
        'number': number,
        'date': date,
        'isArchived': false,
        'isChecked': false,
        'stage': 1,
        'creatorID': widget.user.uid
      });
      setState(() {
        number++;
      });
      print("End adding");
      _firestore
          .collection('users')
          .doc(widget.user.uid)
          .collection('books')
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
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('カードを追加'),
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          _isProcessing = true; // ここでフラグを設定
                          setState(() {}); // フラグの変更を反映
                          await showDialog<int>(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  addCardsQuick().then((_) {
                                    // 正常に終了した場合の処理
                                    Navigator.popUntil(
                                      context,
                                      (route) => route.isFirst,
                                    );
                                  }).catchError((error) {
                                    // エラーが発生した場合の処理
                                    print('エラーが発生しました: $error');
                                    setState(() {
                                      _isProcessing = false; // エラー時にフラグを設定
                                    });
                                    Navigator.of(context).pop(); // ダイアログを閉じる
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("構文エラーまたは接続エラー"),
                                      ),
                                    );
                                  });
                                  return Dialog(
                                    child: Container(
                                      width: 400,
                                      height: 200,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "処理中...$number",
                                            style: TextStyle(fontSize: 30),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                ),
              ),
              // if (_isProcessing) CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
