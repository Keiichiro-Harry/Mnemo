import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  // Firebaseを初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Firestoreのインスタンスを取得
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // コレクションの参照
  CollectionReference collection = firestore.collection('users').doc('bviuAXAAPrOJBt0l5arv1mDeiHc2').collection('books').doc('VgX0M1h8yyhQHz6WDjvG').collection('content');

  // コレクション内の全てのドキュメントを取得
  QuerySnapshot querySnapshot = await collection.get();

  // 全てのドキュメントに新しいcreatorIDフィールドを設定
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    await collection.doc(doc.id).set({
      'bviuAXAAPrOJBt0l5arv1mDeiHc2', // ここに設定したい値を入れてください
    }, SetOptions(merge: true)); // SetOptionsを使用して既存のフィールドを保持
  }

  print('creatorIDフィールドの設定が完了しました。');
}