import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; //DBの定義

Database? db;
Future<void> main() async {
  //awaitのエラーを解消するために導入した。
  // 最初に表示するWidget
  runApp(const MyTodoApp()); //

  db = await openDatabase(
    //DBの初期化
    //db=変数・await=非同期処理完了まで待ち、その結果を取り出す。
    'example.db',
    version: 1, // onCreateを指定する場合はバージョンを指定する
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE IF NOT EXISTS posts ('
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' //AUTOINCREMENT=主キーの値を自動で設定
        '  content TEXT,'
        '  created_at INTEGER'
        ')',
      );
    },
  );
}

class MyTodoApp extends StatelessWidget {
  const MyTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 右上に表示される"debug"ラベルを消す
      debugShowCheckedModeBanner: false,
      // アプリ名
      title: 'My Todo App',
      theme: ThemeData(
        // テーマカラー
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // リスト一覧画面を表示
      home: const TodoListPage(),
    );
  }
}

// リスト一覧画面用Widget
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  TodoListPageState createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  // Todoリストのデータ
  List<String> todoList = [];

  @override
  Widget build(BuildContext context) {
    //tabバー
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // AppBarを表示し、タイトルも設定
        appBar: AppBar(
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: '卓球'),
              Tab(text: 'サッカー'),
              Tab(text: 'テニス'),
            ],
          ),
          title: const Text('リスト'),
        ),
        // データを元にListViewを作成
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(20, 20),
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(2),
              ),
              child: const Text("検索バー"),
            ),
            FutureBuilder(
                future: db?.query(
                  'posts',
                  orderBy: 'created_at DESC', // ソート順
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true, //追加
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                                snapshot.data?[index]["content"].toString() ??
                                    "エラー"),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("エラー");
                  }
                  return CircularProgressIndicator();
                }),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // "push"で新規画面に遷移
            // リスト追加画面から渡される値を受け取る
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                // 遷移先の画面としてリスト追加画面を指定
                return const TodoAddPage();
              }),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class TodoAddPage extends StatefulWidget {
  const TodoAddPage({super.key});

  @override
  TodoAddPageState createState() => TodoAddPageState();
}

class TodoAddPageState extends State<TodoAddPage> {
  // 入力されたテキストをデータとして持つ
  String _text = '';

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('リスト追加'),
      ),
      body: Container(
        // 余白を付ける
        padding: const EdgeInsets.all(64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 入力されたテキストを表示
            Text(_text, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            // テキスト入力
            TextField(
              // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
              onChanged: (String value) async {
                // データが変更したことを知らせる（画面を更新する）
                setState(() {
                  // データを変更
                  _text = value;
                });
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // リスト追加ボタン
              child: ElevatedButton(
                onPressed: () async {
                  await db?.insert(
                    //DBに保存
                    'posts', // テーブル名
                    {
                      'content': _text, // カラム名: 値
                      'created_at': DateTime.now().millisecondsSinceEpoch,
                    },
                  );
                  // "pop"で前の画面に戻る
                  // "pop"の引数から前の画面にデータを渡す
                  Navigator.of(context).pop(_text);
                },
                child:
                    const Text('リスト追加', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              // 横幅いっぱいに広げる
              width: double.infinity,
              // キャンセルボタン
              child: TextButton(
                // ボタンをクリックした時の処理
                onPressed: () {
                  // "pop"で前の画面に戻る

                  Navigator.of(context).pop();
                },
                child: const Text('キャンセル'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
