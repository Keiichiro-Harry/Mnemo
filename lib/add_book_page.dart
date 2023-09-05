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

class AddBookPage extends StatefulWidget {
  final User currentUser;
  AddBookPage({required this.currentUser});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
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
                decoration: InputDecoration(labelText: '本の名前'),
                // 複数行のテキスト入力
                keyboardType: TextInputType.multiline,
                // 最大3行
                maxLines: 3,
                onChanged: (String value) {
                  setState(() {
                    nameText = value;
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
              Row(
                children: [
                  Checkbox(
                    value: isPublic,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isPublic = newValue;
                      });
                    },
                  ),
                  Text('パブリックにする'),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('本棚に追加'),
                  onPressed: _accountName!=''?() async {
                    final Timestamp date = Timestamp.fromDate(DateTime.now()); // 現在の日時
                    final email = widget.currentUser.email; // AddPostPage のデータを参照
                    // 投稿メッセージ用ドキュメント作成
                    late DocumentReference newBookRef;
                    if(isPublic == true){
                        newBookRef = await FirebaseFirestore.instance
                        .collection('users')
                        .doc("8ETzTCzHEj5N1zynrI89")
                        .collection('books') // コレクションID指定
                        .add({
                      // 'question': questionText,
                      // 'answer': answerText,
                      'email': email,
                      'creator' : _accountName,
                      'comment': commentText,
                      'date': date,
                      'name': nameText,
                      'creatorID': widget.currentUser.uid,
                      'next_num':1
                    });
                    }
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.currentUser.uid)
                        .collection('books') // コレクションID指定
                        .doc() // ドキュメントID自動生成
                        .set({
                      // 'question': questionText,
                      // 'answer': answerText,
                      'email': email,
                      'creator' : _accountName,
                      'comment': commentText,
                      'tag': tagText,
                      'date': date,
                      'isLatest': true,
                      'isChecked': false,
                      'name': nameText,
                      'isPublic': isPublic,
                      'publicID' : (isPublic == true) ? newBookRef.id : null,
                      'next_num' : 1
                    });
                    setState(() {});
                    // 1つ前の画面に戻る
                    Navigator.of(context).pop();
                  }:(){}
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}