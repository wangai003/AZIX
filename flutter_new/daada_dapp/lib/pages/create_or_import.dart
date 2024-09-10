import 'package:daada_dapp/pages/generate_mnemonic_page.dart';
import 'package:daada_dapp/pages/import_wallet.dart';
import 'package:flutter/material.dart';

class CreateOrImportPage extends StatelessWidget {
  const CreateOrImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header

              const SizedBox(height: 24.0),

              // Logo
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: SizedBox(
                  width: 150,
                  height: 200,
                  child: Image.asset(
                    'assets/images/azix.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 50.0),

              // Login button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GenerateMnemonicPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                      0xFFC79D02), // Customize button background color
                  foregroundColor: Colors.white, // Customize button text color
                  padding: const EdgeInsets.all(16.0),
                ),
                child: Container(
                  child: const Text(
                    'Create Wallet',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              // Register button
              ElevatedButton(
                onPressed: () {
                  // Add your register logic here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImportWallet(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.white, // Customize button background color
                  foregroundColor: Colors.black, // Customize button text color
                  padding: const EdgeInsets.all(16.0),
                ),
                child: const Text(
                  'Import from Seed',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),

              const SizedBox(height: 24.0),

              // Footer
              Container(
                alignment: Alignment.center,
                child: const Text(
                  '© 2024 DAADA INC. All rights reserved.',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
