import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart' as xml;

class ResxPage extends StatefulWidget {
  const ResxPage({super.key, required this.title});
  final String title;

  @override
  State<ResxPage> createState() => _ResxPageState();
}

class _ResxPageState extends State<ResxPage> {
  late Excel excel;
  late String htmlContent = '';
  late String processedCode = '';

  bool isFullCodeChecked = false;

  List<String> sheetNames = [];
  int selectedSheetIndex = 0;

  Map<String, String> jsonData = {};

  final TextEditingController _textControl = TextEditingController();
  var clipboard = '';

  /// copyToClipboard
  /// @description 클립보드 복사
  void copyToClipboard() {
    updateProcessedCode();
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

  /// convertToXml
  /// @description XML 구조 변환
  String convertToXml(Map<String, dynamic> json) {
    var builder = xml.XmlBuilder();

    // 스위치 버튼 활성 시 전체 코드 추가
    if (isFullCodeChecked) {
      builder.processing('xml', 'version="1.0" encoding="utf-8"');
      builder.element('root', nest: () {
        builder.comment('''
        
          Microsoft ResX Schema 
      
          Version 2.0
          
          The primary goals of this format is to allow a simple XML format 
          that is mostly human readable. The generation and parsing of the 
          various data types are done through the TypeConverter classes 
          associated with the data types.
          
          Example:
          
          ... ado.net/XML headers & schema ...
          <resheader name="resmimetype">text/microsoft-resx</resheader>
          <resheader name="version">2.0</resheader>
          <resheader name="reader">System.Resources.ResXResourceReader, System.Windows.Forms, ...</resheader>
          <resheader name="writer">System.Resources.ResXResourceWriter, System.Windows.Forms, ...</resheader>
          <data name="Name1"><value>this is my long string</value><comment>this is a comment</comment></data>
          <data name="Color1" type="System.Drawing.Color, System.Drawing">Blue</data>
          <data name="Bitmap1" mimetype="application/x-microsoft.net.object.binary.base64">
              <value>[base64 mime encoded serialized .NET Framework object]</value>
          </data>
          <data name="Icon1" type="System.Drawing.Icon, System.Drawing" mimetype="application/x-microsoft.net.object.bytearray.base64">
              <value>[base64 mime encoded string representing a byte array form of the .NET Framework object]</value>
              <comment>This is a comment</comment>
          </data>
                      
          There are any number of "resheader" rows that contain simple 
          name/value pairs.
          
          Each data row contains a name, and value. The row also contains a 
          type or mimetype. Type corresponds to a .NET class that support 
          text/value conversion through the TypeConverter architecture. 
          Classes that don't support this are serialized and stored with the 
          mimetype set.
          
          The mimetype is used for serialized objects, and tells the 
          ResXResourceReader how to depersist the object. This is currently not 
          extensible. For a given mimetype the value must be set accordingly:
          
          Note - application/x-microsoft.net.object.binary.base64 is the format 
          that the ResXResourceWriter will generate, however the reader can 
          read any of the formats listed below.
          
          mimetype: application/x-microsoft.net.object.binary.base64
          value   : The object must be serialized with 
                  : System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
                  : and then encoded with base64 encoding.
          
          mimetype: application/x-microsoft.net.object.soap.base64
          value   : The object must be serialized with 
                  : System.Runtime.Serialization.Formatters.Soap.SoapFormatter
                  : and then encoded with base64 encoding.
      
          mimetype: application/x-microsoft.net.object.bytearray.base64
          value   : The object must be serialized into a byte array 
                  : using a System.ComponentModel.TypeConverter
                  : and then encoded with base64 encoding.
        ''');

        builder.element('xsd:schema', attributes: {
          'id': 'root',
          'xmlns': '',
          'xmlns:xsd': 'http://www.w3.org/2001/XMLSchema',
          'xmlns:msdata': 'urn:schemas-microsoft-com:xml-msdata',
        }, nest: () {
          builder.element('xsd:import', attributes: {
            'namespace': 'http://www.w3.org/XML/1998/namespace',
          });
          builder.element('xsd:element', attributes: {
            'name': 'root',
            'msdata:IsDataSet': 'true',
          }, nest: () {
            builder.element('xsd:complexType', nest: () {
              builder.element('xsd:choice', attributes: {
                'maxOccurs': 'unbounded',
              }, nest: () {
                builder.element('xsd:element', attributes: {
                  'name': 'metadata',
                }, nest: () {
                  builder.element('xsd:complexType', nest: () {
                    builder.element('xsd:sequence', nest: () {
                      builder.element('xsd:element', attributes: {
                        'name': 'value',
                        'type': 'xsd:string',
                        'minOccurs': '0',
                      });
                    });
                    builder.element('xsd:attribute', attributes: {
                      'name': 'name',
                      'use': 'required',
                      'type': 'xsd:string',
                    });
                    builder.element('xsd:attribute', attributes: {
                      'name': 'type',
                      'type': 'xsd:string',
                    });
                    builder.element('xsd:attribute', attributes: {
                      'name': 'mimetype',
                      'type': 'xsd:string',
                    });
                    builder.element('xsd:attribute', nest: 'xml:space');
                  });
                });
              });
            });
          });
        });

        builder.element('resheader', attributes: {
          'name': 'resmimetype',
        }, nest: () {
          builder.element('value', nest: 'text/microsoft-resx');
        });
        builder.element('resheader', attributes: {
          'name': 'version',
        }, nest: () {
          builder.element('value', nest: '2.0');
        });
        builder.element('resheader', attributes: {
          'name': 'reader',
        }, nest: () {
          builder.element('value',
              nest: 'System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089');
        });
        builder.element('resheader', attributes: {
          'name': 'writer',
        }, nest: () {
          builder.element('value',
              nest: 'System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089');
        });

        json.forEach((key, value) {
          builder.element('data', attributes: {
            'name': key,
            'xml:space': 'preserve',
          }, nest: () {
            builder.element('value', nest: value.toString());
          });
        });
      });
    } else {
      json.forEach((key, value) {
        builder.element('data', attributes: {
          'name': key,
          'xml:space': 'preserve',
        }, nest: () {
          builder.element('value', nest: value.toString());
        });
      });
    }

    var xmlDoc = builder.buildDocument();
    var xmlString = xmlDoc.toXmlString(pretty: true);

    return xmlString;
  }

  /// onChangeSheetName
  /// @description 시트명 변경 이벤트 핸들러
  onChangeSheetName(index) {
    setState(() {
      selectedSheetIndex = index;
    });

    Sheet sheet = excel[sheetNames[index]];
    String key = '';
    Map<String, dynamic> jsonData = {};

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

    // print(jsonData);

    setState(() {
      processedCode = convertToXml(jsonData);
    });

    // if (processedHTML.isNotEmpty) {
    //   updateProcessedHTML();
    // }
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
  // Future<void> uploadTemplateFile() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['html'],
  //   );
  //
  //   // 파일 선택을 취소한 경우
  //   if (result == null) {
  //     print('File selection canceled');
  //
  //     return;
  //   }
  //
  //   if (result.files.isNotEmpty) {
  //     PlatformFile file = result.files.first;
  //
  //     // print(file.name);
  //     // print(file.bytes);
  //     // print(file.size);
  //     // print(file.extension);
  //     // print(file.path); // 에러 발생
  //
  //     htmlContent = utf8.decode(file.bytes as List<int>);
  //     // RegExp exp = RegExp(r'{{@([A-Za-z]+\d+)}}');
  //
  //     // setState(() {
  //     //   processedHTML = htmlContent.replaceAllMapped(exp, (match) {
  //     //     // String? pattern = match.group(0); // 전체 패턴, 예: {{@B378}}
  //     //     String? cellName = match.group(1); // 패턴에서 추출한 키, 예: B378
  //     //     String? cellValue = findExcelCellValue(jsonData, cellName!);
  //     //
  //     //     return cellValue!;
  //     //   });
  //     // });
  //
  //     updateProcessedCode();
  //   }
  // }

  /// updateProcessedCode
  /// @description 변환된 코드 업데이트
  Future<void> updateProcessedCode() async {
    // RegExp exp = RegExp(r'{{@([A-Za-z]+\d+)}}');
    //
    // String nHtmlContent = htmlContent.replaceAllMapped(exp, (match) {
    //   // String? pattern = match.group(0); // 전체 패턴, 예: {{@B378}}
    //   String? cellName = match.group(1); // 패턴에서 추출한 키, 예: B378
    //   String? cellValue = findExcelCellValue(jsonData, cellName!);
    //
    //   return cellValue ?? '';
    // });
    //
    // setState(() {
    //   processedHTML = nHtmlContent;
    // });

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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

                  const SizedBox(width: 10),

                  // [D] 스위치 버튼
                  Transform.scale(
                    scale: 1,
                    child: Checkbox(
                      value: isFullCodeChecked,
                      onChanged: processedCode.isNotEmpty ? (bool? value) {
                        setState(() {
                          isFullCodeChecked = value!;

                          onChangeSheetName(selectedSheetIndex);
                        });
                      } : null,
                    ),
                  ),
                  Text(
                    'Full Code',
                    style: TextStyle(
                      fontSize: 14,
                      color: processedCode.isNotEmpty ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
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
              // const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: sheetNames.isNotEmpty ? uploadTemplateFile : null,
              //   style: ElevatedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(0), // 사각형 모양
              //     ),
              //   ),
              //   child: const Text('Upload Template File'),
              // ),

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
                        isFullCodeChecked = false;
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
                    // onPressed: processedHTML.isNotEmpty ? copyToClipboard : null,
                    onPressed: sheetNames.isNotEmpty ? copyToClipboard : null,
                  ),

                  // Row(
                  //   children: [
                  //     Transform.scale(
                  //       scale: 0.8,
                  //       child: Switch(
                  //         value: isSwitched,
                  //         onChanged: processedCode.isNotEmpty ? (value) {
                  //           setState(() {
                  //             isSwitched = value;
                  //
                  //             onChangeSheetName(selectedSheetIndex);
                  //           });
                  //         } : null,
                  //       ),
                  //     ),
                  //     Text(
                  //       // isSwitched ? 'On' : 'Off',
                  //       'Full Source Code',
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         color: processedCode.isNotEmpty ? Colors.black : Colors.grey,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ]
              ),

              const SizedBox(height: 20),

              if (processedCode.isNotEmpty)
                // [D] 하이라이트 코드
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 1,
                    itemBuilder: (context, position) {
                      return Column(
                        children: <Widget>[
                          HighlightView(
                            processedCode,
                            language: 'json',
                            theme: githubTheme,
                            padding: const EdgeInsets.all(20),
                            // textStyle: const TextStyle(
                            //   fontFamily: 'SFMono-Regular, Consolas, Liberation Mono, Menlo, monospace'
                            // ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
