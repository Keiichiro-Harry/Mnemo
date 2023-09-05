import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import './bookshelf.dart';

class AddDailyMemoryPage extends StatefulWidget {
  final User currentUser;
  AddDailyMemoryPage({required this.currentUser});

  @override
  _AddDailyMemoryPageState createState() => _AddDailyMemoryPageState();
}

class _AddDailyMemoryPageState extends State<AddDailyMemoryPage> {
  String _accountName = '';
  late DateTime currentDate;
  late String formattedDate;
  late TextEditingController nameTextController; // 追加


  @override
  void initState() {
    super.initState();
    loadAccountName();
    DateTime currentDate = DateTime.now();
    String formattedDate = "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
    // コントローラーを初期化し、デフォルト値を設定
    nameTextController = TextEditingController(text: formattedDate);
  }

  @override
  void dispose() {
    nameTextController.dispose(); // 不要になったら解放する
    super.dispose();
  }

  Future<void> loadAccountName() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUser.uid)
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
  bool? isPublic = false;
  void _handleCheckbox(bool e) {
    setState(() {
      isPublic = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('本棚に追加'),
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
                controller: nameTextController, // コントローラーを指定
                decoration: InputDecoration(labelText: '本の名前'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
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
              TextFormField(
                decoration: InputDecoration(labelText: 'タグ'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    tagText = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('本棚に追加'),
                  onPressed: () async {
                    final Timestamp date = Timestamp.fromDate(DateTime.now()); // 現在の日時
                    final email = widget.currentUser.email; // AddPostPage のデータを参照
                    // 投稿メッセージ用ドキュメント作成
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.currentUser.uid)
                        .collection('daily_memory') // コレクションID指定
                        .doc() // ドキュメントID自動生成
                        .set({
                      // 'question': questionText,
                      // 'answer': answerText,
                      'next_num':1,
                      'email': email,
                      'creator' : _accountName,
                      'comment': commentText,
                      'tag': tagText,
                      'date': date,
                      'isChecked': false,
                      'name': nameTextController.text,
                    });
                    setState(() {});
                    // 1つ前の画面に戻る
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}