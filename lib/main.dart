import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; //DBの定義

Database? db; //DBのインスタンスはDatabaseで定義します
// ignore: prefer_typing_uninitialized_variables
var controller;

Future<void> main() async {
  // 最初に表示するWidget
  debugPrint("初期化前");
  WidgetsFlutterBinding.ensureInitialized();
  //Vsyncを無効化 この行をrun.appの上からopenDatabaseの上に移動したら、起動した
  db = await openDatabase(
    // SQLite データベースを開くためのメソッド
    //DBの初期化
    'example.db', //データベースファイルの名前を表している
    version: 1, // onCreateを指定する場合はバージョンを指定する
    onCreate: (db, version) async {
      //SQLiteデータベースが初めて作成されるときに呼び出される関数
      await db.execute(
        //与えられた SQL 文をデータベース上で実行します。
        'CREATE TABLE IF NOT EXISTS todos ('
        '  id INTEGER PRIMARY KEY AUTOINCREMENT,' //AUTOINCREMENT=主キーの値を自動で設定
        '  content TEXT,'
        '  created_at INTEGER'
        ')',
      );
    },
  );
  debugPrint("初期化あと");
  runApp(const MyTodoApp());
}

class MyTodoApp extends StatelessWidget {
  //StatelessWidgetという親クラスをMyTodoAppクラスに継承する
  const MyTodoApp({super.key}); //const変数を変えない。super:親クラスのコンストラクタにkeyを渡す

  @override //親クラスのメソッドをサブクラスで上書きする
  Widget build(BuildContext context) {
    //BuildContextを受け取ってWidgetを返す.ここでのcontexは受け取り口
    return MaterialApp(
      // 右上に表示される"debug"ラベルを消す
      debugShowCheckedModeBanner: false,
      // アプリ名
      title: 'My Todo App',
      theme: ThemeData(
        //theme:デザインを簡単に変更できる。
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
  const TodoListPage({super.key}); //super:サブクラスから親クラスにアクセスするときに使用

  @override
  TodoListPageState createState() => //=>は右の結果を左に返す
      TodoListPageState(); //createStateはビルド後に呼ばれるメソッドで必須
}

class TodoListPageState extends State<TodoListPage> {
  late Future<List<Map<String, Object?>>>? todoListQuery;
  int selectedTabIndex = 0; //タブの選択状態を保持する変数
  @override
  void initState() {
    //StatefulWidgetで使用されるウィジェットの初期化時に呼び出されるメソッドです
    super.initState();
    controller =
        StreamController<int>(); //StreamControllerというクラスのインスタンスを作成するコード
    debugPrint("押した後");
    // タブごとに異なるクエリを実行
  }

  @override
  void dispose() {
    //ウィジェットやオブジェクトが不要になったときに、それらを解放しリソースをクリーンアップするためのメソッド
    controller.close(); //ストリームの終了やリソースの解放を行うためのメソッド
    super.dispose();
  }

  void _updateData() {
    controller.add(1); // データが更新されたことを通知
  }

  // Todoリストのデータ
  List<String> todoList = [];

  @override
  Widget build(BuildContext context) {
    //BuildContext:buildする時に情報を提供する。
    //tabバー
    // build メソッド内でクエリを設定
    switch (selectedTabIndex) {
      //ここから
      case 0:
        todoListQuery = db?.query(
          'todos',
          where: 'content LIKE ?',
          whereArgs: ['%%'], //ハードコード
          orderBy: 'created_at DESC',
        );
        break;
      case 1:
        todoListQuery = db?.query(
          'todos',
          where: 'content LIKE ?',
          whereArgs: ['%%'],
          orderBy: 'created_at DESC',
        );
        break;
      case 2:
        todoListQuery = db?.query(
          'todos',
          where: 'content LIKE ?',
          whereArgs: ['%%'],
          orderBy: 'created_at DESC',
        );
        break;
    } // ここまで
    return DefaultTabController(
      //タブバーとタブビューを組み合わせて使用する際に、デフォルトのコントローラを提供するものです
      length: 3,
      child: Scaffold(
        // AppBarを表示し、タイトルも設定
        appBar: AppBar(
          bottom: TabBar(
            tabs: const <Widget>[
              Tab(text: '卓球'),
              Tab(text: 'サッカー'),
              Tab(text: 'テニス'),
            ],
            onTap: (index) {
              setState(() {
                selectedTabIndex = index; //タブが選択されたときに変数を更新
              });
            },
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
            Expanded(
              //これでListView.builderをラップして、画面の残りの領域を使用できるようした
              child: StreamBuilder(
                  //Stream<int> stream = controller.stream;
                  //非同期処理が完了するまで表示する内容を指定し、非同期処理が完了した際にデータをもとにウィジェットツリーを再構築します
                  stream: todoListQuery!.asStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      //AsyncSnapshot オブジェクトの connectionState プロパティを確認するもの
                      //snapshot.hasData
                      debugPrint("hasdata called"); //コンソールにテキストを表示するために使用される
                      debugPrint(snapshot.data.toString());
                      return ListView.builder(
                        //ListView:縦方向や横方向にスクロール可能な項目のリストを作成するために使用されます
                        shrinkWrap: true, //ウィジェットが子要素に合わせて縮小されるかどうかを制御します。
                        //physics:const NeverScrollableScrollPhysics(), //スクロールができなくなる
                        itemCount:
                            snapshot.data!.length, //nullだった時にエラーを出す。アイテムの総数を表す
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(snapshot.data?[index]["content"]
                                      .toString() ?? //?はnullを許容する。
                                  "エラー"), //nullだった時に「エラー」を表示する。
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      debugPrint("haser called");
                      return const Text("エラー");
                    }
                    debugPrint("progress called");
                    return const CircularProgressIndicator(); //アプリケーションが何らかの処理を行っていることをユーザーに示すために使用されます。通常、非同期操作やデータの読み込みなど、処理が完了するまでに時間がかかる場面で使われます。
                  }),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // "push"で新規画面に遷移
            // リスト追加画面から渡される値を受け取る
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                // 遷移先の画面としてリスト追加画面を指定
                return TodoAddPage(tabIndex: selectedTabIndex);
              }),
            ).then((value) {
              // リスト追加画面から戻ってきたときにデータを更新
              _updateData();
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class TodoAddPage extends StatefulWidget {
  final int tabIndex; // タブの選択状態を保持する変数
  const TodoAddPage({Key? key, required this.tabIndex}) : super(key: key);

  @override
  TodoAddPageState createState() => TodoAddPageState();
}

class TodoAddPageState extends State<TodoAddPage> {
  // 入力されたテキストをデータとして持つ
  String _text = '';

  // データを元に表示するWidget
  @override
  Widget build(BuildContext context) {
    // タブの選択状態を使って適切な処理を行う
    switch (widget.tabIndex) {
      case 0:
        debugPrint("卓球");
        // 卓球の処理
        break;
      case 1:
        debugPrint("サッカー");
        // サッカーの処理
        break;
      case 2:
        debugPrint("テニス");
        // テニスの処理
        break;
      default:
        break;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('リスト追加'),
      ),
      body: Container(
        // 余白を付ける
        padding: const EdgeInsets.all(64), //上下左右の各方向に対して同じ値（ここでは64）の余白を作成する
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 入力されたテキストを表示
            Text(_text, style: const TextStyle(color: Colors.blue)),
            const SizedBox(height: 8),
            // テキスト入力
            TextField(
              // 入力されたテキストの値を受け取る（valueが入力されたテキスト）
              onChanged: (String value) {
                //ユーザーが特定の入力フィールドに対して入力を行った際に発火されるコールバック
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
                    'todos', // テーブル名
                    {
                      'content': _text, // カラム名: 値
                      'created_at': DateTime.now()
                          .millisecondsSinceEpoch, //データベースに新しいレコードを挿入する際に、そのレコードが作成された日時を表すための情報を設定しています。
                    },
                  ).then((value) => Navigator.of(context).pop(_text)); //.then
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
                onPressed: () {
                  // ボタンをクリックした時の処理
                  Navigator.of(context).pop(); // "pop"で前の画面に戻る
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
