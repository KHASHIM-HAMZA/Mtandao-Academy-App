import 'package:flutter/material.dart';
import 'package:mtandao_app/components/Message.dart';

class Course extends StatefulWidget {
  const Course({super.key});

  @override
  State<Course> createState() => _CourseState();
}

Future<List<Message>> fetchMessages() async {
  await Future.delayed(Duration(seconds: 3));

  return [
    Message(
      sender: "My love",
      time: "20:01Am",
      messagePreview: "Please come back home!",
      iconUrl: Icon(Icons.person_2),
    ),
    Message(
      sender: "Dad",
      time: "11:21pm",
      messagePreview: "Chrismass is comming!",
      iconUrl: Icon(Icons.person_2),
    ),
  ];
}

class _CourseState extends State<Course> {
  late Future<List<Message>> fMessage;

  @override
  void initState() {
    super.initState();
    fMessage = fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fMessage,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error has occured",
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Messages"));
          }
          List<Message> sms = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text("Messages"),
                pinned: true,
                centerTitle: true,
                leading: Icon(Icons.menu_outlined),
                expandedHeight: 100,
                toolbarHeight: 50,
              ),
              SliverList.builder(
                itemCount: sms.length,
                itemBuilder: (context, index) {
                  Message message = sms[index];

                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: SizedBox(
                      height: 100,
                      child: ListTile(
                        hoverColor: const Color.fromARGB(255, 8, 8, 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: const Color.fromARGB(255, 88, 85, 85),
                            width: 1,
                          ),
                        ),
                        textColor: Colors.white,
                        tileColor: Colors.grey,
                        title: Text(message.sender),
                        subtitle: Text(message.messagePreview),
                        leading: message.iconUrl,
                        trailing: Text(message.time),
                      ),
                    ),
                  );
                },
              ),
              SliverFillRemaining(),
            ],
          );
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:mtandao_app/components/room.dart';
// //import 'package:flutter/cupertino.dart';

// class Registerpage extends StatelessWidget {
//   const Registerpage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(13.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: Card(
//                 color: Colors.amberAccent,
//                 child: Column(
//                   children: [
//                     Text("data", style: TextStyle(fontSize: 24)),
//                     Text("data", style: TextStyle(fontSize: 24)),
//                     Text("data", style: TextStyle(fontSize: 24)),
//                     Icon(Icons.gamepad),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 15),
//             Container(
//               height: 90,
//               width: double.infinity,
//               color: Colors.blue,
//               child: IconButton(onPressed: () {}, icon: Icon(Icons.person)),
//             ),
//             SizedBox(height: 8),
//             Text("Todays Wheather", style: TextStyle(fontSize: 20)),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   Room("12.00", "Rainy", Icons.cloud),
//                   Room("07:25", "Humidity", Icons.sunny),
//                   Room("09:00", "Wind", Icons.wind_power),
//                   Room("19:01", "Cold", Icons.air),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
