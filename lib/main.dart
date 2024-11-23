import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:device_preview/device_preview.dart';

import 'package:flutter_excel_template/view/MainPage.dart';
import 'package:flutter_excel_template/view/HtmlPage.dart';
import 'package:flutter_excel_template/view/JsonPage.dart';
import 'package:flutter_excel_template/view/ResxPage.dart';
import 'package:flutter_excel_template/view/DocsPage.dart';

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
  // runApp(DevicePreview(
  //   enabled: !kReleaseMode,
  //   builder: (context) => const MyApp(), // Wrap your app
  // ));
}

// MyApp 클래스 외부 변수 정의
Map<String, String> pageTitle = {
  'main': 'Excel2Template',
  'sub': 'Conversion',
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '[Convert] ${pageTitle['main']}', // 웹 빌드 시 타이틀 태그에 사용.
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // scaffoldBackgroundColor: Colors.white,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => MainPage(title: '${pageTitle['main']} ${pageTitle['sub']}'),
        '/html': (_) => HtmlPage(title: '[HTML] :: ${pageTitle['main']} ${pageTitle['sub']}'),
        '/json': (_) => JsonPage(title: '[JSON] :: ${pageTitle['main']} ${pageTitle['sub']}'),
        '/resx': (_) => ResxPage(title: '[RESX] :: ${pageTitle['main']} ${pageTitle['sub']}'),
        '/docs': (_) => DocsPage(title: '[Guide] :: ${pageTitle['main']} ${pageTitle['sub']}', mdFile: '@guide/README.md'),
        '/docs/html': (_) => DocsPage(title: '[Guide > HTML] :: ${pageTitle['main']} ${pageTitle['sub']}', mdFile: '@guide/html/README.md'),
        '/docs/json': (_) => DocsPage(title: '[Guide > JSON] :: ${pageTitle['main']} ${pageTitle['sub']}', mdFile: '@guide/json/README.md'),
        '/docs/resx': (_) => DocsPage(title: '[Guide > RESX] :: ${pageTitle['main']} ${pageTitle['sub']}', mdFile: '@guide/resx/README.md'),
      }
    );
  }
}
