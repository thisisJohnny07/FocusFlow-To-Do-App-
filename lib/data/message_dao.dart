import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class MessageDao {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('messages');
  // TODO: Add saveMessage

  Future<String> saveMessage(Message message) async {
    final docRef = await collection.add(message.toJson());
    return docRef.id; // Return the document ID
  }

  Stream<QuerySnapshot> getMessageStream() {
    return collection.snapshots();
  }
}
