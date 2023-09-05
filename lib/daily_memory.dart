import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:sqflite/sqflite.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import './add_book_page.dart';
import './login_page.dart';
import './memory_game.dart';
import './screen_transition.dart';
import './add_dailymemory_page.dart';
import './bookcards.dart';
import './dailycards.dart';

class _Slidable extends StatefulWidget {
  final List<DocumentSnapshot<Object?>> documents;
  final int index;
  final User user;
  _Slidable({
    required this.documents,
    required this.index,
    required this.user,
    // required this._selectedValue,
    Key? key,
  }) : super(key: key);

  @override
  State<_Slidable> createState() => __SlidableState();
}

class __SlidableState extends State<_Slidable> {
  bool isReviewDays(String targetDate) {
    DateTime currentDate = DateTime.now();
    DateTime parsedTargetDate = DateTime.parse(targetDate);
    final difference = currentDate.difference(parsedTargetDate).inDays;
    return difference == 0 ||
        difference == 1 ||
        difference == 3 ||
        difference == 6 ||
        difference == 13 ||
        difference == 27;
  }
  Future<void> colorDecider(
      {required String bookType,
      required User user,
      required String documentID}) async {
    final CollectionReference _collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(bookType)
        .doc(documentID)
        .collection('content');

    bool allDocumentsAreStage5 = true;

    try {
      QuerySnapshot querySnapshot = await _collection.get();

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        //print(data['stage']);

        if (data.containsKey('stage') && data['stage'] != 5) {
          allDocumentsAreStage5 = false;
          break;
        }
      }
    } catch (error) {
      print('Error: $error');
      mastered = false;
    }

    mastered = allDocumentsAreStage5;
  }

  bool mastered = false;
  String tagText = '';
  var _selectedTag = "All";
  var _selectedStage = "All";
  bool? shuffle = false;
  @override
  Widget build(BuildContext context) {
    return Slidable(
      // enabled: false, // falseにすると文字通りスライドしなくなります
      // closeOnScroll: false, // *2
      // dragStartBehavior: DragStartBehavior.start,
      key: UniqueKey(),
      startActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
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
                              // Text(
                              //     "by " +
                              //         widget.documents[widget.index]['creator'],
                              //     style: TextStyle(fontSize: 20)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text("本を削除"),
                                    onPressed: () async {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.user.uid)
                                          .collection('daily_memory')
                                          .doc(
                                              widget.documents[widget.index].id)
                                          .delete();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              )
                            ]),
                      ));
                    });
                  });
            },
            backgroundColor: const Color.fromARGB(255, 48, 89, 115), // (4)
            foregroundColor: const Color.fromARGB(255, 222, 213, 196),
            icon: Icons.delete,
            label: '削除',
          )
        ],
      ),
      // endActionPane: ActionPane(
      //   // (2)
      //   extentRatio: 0.5,
      //   motion: const StretchMotion(), // (5)
        // dismissible: DismissiblePane(onDismissed: () {
        //   setState(() {
        //     //ここ逆だと、一瞬removeAtで消えたやつの次のやつが間違って消される。
        //     //documentsで消しても大元が消えてないから
        //     //FirebaseFirestore.instance
        //     // .collection('books')
        //     // .doc(widget.documents[widget.index].id)
        //     // .delete();危ないから消しとく
        //     //widget.documents.removeAt(widget.index);
        //     ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('message cannot dismissed')));
        //   });
        // }),
        // children: [
          // SlidableAction(
          //   // (3)
          //   onPressed: (_) {
          //     FirebaseFirestore.instance
          //         .collection('users')
          //         .doc(widget.user.uid)
          //         .collection('daily_memory')
          //         .doc(widget.documents[widget.index].id)
          //         .update({'isChecked': true});
          //   }, // (4)
          //   backgroundColor: const Color.fromARGB(255, 48, 89, 115), // (4)
          //   foregroundColor: const Color.fromARGB(255, 249, 249, 249), // (4)
          //   icon: Icons.chair_rounded, // (4)
          //   label: '詳細',
          // ),
          // SlidableAction(
          //   // (3)
          //   onPressed: (_) {
          //     FirebaseFirestore.instance
          //         .collection('users')
          //         .doc(widget.user.uid)
          //         .collection('daily_memory')
          //         .doc(widget.documents[widget.index].id)
          //         .update({'isChecked': true});
          //   },
          //   backgroundColor: const Color.fromARGB(255, 48, 89, 115), // (4)
          //   foregroundColor: const Color.fromARGB(255, 222, 213, 196),
          //   icon: Icons.flag,
          //   label: 'Flag',
          // ),
          // SlidableAction(
          //   // (3)
          //   onPressed: (_) {
          //     //FirebaseFirestore.instance
          //     // .collection('books')
          //     // .doc(widget.documents[widget.index].id)
          //     // .delete();危ないから消しとく
          //   },
          //   backgroundColor: const Color.fromARGB(255, 48, 89, 115), // (4)
          //   foregroundColor: const Color.fromARGB(255, 239, 126, 86),
          //   icon: Icons.delete,
          //   label: '消去',
          // ),
        // ],
      // ),
      child: FutureBuilder(
            future: colorDecider(
                bookType: 'daily_memory',
                user: widget.user,
                documentID: widget.documents[widget.index].id),
            builder: ((context, snapshot) {
      return Card(color: mastered
                      // ? Colors.deepPurple[100]
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).cardColor,
          // child: Column(
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[
          //     ListTile(
          //       leading: Image.network(
          //           'https://images-na.ssl-images-amazon.com/images/I/51HRqCnj7SL._SX344_BO1,204,203,200_.jpg'),
          //       title: Text('完訳 7つの習慣~人格主義の回復~'),
          //       subtitle: Text('送料無料'),
          //     ),
          //     Row(
          //       mainAxisAlignment: MainAxisAlignment.end,
          //       children: <Widget>[
          //         TextButton(
          //           child: const Text('詳細'),
          //           onPressed: () {/* ... */},
          //         ),
          //         const SizedBox(width: 8),
          //         TextButton(
          //           child: const Text('今すぐ購入'),
          //           onPressed: () {/* ... */},
          //         ),
          //         const SizedBox(width: 8),
          //       ],
          //     ),
          //   ],
          // ),

          //TODO ここでエラー
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        ListTile(
            onTap: () async {
              // 投稿画面に遷移
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return DailyCards(
                      widget.user, widget.documents[widget.index]);
                }),
              );
            },
            //leading: documents[index]['image'],
            title: Text(widget.documents[widget.index]['name']),
            subtitle: Text(widget.documents[widget.index]['creator']),
            // 自分の投稿メッセージの場合は削除ボタンを表示
            leading: IconButton(
              icon: const Icon(Icons.star_rounded),
              onPressed: () async {},
              color: isReviewDays(widget.documents[widget.index]["name"])
                  ? Colors.amber[600]
                  : Theme.of(context).dividerColor,
            ),
            trailing: widget.documents[widget.index]['email'] ==
                    widget.user.email
                ? IconButton(
                    icon: const Icon(Icons.verified),
                    onPressed: () async {
                      // 投稿メッセージのドキュメントを削除
                      // await FirebaseFirestore.instance
                      //     .collection('posts')
                      //     .doc(documents[index].id)
                      //     .delete();

//
                      await showDialog<int>(
                          context: context,
                          barrierDismissible: false, //ここ？
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                                //できた！！！https://stackoverflow.com/questions/51962272/how-to-refresh-an-alertdialog-in-flutter
                                builder: (context, setState) {
                              return Dialog(
                                  child: SizedBox(
                                // alignment:
                                width: 400,
                                height: 200,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                          widget.documents[widget.index]
                                              ['name'],
                                          style: TextStyle(fontSize: 30)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text('tag'),
                                          ),
                                          Flexible(
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(widget.user.uid)
                                                    .collection('daily_memory')
                                                    .doc(widget
                                                        .documents[widget.index]
                                                        .id)
                                                    .collection('content')
                                                    .orderBy('number',
                                                        descending: true)
                                                    // .endBefore(["中枢神経", "questoion"])
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    if (snapshot.data != null) {
                                                      final List<
                                                              DocumentSnapshot>
                                                          documents =
                                                          snapshot.data!.docs;
                                                      // print("OKK1");
                                                      var tagList = <String>[
                                                        "All"
                                                      ];
                                                      // tagList.add(
                                                      //     'All'); //???なんかよくわからんけど空白とallがいる
                                                      // List<String> tagList = [];
                                                      // tagList.add("All");
                                                      for (var value
                                                          in documents) {
                                                        if (value['tag'] !=
                                                            "") {
                                                          tagList.add(
                                                              value['tag']);
                                                        }
                                                      }
                                                      // tagList.toSet().toList();
                                                      tagList = tagList
                                                          .toSet()
                                                          .toList();
                                                      //print(tagList);
                                                      //print(_selectedTag);
                                                      return DropdownButton<
                                                          String>(
                                                        value: _selectedTag,
                                                        items: tagList
                                                            .map((String
                                                                    list) =>
                                                                DropdownMenuItem(
                                                                    value: list,
                                                                    child: Text(
                                                                        list)))
                                                            .toList(),
                                                        onChanged:
                                                            (String? value) {
                                                          setState(() {
                                                            _selectedTag =
                                                                value!;
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
                                          Padding(padding: EdgeInsets.all(4)),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text('stage'),
                                          ),
                                          Flexible(
                                            //stage選択
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(widget.user.uid)
                                                    .collection('daily_memory')
                                                    .doc(widget
                                                        .documents[widget.index]
                                                        .id)
                                                    .collection("content")
                                                    .orderBy('number')
                                                    // .endBefore(["中枢神経", "question"])
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    if (snapshot.data != null) {
                                                      //print("in snapshot data");
                                                      final List<
                                                              DocumentSnapshot>
                                                          documents =
                                                          snapshot.data!.docs;
                                                      // print("OKK1");
                                                      var stageList = <String>[
                                                        "All"
                                                      ];
                                                      // stageList.add(
                                                      //     'All'); //???なんかよくわからんけど空白とallがいる
                                                      // List<String> tagList = [];
                                                      // tagList.add("All");
                                                      for (var value
                                                          in documents) {
                                                        stageList.add(
                                                            value['stage']
                                                                .toString());
                                                      }
                                                      // tagList.toSet().toList();
                                                      stageList = stageList
                                                          .toSet()
                                                          .toList();
                                                      //print(stageList);
                                                      //print(_selectedStage);
                                                      // return DropdownButton<String>(
                                                      //   value: _selectedStage,
                                                      //   onChanged: (newValue) {
                                                      //     setState(() {
                                                      //       _selectedStage =
                                                      //           newValue!;
                                                      //     });
                                                      //   },
                                                      //   items: stageList.map<
                                                      //           DropdownMenuItem<
                                                      //               String>>(
                                                      //       (String value) {
                                                      //     return DropdownMenuItem<
                                                      //         String>(
                                                      //       value: value,
                                                      //       child: Text(value),
                                                      //     );
                                                      //   }).toList(),
                                                      // );
                                                      return DropdownButton<
                                                          String>(
                                                        value: _selectedStage,
                                                        items: stageList
                                                            .map((String
                                                                    list) =>
                                                                DropdownMenuItem(
                                                                    value: list,
                                                                    child: Text(
                                                                        list)))
                                                            .toList(),
                                                        onChanged:
                                                            (String? value) {
                                                          setState(() {
                                                            _selectedStage =
                                                                value!;
                                                            //print(value);
                                                            //print(_selectedStage);
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          TextButton(
                                            child: Text("Game Start"),
                                            onPressed: () async {
                                              // 投稿画面に遷移
                                              if (_selectedTag != "" &&
                                                  _selectedStage != "") {
                                                int _selectedStageInt;
                                                if (_selectedStage == "All") {
                                                  _selectedStageInt = 0;
                                                } else {
                                                  _selectedStageInt =
                                                      int.parse(_selectedStage);
                                                }
                                                await Navigator.of(context)
                                                    .push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                    return MemoriaGame(
                                                        widget.user,
                                                        widget.documents[
                                                            widget.index],
                                                        _selectedTag,
                                                        _selectedStageInt,
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

                            //   }),
                            // );
                          });
                    },
                  )
                : null)
      ]));}))
    );
  }
}

class DailyMemory extends StatefulWidget {
  // ユーザー情報
  final User currentUser;
  DailyMemory({required this.currentUser});
  @override
  _DailyMemoryState createState() => _DailyMemoryState();
}

class _DailyMemoryState extends State<DailyMemory> {
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
                  .doc(widget.currentUser.uid)
                  .collection('daily_memory')
                  .orderBy('date', descending: true)
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
                          // _selectedValue: '',
                        );
                      },

                      //} else {
                      // return Slidable(
                      //   // enabled: false,
                      //   startActionPane: ActionPane(
                      //     extentRatio: 0.2,
                      //     motion: const ScrollMotion(),
                      //     children: [
                      //       documents[index]['isChecked']
                      //           ? SlidableAction(
                      //               onPressed: (_) {
                      //                 //参照⇨https://www.wakuwakubank.com/posts/723-firebase-firestore-query/
                      //                 FirebaseFirestore.instance
                      //                     .collection('posts')
                      //                     .doc(documents[index].id)
                      //                     .update({
                      //                   //参照⇨https://www.wakuwakubank.com/posts/723-firebase-firestore-query/
                      //                   'isChecked': false
                      //                   //updatedAt: firebase.firestore.FieldValue.serverTimestamp();
                      //                 });
                      //               },
                      //               backgroundColor: const Color.fromARGB(
                      //                   255, 48, 89, 115), // (4)
                      //               foregroundColor: const Color.fromARGB(
                      //                   255, 222, 213, 196),
                      //               icon: Icons.star,
                      //               label: 'Unread',
                      //             )
                      //           : SlidableAction(
                      //               onPressed: (_) {
                      //                 FirebaseFirestore.instance
                      //                     .collection('posts')
                      //                     .doc(documents[index].id)
                      //                     .update({'isChecked': true});
                      //               },
                      //               backgroundColor: const Color.fromARGB(
                      //                   255, 48, 89, 115), // (4)
                      //               foregroundColor: const Color.fromARGB(
                      //                   255, 239, 126, 86),
                      //               icon: Icons.star,
                      //               label: 'Read',
                      //             )
                      //     ],
                      //   ),
                      //   child: Card(
                      //     child: ListTile(
                      //         title: Text(documents[index]['text']),
                      //         subtitle: Text(documents[index]['email']),
                      //         // 自分の投稿メッセージの場合は削除ボタンを表示
                      //         trailing: documents[index]['email'] ==
                      //                 widget.user.email
                      //             ? IconButton(
                      //                 icon: const Icon(Icons.delete),
                      //                 onPressed: () async {
                      //                   // 投稿メッセージのドキュメントを削除
                      //                   await FirebaseFirestore.instance
                      //                       .collection('posts')
                      //                       .doc(documents[index].id)
                      //                       .delete();
                      //                 },
                      //               )
                      //             : null),
                      //   ),
                      // );
                      //}
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // 投稿画面に遷移
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddDailyMemoryPage(currentUser: widget.currentUser);
            }),
          );
        },
      ),
    );
  }
}
