import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:sqflite/sqflite.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import './setting.dart';

class Account extends StatefulWidget {
  //参照⇨https://qiita.com/agajo/items/50d5d7497d28730de1d3
  // ユーザー情報
  final User currentUser;
  Account({required this.currentUser});
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
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

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(padding: EdgeInsets.all(8), child: Text('ログイン情報：')),
                  Container(
                      padding: EdgeInsets.all(8),
                      child: Text('アカウント名：$_accountName')),
                  Container(
                      padding: EdgeInsets.all(8),
                      child: Text('メールアドレス：${widget.currentUser.email}')),

                  // Container(
                  //     padding: EdgeInsets.all(8),
                  //     child: Text('ログイン情報：${widget.currentUser.email}')),
                  // Container(
                  //   height: 50,
                  //   child: const Text('設定',
                  //       style: TextStyle(color: Colors.white, fontSize: 32.0)),
                  //   alignment: Alignment.center,
                  //   decoration: const BoxDecoration(
                  //     gradient: LinearGradient(
                  //         begin: Alignment.topRight,
                  //         end: Alignment.bottomLeft,
                  //         colors: [Colors.blue, Colors.white]),
                  //   ),
                  // ),
                ],
              ))),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        onPressed: () async {
          // 投稿画面に遷移
          if (widget.currentUser.email != "guest@guest.com") {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return Setting(currentUser: widget.currentUser);
              }),
            );
          }
        },
      ),
    );
  }
}
