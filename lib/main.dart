import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'music_player_page.dart';
import 'music_search_page.dart';
import 'offline_manager_page.dart';
import 'platform_interface.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(title: 'Wear Music'),
        routes: [
          GoRoute(
            path: 'player/:musicId',
            builder: (context, state) => MusicPlayerPage(
              musicId: state.pathParameters['musicId'],
              title: state.extra as String?,
            ),
          ),
        ],
      ),
    ],
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wear Music',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: TextStyle(fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 10),
        ),
      ),
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _pages = <Widget>[
    MusicSearchPage(),
    MusicPlayerPage(),
    OfflineManagerPage(),
  ];

  void _onItemTapped(int index) async {
    // Wear OS: デジタルクラウンで音量調整例
    if (index == 1) {
      await PlatformInterfaceImpl().adjustVolume(0.5); // 仮実装
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(child: SizedBox.expand(child: _pages[_selectedIndex])),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
      //     BottomNavigationBarItem(icon: Icon(Icons.music_note), label: '再生'),
      //     BottomNavigationBarItem(icon: Icon(Icons.download), label: 'オフライン'),
      //   ],
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

// Wear OS向けのプラットフォーム実装例
class PlatformInterfaceImpl implements PlatformInterface {
  @override
  Future<void> adjustVolume(double value) async {
    // TODO: Wear OSのデジタルクラウン連携やネイティブ連携実装
    debugPrint('音量調整: $value');
  }

  @override
  Future<void> useVoiceCommand() async {
    // TODO: Google Assistant連携
  }

  @override
  Future<int> getHeartRate() async {
    // TODO: フィットネスデータ取得
    return 0;
  }
}
