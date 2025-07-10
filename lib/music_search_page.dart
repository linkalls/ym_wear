import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';
import 'music_repository.dart';

class MusicSearchPage extends StatefulWidget {
  @override
  State<MusicSearchPage> createState() => _MusicSearchPageState();
}

class _MusicSearchPageState extends State<MusicSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    print('検索ボタンが押されました: ${_controller.text}');
    setState(() => _loading = true);
    final repo = MusicRepository();
    final results = await repo.searchMusic(_controller.text);
    print('検索結果: ${results.length}件');
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 260, // 丸画面でもはみ出さない幅
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.mic, color: Colors.white70),
                          tooltip: '音声検索',
                          onPressed: () async {
                            await PlatformInterfaceImpl().useVoiceCommand();
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: TextStyle(fontSize: 13, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '曲名・アーティスト・アルバム',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _search(),
                            textInputAction: TextInputAction.search,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(30),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: Colors.white),
                          onPressed: _search,
                          tooltip: '検索',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : _results.isEmpty
                        ? Center(
                            child: Text(
                              '検索結果なし',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            itemCount: _results.length,
                            separatorBuilder: (_, __) =>
                                Divider(color: Colors.white12, height: 1),
                            itemBuilder: (context, i) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 0,
                              ),
                              title: Text(
                                _results[i]['title'] ?? '',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                _results[i]['artist'] ?? '',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Colors.white24,
                              ),
                              onTap: () {
                                GoRouter.of(context).push(
                                  '/player/${_results[i]['id']}',
                                  extra: _results[i]['title'],
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
