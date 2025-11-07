import 'package:flutter/material.dart';

class Slivepage extends StatefulWidget {
  const Slivepage({super.key});

  @override
  State<Slivepage> createState() => _SlivepageState();
}

class _SlivepageState extends State<Slivepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            backgroundColor: Colors.black,
            pinned: true,
            title: Text(
              "AiScore Premium",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.help_outline_sharp),
              ),
            ],
          ),
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.black,
            leading: Icon(Icons.account_circle, color: Colors.grey),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: Icon(Icons.monetization_on, size: 50, shadows: []),
              ),
            ],
            title: //Column(
            //   mainAxisAlignment: MainAxisAlignment.start,
            //   children: [
            Text(
              "Sign in \n please login to purchase",
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            //SizedBox(height: 10),
            //     Text(
            //       "please log in to purchase Premium",
            //       style: TextStyle(color: Colors.grey, fontSize: 13),
            //     ),
            //   ],
            // ),
          ),
          SliverToBoxAdapter(),
          SliverFillRemaining(),
        ],
      ),
    );
  }
}
