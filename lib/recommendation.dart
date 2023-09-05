import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:sqflite/sqflite.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import './add_book_page.dart';
import './login_page.dart';
import './memory_game_recommendation.dart';
import './screen_transition.dart';
import './recom_cards.dart';
import 'bookshelf.dart';

class _Slidable extends StatefulWidget {
  final List<DocumentSnapshot<Object?>> documents;
  final int index;
  final User user;
  final String accountName;
  _Slidable({
    required this.documents,
    required this.index,
    required this.user,
    required this.accountName,
    // required this._selectedValue,
    Key? key,
  }) : super(key: key);

  @override
  State<_Slidable> createState() => __SlidableState();
}

class __SlidableState extends State<_Slidable> {
  var _selectedTag = "All";
  bool? shuffle = false;
  String isWho = '';
  String num_readers = 'loading...';
  bool _isProcessing = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> copyDocumentAndModify(String documentID) async {
    try {
      // Get the source document reference
      DocumentReference sourceDocRef = _firestore
          .collection('users')
          .doc('8ETzTCzHEj5N1zynrI89')
          .collection('books')
          .doc(documentID);

      // Get the source document data
      DocumentSnapshot sourceSnapshot = await sourceDocRef.get();
      Map<String, dynamic> sourceData =
          sourceSnapshot.data() as Map<String, dynamic>;

      final Timestamp date = Timestamp.fromDate(DateTime.now()); // 現在の日時
      // Modify the data (e.g., change a field or remove a field)
      sourceData['isLatest'] = true;
      sourceData['isPublic'] = false;
      sourceData['isChecked'] = false;
      sourceData['publicID'] = documentID;
      sourceData['tag'] = "";
      sourceData['date'] = date; // Change or add fields as needed
      // Create a new document reference in the destination location

      // Set the modified data in the new location
      DocumentReference destinationDocRef = _firestore
          .collection('users')
          .doc(widget.user.uid)
          .collection('books')
          .doc(); //本ごとにIDは固有にしたいから、コピーだけど違うIDにする
      await destinationDocRef.set(sourceData);
      await _firestore
          .collection('users')
          .doc('8ETzTCzHEj5N1zynrI89')
          .collection('books')
          .doc(documentID)
          .collection('readers')
          .doc(widget.user.uid) //ユーザーidを閲覧者idにする
          .set({
        'email': widget.user.email,
        'userName': widget.accountName,
        'userID': widget.user.uid,
        'date': date,
        'destinationID': destinationDocRef.id
      });

      // Get the content subcollection
      QuerySnapshot contentQuerySnapshot = await _firestore
          .collection('users')
          .doc('8ETzTCzHEj5N1zynrI89')
          .collection('books')
          .doc(documentID)
          .collection('content')
          .get();
      List<QueryDocumentSnapshot> contentDocuments = contentQuerySnapshot.docs;

      // Copy each content document to the destination collection
      for (QueryDocumentSnapshot contentDocument in contentDocuments) {
        Map<String, dynamic> contentData =
            contentDocument.data() as Map<String, dynamic>;
        contentData['stage'] = 1;
        contentData['isArchived'] = false;
        contentData['isChecked'] = false;
        await _firestore
            .collection('users')
            .doc(widget.user.uid)
            .collection('books')
            .doc(destinationDocRef.id)
            .collection('content')
            .doc(contentDocument.id) //コレクションの中のidは一致させることでアップデートを簡単にする
            .set(contentData);
      }
      print('Document copied and modified successfully');
      setState(() {
        Get.find<Controller>().selected.value = 1;
      }); //これ本当は画面をマイ本棚にすることでダブル追加を避けようとしたら、画面切り替わらない代わりにすぐIconButtonを更新してくれて解決した。
    } catch (error) {
      print('Error copying document: $error');
    }
  }

  Future<void> IconDecider() async {
    try {
      DocumentSnapshot bookSnapshot = await _firestore
          .collection('users')
          .doc('8ETzTCzHEj5N1zynrI89')
          .collection('books')
          .doc(widget.documents[widget.index].id)
          .get();

      Map<String, dynamic> bookData =
          bookSnapshot.data() as Map<String, dynamic>;
      bool isCreator = widget.user.uid == bookData['creatorID'];

      DocumentSnapshot readerSnapshot = await _firestore
          .collection('users')
          .doc('8ETzTCzHEj5N1zynrI89')
          .collection('books')
          .doc(widget.documents[widget.index].id)
          .collection('readers')
          .doc(widget.user.uid)
          .get();

      bool isReader = readerSnapshot.exists;

      if (isCreator) {
        isWho = 'Creator'; //ここsetStateにしたら永遠にぐるぐるする現象起きた
      } else if (isReader) {
        isWho = 'Reader';
      } else {
        isWho = 'Other';
      }
      //print(isWho);
    } catch (error) {
      print('Error determining user role: $error');
      isWho = 'Other';
    }
  }

  Future<void> numReaders() async {
    try {
      QuerySnapshot readersSnapshot = await _firestore
          .collection('users')
          .doc('8ETzTCzHEj5N1zynrI89')
          .collection('books')
          .doc(widget.documents[widget.index].id)
          .collection('readers')
          .get();
      num_readers = readersSnapshot.size.toString();
      //print(num_readers);
    } catch (error) {
      print('Error determining the number of readers: $error');
      num_readers = "error"; // Handle errors by assuming default role
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: UniqueKey(),
      child: Card(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
            onTap: () async {
              // 投稿画面に遷移
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return RecomCards(
                      widget.user, widget.documents[widget.index]);
                }),
              );
            },
            //leading: documents[index]['image'],
            title: Text(widget.documents[widget.index]['name']),
            subtitle: FutureBuilder<void>(
                future: numReaders(),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Text(
                        "読者${num_readers} ${widget.documents[widget.index]['comment']} by ${widget.documents[widget.index]['creator']}");
                  } else {
                    return Text(
                        "creator: ${widget.documents[widget.index]['creator']}, reader: loading");
                  }
                })),
            // 自分の投稿メッセージの場合は削除ボタンを表示
            leading: FutureBuilder<void>(
              future: IconDecider(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Determine the role of the user based on the query results
                  if (isWho == 'Creator') {
                    return IconButton(
                      icon: Icon(Icons.person),
                      onPressed: () async {
                        // ...
                      },
                    );
                  } else if (isWho == 'Reader') {
                    return IconButton(
                      icon: Icon(Icons.download_done),
                      onPressed: () async {
                        // ...
                      },
                    );
                  } else {
                    return IconButton(
                      icon: Icon(Icons.download),
                      onPressed: () async {
                        await showDialog<int>(
                            context: context,
                            barrierDismissible: false, //ここ？
                            builder: (BuildContext context) {
                              //print(isWho);
                              return StatefulBuilder(
                                  //できた！！！https://stackoverflow.com/questions/51962272/how-to-refresh-an-alertdialog-in-flutter
                                  builder: (context, setState) {
                                return Dialog(
                                    child: Container(
                                  // alignment:
                                  width: 400,
                                  height: 200,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                            widget.documents[widget.index]
                                                ['name'],
                                            style: TextStyle(fontSize: 30)),
                                        Text(
                                            "by " +
                                                widget.documents[widget.index]
                                                    ['creator'],
                                            style: TextStyle(fontSize: 20)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: _isProcessing
                                                  ? null
                                                  : () =>
                                                      Navigator.pop(context),
                                            ),
                                            TextButton(
                                              child: Text("マイ本棚に追加"),
                                              onPressed: _isProcessing
                                                  ? null
                                                  : () async {
                                                      setState(() {
                                                        _isProcessing =
                                                            true; // ここでフラグを設定
                                                      }); // フラグの変更を反映
                                                      try {
                                                        await copyDocumentAndModify(
                                                            widget
                                                                .documents[
                                                                    widget
                                                                        .index]
                                                                .id);
                                                        // 他のファイルからのアクセス例
                                                        Navigator.pop(context);
                                                      } catch (e) {
                                                        // エラーが発生した場合の処理
                                                        print('エラーが発生しました: $e');
                                                        setState(() {
                                                          _isProcessing =
                                                              false; // エラー時にフラグを設定
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "構文エラーまたは接続エラー"),
                                                          ),
                                                        );
                                                      }
                                                    },
                                            ),
                                          ],
                                        ),
                                        if (_isProcessing)
                                          CircularProgressIndicator(),
                                      ]),
                                ));
                              });
                            });
                      },
                    );
                  }
                } else {
                  return IconButton(
                    icon: Icon(Icons.download),
                    onPressed: null, // Disable the button while loading
                  );
                }
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.verified),
              onPressed: () async {
                await showDialog<int>(
                    context: context,
                    barrierDismissible: false, //ここ？
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          //できた！！！https://stackoverflow.com/questions/51962272/how-to-refresh-an-alertdialog-in-flutter
                          builder: (context, setState) {
                        return Dialog(
                            child: Container(
                          // alignment:
                          width: 400,
                          height: 200,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(widget.documents[widget.index]['name'],
                                    style: TextStyle(fontSize: 30)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('tag'),
                                    ),
                                    Flexible(
                                      child: StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('users')
                                              .doc("8ETzTCzHEj5N1zynrI89")
                                              .collection('books')
                                              .doc(widget
                                                  .documents[widget.index].id)
                                              .collection('content')
                                              .orderBy('number')
                                              // .endBefore(["中枢神経", "questoion"])
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data != null) {
                                                final List<DocumentSnapshot>
                                                    documents =
                                                    snapshot.data!.docs;
                                                // print("OKK1");
                                                var tagList = <String>["All"];
                                                // tagList.add(
                                                //     'All'); //???なんかよくわからんけど空白とallがいる
                                                // List<String> tagList = [];
                                                // tagList.add("All");
                                                for (var value in documents) {
                                                  if (value["tag"] != "") {
                                                    tagList.add(value['tag']);
                                                  }
                                                }
                                                // tagList.toSet().toList();
                                                tagList =
                                                    tagList.toSet().toList();
                                                //print(tagList);
                                                //print(_selectedTag);
                                                return DropdownButton<String>(
                                                  value: _selectedTag,
                                                  items: tagList
                                                      .map((String list) =>
                                                          DropdownMenuItem(
                                                              value: list,
                                                              child:
                                                                  Text(list)))
                                                      .toList(),
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _selectedTag = value!;
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
                                    Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Text('shuffle'),
                                    ),
                                    Checkbox(
                                      value: shuffle,
                                      onChanged: (bool? newValue) {
                                        setState(() {
                                          shuffle = newValue;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      child: Text("Cancel"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text("Game Start"),
                                      onPressed: () async {
                                        // 投稿画面に遷移
                                        if (_selectedTag != "") {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                              return MemoriaGame(
                                                  widget.user,
                                                  widget
                                                      .documents[widget.index],
                                                  _selectedTag,
                                                  shuffle);
                                            }),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ]),
                        ));
                      });
                    });
              },
            ))
      ])),
    );
  }
}

class Recommendation extends StatefulWidget {
  // ユーザー情報
  final User currentUser;
  Recommendation({required this.currentUser});
  @override
  _RecommendationState createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
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
          .doc(widget.currentUser.uid) //uid : user id
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
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Text('ログイン情報：$_accountName'),
          ),
          Expanded(
            // FutureBuilder
            // 非同期処理の結果を元にWidgetを作れる
            child: StreamBuilder<QuerySnapshot>(
              // 投稿メッセージ一覧を取得（非同期処理）
              // 投稿日時でソート
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc("8ETzTCzHEj5N1zynrI89")
                  .collection('books')
                  .orderBy('date', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                // データが取得できた場合
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    final List<DocumentSnapshot> documents =
                        snapshot.data!.docs;
                    // 取得した投稿メッセージ一覧を元にリスト表示
                    return ListView.builder(
                      //参照⇨https://zenn.dev/ryota_iwamoto/articles/slidable_list_like_iphone_mail
                      itemCount: documents.length,
                      itemBuilder: (context, int index) {
                        //TODO 後で消す
                        //print('イメージ：${documents[index]['email']}');
                        //ここはdocumentsの中身の構造なのかな？Todo!
                        //if (documents[index]['email'] == widget.user.email) {
                        return _Slidable(
                          documents: documents,
                          index: index,
                          user: widget.currentUser,
                          accountName: _accountName,
                          // _selectedValue: '',
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                }
                // データが読込中の場合
                return const Center(
                  child: Text('読込中...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
