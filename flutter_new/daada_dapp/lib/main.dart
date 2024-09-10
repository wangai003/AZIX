import 'package:daada_dapp/pages/signup_page.dart';
import 'package:daada_dapp/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallet_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

void main() async {
  // Submit the transaction

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDez-3_pVJepyOkMxvWp5IL5_-cf2fmXdk",
          authDomain: "azix-7ffe4.firebaseapp.com",
          projectId: "azix-7ffe4",
          storageBucket: "azix-7ffe4.appspot.com",
          messagingSenderId: "40354643169",
          appId: "1:40354643169:web:d3cd66059540d3cb36cba0",
          measurementId: "G-D60TVF0VEK" // Only for analytics (optional)
          ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Load the private key
  WalletProvider walletProvider = WalletProvider();
  await walletProvider.loadPrivateKey();

  runApp(
    ChangeNotifierProvider<WalletProvider>.value(
      value: walletProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: MyRoutes.loginRoute,
      routes: {
        MyRoutes.loginRoute: (context) => const SignupPage(),
      },
    );
  }
}
