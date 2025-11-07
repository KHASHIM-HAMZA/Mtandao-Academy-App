import 'package:flutter/material.dart';

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  Future<String> getWeb() async {
    await Future.delayed(Duration(seconds: 3));

    return "Name: Hyskay";

    // if (result.statusCode == 200) {
    //   return jsonDecode(result.body);
    // } else {
    //   throw Exception("fail to load");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Future App"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: getWeb(),
          builder: (context, snapshot) {
            //still waiting
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            //if error happen
            else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "ERRO HAS OCCURED: ${snapshot.error}",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
              );
            }
            //if success
            else if (snapshot.hasData) {
              return Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "WELCOME",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(child: Text('hello ${snapshot.data}')),
                ],
              );
            } else {
              return Text("data isnt available;");
            }
          },
        ),
      ),
    );
  }
}
