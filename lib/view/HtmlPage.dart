import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';

class HtmlPage extends StatefulWidget {
  const HtmlPage({super.key, required this.title});
  final String title;

  @override
  State<HtmlPage> createState() => _HtmlPageState();
}

class _HtmlPageState extends State<HtmlPage> {
  late Excel excel;
  late String htmlContent = '';
  late String processedCode = '';

  List<String> sheetNames = [];
  int selectedSheetIndex = 0;

  Map<String, String> jsonData = {};

  final TextEditingController _textControl = TextEditingController();
  var clipboard = '';

  /// copyToClipboard
  /// @description 클립보드 복사
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

  /// pasteFromClipboard
  /// @description 클립보드 데이터 삽입
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

  /// onChangeSheetName
  /// @description 시트명 변경 이벤트 핸들러
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

    if (processedCode.isNotEmpty) {
      updateProcessedCode();
    }
  }

  /// findExcelCellValue
  /// @description 엑셀 셀 값 찾기
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

      updateProcessedCode();
    }
  }

  /// updateProcessedCode
  /// @description 변환된 코드 업데이트
  Future<void> updateProcessedCode() async {
    RegExp exp = RegExp(r'{{@([A-Za-z]+\d+)}}');

    String nHtmlContent = htmlContent.replaceAllMapped(exp, (match) {
      // String? pattern = match.group(0); // 전체 패턴, 예: {{@B378}}
      String? cellName = match.group(1); // 패턴에서 추출한 키, 예: B378
      String? cellValue = findExcelCellValue(jsonData, cellName!);

      return cellValue ?? '';
    });

    setState(() {
      processedCode = nHtmlContent;
    });

    // print(processedHTML);
    _textControl.text = processedCode;
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
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
                      onPressed: processedCode.isNotEmpty ? () {
                        setState(() {
                          sheetNames = [];
                          // selectedSheetIndex = 0;
                          processedCode = '';
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
                      onPressed: processedCode.isNotEmpty ? copyToClipboard : null,
                    ),
                  ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}
