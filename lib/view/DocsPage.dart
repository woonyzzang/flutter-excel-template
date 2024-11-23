import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DocsPage extends StatefulWidget {
  const DocsPage({super.key, required this.title, required this.mdFile});
  final String title;
  final String mdFile;

  @override
  State<DocsPage> createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  late Future<String> mdContent;

  Future<String> loadMarkdown() async {
    return await rootBundle.loadString(widget.mdFile);
  }

  @override
  void initState() {
    super.initState();

    mdContent = loadMarkdown();
  }

  @override
  Widget build(BuildContext context) {
    // [D] Navigator.pushNamed 속성 arguments 값 가져오기
    // final args = ModalRoute.of(context)!.settings.arguments;
    // print(args);

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
        child: FutureBuilder(
          future: mdContent,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                selectable: true,
                data: snapshot.data!,
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: Colors.black),
                  h2: const TextStyle(fontWeight: FontWeight.w600, fontSize: 26, color: Color(0xff172b4d)),
                  blockquoteDecoration: const BoxDecoration(color: Color(0xffe9f2ff)),
                  code: const TextStyle(backgroundColor: Color(0xfff1f2f4), fontSize: 16),
                  codeblockPadding: const EdgeInsets.all(20),
                  codeblockDecoration: const BoxDecoration(color: Color(0xfff1f2f4)),
                  horizontalRuleDecoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.grey))),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
