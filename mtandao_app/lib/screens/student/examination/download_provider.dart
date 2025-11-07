import 'package:flutter/material.dart';

class DownloadItem {
  final String name;
  final String path;
  final DateTime date;

  DownloadItem({required this.name, required this.path, required this.date});
}

class DownloadProvider with ChangeNotifier {
  final List<DownloadItem> _downloads = [];

  List<DownloadItem> get downloads => List.unmodifiable(_downloads);

  void addDownloadItem(DownloadItem item) {
    _downloads.insert(0, item);
    notifyListeners();
  }

  void deleteDownloadedItem(int index) {
    _downloads.remove(index);
    notifyListeners();
  }
}
