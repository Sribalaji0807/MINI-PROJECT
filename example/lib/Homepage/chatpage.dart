import 'package:example/Database/DatabaseService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class ChatPage extends StatefulWidget {
  final String personName;

  ChatPage(this.personName);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  String? id;
  @override
  void initState() {
    super.initState();
    print(widget.personName);
    if (kIsWeb) {
      id = html.window.localStorage['userid'] as String;
    } else {
      getid();
    }
  }

  Future<void> getid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('userid');
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
            child: Center(
              child: Text('Chat Page'),
            ),
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
                  String formattedTime =
                      DateFormat('HH:mm:ss').format(DateTime.now());
                  Map<String, dynamic> message = {
                    'text': _messageController.text,
                    'sendby': 'sribalaji',
                    'destination': widget.personName,
                    'time': formattedTime
                  };
                  DBservice db = DBservice(id: id);
                  String d =
                      await db.sendertoreceiver(widget.personName, message);
                  print(d);
                  _messageController.text = '';
                  // Add your send message functionality here
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
