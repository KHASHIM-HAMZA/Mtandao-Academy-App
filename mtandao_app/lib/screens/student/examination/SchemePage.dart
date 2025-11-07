import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Schemepage extends StatefulWidget {
  const Schemepage({super.key});

  @override
  State<Schemepage> createState() => _SchemepageState();
}

class _SchemepageState extends State<Schemepage> {
  Future<List<String>> _loadedScheme() async {
    await Future.delayed(Duration(seconds: 3));
    return ["hello", "today"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Learning Scheme",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 27, 88, 138),
      ),
      body: FutureBuilder<List<String>>(
        future: _loadedScheme(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error occured : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No uploaded scheme"));
          }
          final schemes = snapshot.data!;

          return ListView.builder(
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(schemes[index]));
            },
          );
        },
      ),
    );
  }
}
