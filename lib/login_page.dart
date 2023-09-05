import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'screen_transition.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    if (_auth.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenTransition(_auth.currentUser!)),
      );
    }
  }

  Future<void> loginUser() async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ScreenTransition(userCredential.user!)),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ログインエラー：メールアドレスまたはパスワードが正しくありません。';
      });
    }
  }

  Future<void> createUser() async {
    try {
      final email =
          _emailController.text.trim(); // Remove leading/trailing spaces
      final password = _passwordController.text;
      final accountName =
          _accountNameController.text.trim(); // Remove leading/trailing spaces

      // Check for existing email and account name
      final emailSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      final accountNameSnapshot = await _firestore
          .collection('users')
          .where('account_name', isEqualTo: accountName)
          .get();

      if (accountName=="") {
        setState(() {
          _errorMessage = '新規アカウント作成エラー：ユーザーネームを入力してください。';
        });
        return;
      }

      if (emailSnapshot.docs.isNotEmpty) {
        setState(() {
          _errorMessage = '新規アカウント作成エラー：このメールアドレスは既に使用されています。';
        });
        return;
      }

      if (accountNameSnapshot.docs.isNotEmpty) {
        setState(() {
          _errorMessage = '新規アカウント作成エラー：このユーザーネームは既に使用されています。';
        });
        return;
      }

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'account_name': accountName,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ScreenTransition(userCredential.user!)),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage = '新規アカウント作成エラー：何かが間違っています。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン画面'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'メールアドレス',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'パスワード',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _accountNameController,
              decoration: InputDecoration(
                labelText: 'アカウント名(新規登録のみ)',
              ),
            ),
            ElevatedButton(
              onPressed: loginUser,
              child: Text('ログイン'),
            ),
            ElevatedButton(
              onPressed: createUser,
              child: Text('アカウントを新規作成'),
            ),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
            //ElevatedButton(
            //  onPressed: () {
            //    // ゲストログインの処理をここに記述
            //  },
            //  child: Text('ゲストログイン'),
            //),
          ],
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  final User currentUser;

  Home({required this.currentUser});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('アカウント名：$_accountName'),
            // ここにHomeのコンテンツを追加
          ],
        ),
      ),
    );
  }
}
