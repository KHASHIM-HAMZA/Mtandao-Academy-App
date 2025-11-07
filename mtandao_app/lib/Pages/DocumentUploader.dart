import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Document Uploader', home: DocumentUploader());
  }
}

class DocumentUploader extends StatefulWidget {
  @override
  _DocumentUploaderState createState() => _DocumentUploaderState();
}

class _DocumentUploaderState extends State<DocumentUploader> {
  List<dynamic> documents = [];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      var uri = Uri.parse('http://yourapi.com/upload'); // Replace with your API
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Uploaded successfully");
        fetchDocuments(); // Refresh list
      } else {
        print("Upload failed");
      }
    }
  }

  Future<void> fetchDocuments() async {
    var response = await http.get(
      Uri.parse('http://yourapi.com/documents'),
    ); // Replace with your API

    if (response.statusCode == 200) {
      setState(() {
        documents = json.decode(response.body);
      });
    }
  }

  void openDocument(String url) {
    // You can use open_file or url_launcher depending on the source
    // open_file can open local files
    // url_launcher is better for online files
    print("Open document: $url");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Documents')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickAndUploadFile,
            child: Text("Upload Document"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var doc = documents[index];
                return ListTile(
                  title: Text(doc['name']),
                  subtitle: Text(doc['type']),
                  onTap: () => openDocument(doc['url']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
