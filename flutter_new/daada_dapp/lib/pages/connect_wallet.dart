import 'package:daada_dapp/components/mine_tokens.dart';
import 'package:daada_dapp/utils/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectWalletPage extends StatefulWidget {
  @override
  _ConnectWalletPageState createState() => _ConnectWalletPageState();
}

class _ConnectWalletPageState extends State<ConnectWalletPage> {
  final TextEditingController _walletAddressController =
      TextEditingController();

  void _connectWallet() async {
    String walletAddress = _walletAddressController.text.trim();

    if (walletAddress.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await DatabaseService(uid: user.uid)
            .updateUserData(walletAddress, DateTime.now().toIso8601String());
        // Store wallet address and current time in Firestore

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(walletAddress: walletAddress),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid Solar wallet address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect Solar Wallet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _walletAddressController,
              decoration: InputDecoration(
                labelText: 'Enter your Solar wallet address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your wallet address';
                }

                // Basic validation for Solar wallet address format
                final walletRegex = RegExp(r'^G[0-9a-zA-Z]{55}$');
                if (!walletRegex.hasMatch(value)) {
                  return 'Invalid Solar wallet address';
                }

                return null; // Return null if validation passes
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectWallet,
              child: Text('Connect Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
