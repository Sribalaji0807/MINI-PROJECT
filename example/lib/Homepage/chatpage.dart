import 'package:example/Database/DatabaseService.dart';
import 'package:example/cryptography/asymmetric.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:async';
import 'package:example/cryptography/symmetric.dart';

class ChatPage extends StatefulWidget {
  final String personName;

  ChatPage(this.personName);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String? id;
  String? name;
  List<Map<String, dynamic>> messages = [];
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      id = html.window.localStorage['userid'] as String;
      getMessages(id!);
    } else {
      getId();
      getname();
    }
    _startTimer();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Create a timer that executes a function every 1 second
    _timer = Timer.periodic(Duration(seconds: 600), (timer) {
      setState(() {
        getMessages(id!);
      });
    });
  }

  Future<void> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('userid');
    getMessages(id!);
  }

  Future<void> getMessages(String id) async {
    DBservice db = DBservice(id: id);
    List<Map<String, dynamic>>? fetchedMessages = await db.getusermessage(id);
    setState(() {
      messages = fetchedMessages!;
    });
  }

  Future<void> getname() async {
    if (kIsWeb) {
      name = html.window.localStorage['username'] as String;
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      name = prefs.getString('username');
      print(name);
    }
  }

  Future<String> messagedecrypt(String text, String key, String iv) async {
    return await decrypt(text, key, iv);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
  itemCount: messages.length,
  itemBuilder: (context, index) {
    final message = messages[index];
    final bool isSentByUser = message['sendby'] != widget.personName;

    return FutureBuilder<String>(
      future: messagedecrypt(
        message["text"],
        message["key"],
        message["iv"],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Or any loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Align(
            alignment: isSentByUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isSentByUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
              child: Text(snapshot.data!),
            ),
          );
        }
      },
    );
  },
),

            // ListView.builder(
            //   itemCount: messages.length,
            //   itemBuilder: (context, index)  {
            //     print("-----he");

            //     final message = messages[index];
            //     //    print(message);
            //     //   print(message['sendby']);
            //     final bool isSentByUser =
            //         message['sendby'] != widget.personName;
            //     //   print(isSentByUser);

            //     Future<String> text =messagedecrypt(
            //       message[
            //           "text"], // Provide a default value if message["text"] is null
            //       message[
            //           "key"], // Provide a default value if message["key"] is null
            //       message[
            //           "iv"], // Provide a default value if message["iv"] is null
            //     ) ;
            //     return Align(
            //       alignment: isSentByUser
            //           ? Alignment.centerRight
            //           : Alignment.centerLeft,
            //       child: Container(
            //         margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            //         decoration: BoxDecoration(
            //           color: isSentByUser ? Colors.blue[100] : Colors.grey[200],
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         padding: EdgeInsets.all(8),
            //         child: Text(text as String),
            //       ),
            //     );
            //   },
            // ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message here...',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                                    DBservice db = DBservice(id: id);

                  String formattedTime =
                      DateFormat('HH:mm:ss').format(DateTime.now());
                  //  print(name);
                  List list = await crypto(_messageController.text);
                  Map<String, dynamic> message = {
                    'text': list[1],
                    'key': list[0],
                    'iv': list[2],
                    'sendby': name,
                    'destination': widget.personName,
                    'time': formattedTime
                  };
                  String response =
                      await db.sendertoreceiver(widget.personName, message);
                  //  print(response);
                  _messageController.clear();
                  await getMessages(
                      id!); // Assuming id is already set in initState

                  await Future.delayed(Duration(milliseconds: 500));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
