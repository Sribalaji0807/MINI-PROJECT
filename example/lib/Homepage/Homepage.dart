import 'package:example/Database/DatabaseService.dart';
import 'package:example/Homepage/chatpage.dart';
import 'package:example/authenticationui/login.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>?> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = getContacts();
  }

  Future<List<dynamic>?> getContacts() async {
    if (kIsWeb) {
      String id = html.window.localStorage['userid'] as String;
      DBservice db = DBservice(id: id);
      return db.getContacts(id);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString('userid');
      DBservice db = DBservice(id: id);
      return db.getContacts(id);
    }
  }

  void signOut() async {
    if (kIsWeb) {
      html.window.localStorage.remove('userid');
      html.window.localStorage.remove('username');
      html.window.localStorage.remove('useremail');
      html.window.localStorage['isLoggedIn'] = 'false';
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userid','');
      prefs.setString('username','');
      prefs.setString('useremail','');
      prefs.setBool('isLoggedIn', false);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
              future: _contacts,
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Handle the case when the future is still loading
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Handle the case when an error occurred
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  // Handle the case when the future returns null
                  return Text('No data available');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChatPage(snapshot.data![index])),
                          );
                          // Add your onclick logic here
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(snapshot.data![index]),
                          subtitle: const Text('Last message'),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
