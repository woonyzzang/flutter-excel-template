import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Map<String, dynamic>> dropdownList = [
    {'type': null, 'icon': null, 'name': '- Select -' ,'value': ''},
    {'type': 'html', 'icon': Icons.text_snippet, 'name': 'HTML Template', 'value': 'html_template.html'},
    {'type': 'html', 'icon': Icons.article_outlined, 'name': 'HTML Excel', 'value': 'html_i18n.xlsx'},
    {'type': 'json', 'icon': Icons.article_outlined, 'name': 'JSON Excel', 'value': 'json_i18n.xlsx'},
    {'type': 'resx', 'icon': Icons.article_outlined, 'name': 'RESX Excel', 'value': 'resx_i18n.xlsx'},
  ];
  String dropdownValue = '';

  /// downloadTemplate
  /// @description 템플릿 파일 다운로드
  void downloadTemplate(String type, String fileName) {
    String path = 'assets/upload'; // 다운로드할 파일 URL

    html.AnchorElement anchorElement = html.AnchorElement(href: '$path/$type/$fileName')
      ..setAttribute('download', fileName) // 파일명 설정
      ..click(); // 클릭 이벤트 발생

    anchorElement.target = '_blank'; //새창 열기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            // color: Colors.blue,
          ),
        ),
      ),
      drawer: Drawer(
        // backgroundColor: Colors.purpleAccent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              child: Center(
                child: Text(
                  'Excel2Template',
                  style: TextStyle(
                    fontSize: 28
                  ),
                ),
              ),
            ),

            ListTile(
              title: const Text(
                'Docs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Drawer 를 닫음
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pushNamed(context, '/docs');
                });
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.auto_stories_outlined, color: Colors.grey),
              title: const Text('.html'),
              onTap: () {
                Navigator.pop(context); // Drawer 를 닫음
                Future.delayed(const Duration(milliseconds: 300), () {
                  // Navigator.pushNamed(context, '/docs/html', arguments: '@guide/markup/README.md');
                  Navigator.pushNamed(context, '/docs/html');
                });
              },
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined, color: Colors.grey),
              title: const Text('.json'),
              onTap: () {
                Navigator.pop(context); // Drawer 를 닫음
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pushNamed(context, '/docs/json');
                });
              },
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: const Icon(Icons.auto_stories_outlined, color: Colors.grey),
              title: const Text('.resx'),
              onTap: () {
                Navigator.pop(context); // Drawer 를 닫음
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pushNamed(context, '/docs/resx');
                });
              },
              trailing: const Icon(Icons.chevron_right),
            ),

            // const Divider(),
          ]
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Support File format for',
                      style: TextStyle(
                        fontSize: 24,
                        // fontWeight: FontWeight.bold,
                        // color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/html');
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.code, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('.html'),
                        ],
                      ),
                    ),

                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/json');
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.data_object, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('.json'),
                        ],
                      )
                    ),

                    OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/resx');
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.code, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('.resx'),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 100),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Started with the Template Guide!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: dropdownValue, // 현재 선택된 값
                      // isDense: true,
                      // isExpanded: true,
                      focusColor: Colors.transparent,
                      items: dropdownList.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          value: item['value'] ?? '',
                          child: (item['icon'] != null)
                            ? Row(
                              children: [
                                Icon(item['icon']),
                                const SizedBox(width: 8),
                                Text(item['name']!),
                              ]
                            )
                            : Text(item['name']!)
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        // if (value != null && value != '') {
                        setState(() {
                          dropdownValue = value!;
                        });
                        // }
                      },
                    ),

                    const SizedBox(width: 14),

                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.download,
                        size: 20,
                      ),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero, // 모든 모서리를 직각으로 설정
                          ),
                        ),
                      ),
                      label: const Text('Download'),
                      onPressed: dropdownValue.isNotEmpty ? () {
                        // 현재 선택된 dropdownValue 에 해당 하는 항목 찾기
                        final selectedItem = dropdownList.firstWhere(
                              (item) => item['value'] == dropdownValue,
                          orElse: () => {'type': null}, // 만약 해당 항목이 없으면 기본값 설정
                        );

                        downloadTemplate(selectedItem['type']!, dropdownValue);
                      } : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
