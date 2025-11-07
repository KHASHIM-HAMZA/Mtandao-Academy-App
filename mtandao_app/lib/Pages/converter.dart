import 'package:flutter/material.dart';

class Converter extends StatefulWidget {
  const Converter({super.key});

  @override
  State<Converter> createState() => _ConverterState();
}

class _ConverterState extends State<Converter> {
  double result = 0;
  TextEditingController userInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(borderSide: BorderSide(width: 2));

    return Scaffold(
      appBar: AppBar(
        title: Text("Converter"),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Tsh. ${result != 0 ? result.toStringAsFixed(2) : result.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: userInput,
              decoration: InputDecoration(
                hintText: "Enter Currency",
                prefixIcon: Icon(Icons.monetization_on),
                enabledBorder: border,
                focusedBorder: border,
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: TextButton(
              onPressed: () {
                setState(() {
                  result = double.parse(userInput.text) * 2500;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              child: Text("Converter", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
