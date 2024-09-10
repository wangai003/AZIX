import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // collection reference
  final CollectionReference brewCollection =
      FirebaseFirestore.instance.collection('user');

  Future<void> updateUserData(String walletAdress, String DateTime) async {
    return await brewCollection.doc(uid).set({
      'WalletAdress': walletAdress,
      'DateTime': DateTime,
    });
  }
}
