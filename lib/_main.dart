import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // [I] 데스크탑일 경우에만 사용 가능
  // WidgetsFlutterBinding.ensureInitialized();
  //
  // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //   await windowManager.ensureInitialized();
  //
  //   WindowOptions windowOptions = const WindowOptions(
  //     size: Size(300, 250),
  //     center: true,
  //     backgroundColor: Colors.transparent,
  //     skipTaskbar: false,
  //     titleBarStyle: TitleBarStyle.hidden,
  //   );
  //
  //   windowManager.waitUntilReadyToShow(windowOptions, () async {
  //     await windowManager.show();
  //     await windowManager.focus();
  //   });
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '[ZEMPOT] Excel2Template', // 웹 빌드 시 타이틀 태그에 사용.
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // scaffoldBackgroundColor: Colors.white,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      home: const MyHomePage(title: 'Excel2Template Conversion'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Excel excel;
  late String htmlContent = '';
  late String processedHTML = '';

  List<String> sheetNames = [];
  int selectedSheetIndex = 0;

  Map<String, String> jsonData = {};

  final TextEditingController _textControl = TextEditingController();
  var clipboard = '';

  void copyToClipboard() {
    // Clipboard.setData(ClipboardData(text: _textControl.text));
    Clipboard.setData(ClipboardData(text: _textControl.text)).then((_) {
      const snackBar = SnackBar(
        content: Text('Copy to Clipboard is complete!'),
        duration: Duration(seconds: 1, milliseconds: 250), // 1.25초
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  void pasteFromClipboard() async {
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);

    setState(() {
      clipboard = cdata?.text ?? '';
    });
  }

  /// uploadExcelFile
  /// @description 엑셀 파일 업로드
  Future<void> uploadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    // 파일 선택을 취소한 경우
    if (result == null) {
      print('File selection canceled');

      return;
    }

    if (result.files.isNotEmpty) {
      PlatformFile file = result.files.first;

      // print(file.name);
      // print(file.bytes);
      // print(file.size);
      // print(file.extension);
      // print(file.path); // 에러 발생

      excel = Excel.decodeBytes(file.bytes as List<int>);

      setState(() {
        sheetNames = excel.tables.keys.toList();
      });

      onChangeSheetName(selectedSheetIndex);
    }
  }

  /// 시트명 변경 이벤트 핸들러
  onChangeSheetName(index) {
    setState(() {
      selectedSheetIndex = index;
    });

    Sheet sheet = excel[sheetNames[index]];
    String key = '';
    jsonData = {};

    for (var row in sheet.rows) {
      for (var cell in row) {
        if (key.isEmpty) {
          key = cell?.value.toString() ?? '';
        } else {
          jsonData[key] = cell?.value.toString() ?? '';
          key = ''; // 다음 셀은 키로 처리
        }
      }
    }

    // print(json.encode(jsonData));

    if (processedHTML.isNotEmpty) {
      updateProcessedHTML();
    }
  }

  /// findExcelCellValue
  String? findExcelCellValue(json, String cellName) {
    for (var key in json.keys) {
      if (cellName == key) {
        return json[key];
      }
    }

    return null; // 찾지 못한 경우 null 반환
  }

  /// uploadTemplateFile
  /// @description HTML 템플릿 파일 업로드
  Future<void> uploadTemplateFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html'],
    );

    // 파일 선택을 취소한 경우
    if (result == null) {
      print('File selection canceled');

      return;
    }

    if (result.files.isNotEmpty) {
      PlatformFile file = result.files.first;

      // print(file.name);
      // print(file.bytes);
      // print(file.size);
      // print(file.extension);
      // print(file.path); // 에러 발생

      htmlContent = utf8.decode(file.bytes as List<int>);
      // RegExp exp = RegExp(r'{{@([A-Za-z]+\d+)}}');

      // setState(() {
      //   processedHTML = htmlContent.replaceAllMapped(exp, (match) {
      //     // String? pattern = match.group(0); // 전체 패턴, 예: {{@B378}}
      //     String? cellName = match.group(1); // 패턴에서 추출한 키, 예: B378
      //     String? cellValue = findExcelCellValue(jsonData, cellName!);
      //
      //     return cellValue!;
      //   });
      // });

      updateProcessedHTML();
    }
  }

  Future<void> updateProcessedHTML() async {
    RegExp exp = RegExp(r'{{@([A-Za-z]+\d+)}}');

    String nHtmlContent = htmlContent.replaceAllMapped(exp, (match) {
      // String? pattern = match.group(0); // 전체 패턴, 예: {{@B378}}
      String? cellName = match.group(1); // 패턴에서 추출한 키, 예: B378
      String? cellValue = findExcelCellValue(jsonData, cellName!);

      return cellValue ?? '';
    });

    setState(() {
      processedHTML = nHtmlContent;
    });

    // print(processedHTML);
    _textControl.text = processedHTML;
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // [D] 엑셀 업로드 파일
            ElevatedButton(
              onPressed: uploadExcelFile,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // 사각형 모양
                ),
              ),
              child: const Text('Upload Excel File'),
            ),
            // [D] 엑셀 시트명 라디오 컨트롤
            if (sheetNames.isNotEmpty)
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: sheetNames.asMap().entries.map((entry) {
                  int index = entry.key;
                  String name = entry.value;

                  return Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: selectedSheetIndex,
                        onChanged: onChangeSheetName,
                      ),
                      Text(name),
                    ],
                  );
                }).toList(),
              ),

            // [D] 템플릿 업로드 파일
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sheetNames.isNotEmpty ? uploadTemplateFile : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0), // 사각형 모양
                ),
              ),
              child: const Text('Upload Template File'),
            ),

            // [D] 클립보드 복사
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: processedHTML.isNotEmpty ? () {
                    setState(() {
                      sheetNames = [];
                      // selectedSheetIndex = 0;
                      processedHTML = '';
                    });
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('Reset', style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(width: 10),

                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.copy,
                    size: 20,
                  ),
                  label: const Text('Copy Converted to Clipboard!'),
                  onPressed: processedHTML.isNotEmpty ? copyToClipboard : null,
                ),
              ]
            )

            // OutlinedButton.icon(
            //   icon: const Icon(
            //     Icons.paste,
            //     size: 20,
            //   ),
            //   label: const Text('Paste to Clipboard'),
            //   onPressed: pasteFromClipboard,
            // ),

            // [D] 하이라이트 코드
            // const SizedBox(height: 20),
            // Expanded(
            //   child: ListView.builder(
            //     shrinkWrap: true,
            //     itemBuilder: (context, position) {
            //       return Column(
            //         children: <Widget>[
            //           HighlightView(
            //             processedHTML,
            //             language: 'html',
            //             theme: githubTheme,
            //           ),
            //         ],
            //       );
            //     },
            //   ),
            // ),

            // [D] 하이라이트 코드2
            // Expanded(
            //   child: FutureBuilder(
            //     future: updateProcessedHTML(), // 로딩할 데이터를 불러오는 비동기 함수
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         print('데이터가 로딩 중인 경우');
            //         return const CircularProgressIndicator();
            //       } else if (snapshot.hasError) {
            //         // 데이터 로딩 중 에러가 발생한 경우
            //         return Center(
            //           child: Text('Error: ${snapshot.error}'),
            //         );
            //       } else {
            //         // 데이터 로딩이 완료된 경우
            //         return ListView.builder(
            //           shrinkWrap: true,
            //           itemBuilder: (context, position) {
            //             return Column(
            //               children: <Widget>[
            //                 HighlightView(
            //                   processedHTML,
            //                   language: 'html',
            //                   theme: githubTheme,
            //                 ),
            //               ],
            //             );
            //           },
            //         );
            //       }
            //     },
            //   ),
            // )
          ],
        ),
      )
    );
  }
}
