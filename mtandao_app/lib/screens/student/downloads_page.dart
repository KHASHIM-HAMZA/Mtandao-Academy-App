import 'package:flutter/material.dart';
import 'package:mtandao_app/screens/student/examination/download_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  @override
  Widget build(BuildContext context) {
    final downloadprovider = Provider.of<DownloadProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: Text(
          "My Downloads",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body:
          downloadprovider.downloads.isEmpty
              ? Center(
                child: Text(
                  "No downloads yet",
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: downloadprovider.downloads.length,
                itemBuilder: (context, index) {
                  final item = downloadprovider.downloads[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        "Downloaded on ${DateFormat('dd MMM, yyyy – hh:mm a').format(item.date)}",
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                      trailing: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              downloadprovider.deleteDownloadedItem(index);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
