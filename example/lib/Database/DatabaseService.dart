import 'package:cloud_firestore/cloud_firestore.dart';

class DBservice {
  final String? id;
  DBservice({this.id});

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> addUserData(String name, String email) async {
    return await _usersCollection
        .doc(id)
        .set({'name': name, 'email': email, 'mailbox': [], 'MyContacts': []})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<String> retriveuserinfo(String? id) async {
    return _usersCollection
        .doc(id)
        .get()
        .then((value) => (value.data() as Map<String, dynamic>)['name']);
  }

  Future<List<dynamic>?> getContacts(String? id) async {
    print(id);
    final documentSnapshot = await _usersCollection.doc(id).get();
    final contactsData = documentSnapshot.data() as Map<String, dynamic>?;

    if (contactsData != null) {
      final contacts = contactsData['MyContacts'] as List<dynamic>?;
      print(contacts);

      return contacts;
    } else {
      return null;
    }
    //   return _usersCollection
    //       .doc(id)
    //       .get()
    //       .then((value) => (value.data() as Map<String, dynamic>?)?['MyContacts']);
    // }
  }

  Future<String> sendertoreceiver(
      String username, Map<String, dynamic> dataToAdd) async {
    QuerySnapshot querySnapshot =
        await _usersCollection // Replace 'your_collection' with the name of your collection
            .where('name',
                isEqualTo: username) // Query based on field and value
            .get();
    
    DocumentReference documentRef = _usersCollection.doc(querySnapshot.docs[0].id);
    print(documentRef);
    // // Use update method to add data to a specific field (e.g., "mailbox")
    return await documentRef
        .update({
          'mailbox': FieldValue.arrayUnion([dataToAdd])
        })
        .then((value) => "Data added to mailbox")
        .catchError((error) => "Failed to add data to mailbox: $error");
  }
}
