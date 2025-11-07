import 'package:flutter/material.dart';

class Room extends StatelessWidget {
  final String label;
  final String muda;
  final IconData iconi;

  const Room(this.muda, this.label, this.iconi, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      width: 110,
      child: Card(
        elevation: 6,
        child: Column(
          children: [
            Text(
              muda,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Icon(iconi, size: 55),
            Text(label),
          ],
        ),
      ),
    );
  }
}
