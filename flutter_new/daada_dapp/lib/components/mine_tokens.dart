import 'package:daada_dapp/components/custom_bottom_navbar.dart';
import 'package:daada_dapp/pages/wallet.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:daada_dapp/components/nft_balances.dart';
import 'package:daada_dapp/components/send_tokens.dart';
import 'package:daada_dapp/pages/create_or_import.dart';
import 'package:daada_dapp/providers/wallet_provider.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart' as stellarSdk;
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String walletAddress;
  HomeScreen({required this.walletAddress});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isMining = false;
  DateTime loginTime = DateTime.now();
  StellarSDK sdk = StellarSDK.TESTNET;

  double akofaBalance = 0.0;
  DateTime? lastMinedDate;
  double dailyLimit = 0.2;
  double monthlyLimit = 6.0;

  final String distributionAccountSecret =
      'SD3DC4XMEP6SRYMDP74EZWAEX5MACK6U4PCMJPL3SDF47QNCZB5S55H2';

  int _selectedIndex = 0; // Track the selected index
  String walletAddress = '';
  String balance = '';
  String pvKey = '';
  late Web3Client ethClient;

  @override
  void initState() {
    super.initState();

    ethClient = Web3Client(
      "https://eth-sepolia.g.alchemy.com/v2/grIRs75_QuxPGzESgRigtXgkl99sRVee", // Replace with your Alchemy API key
      Client(),
    );
    loadWalletData();
  }

  void startMining() async {
    if (!isMining && widget.walletAddress.isNotEmpty) {
      setState(() {
        isMining = true;
      });

      final currentTime = DateTime.now();
      final duration = currentTime.difference(loginTime);
      final hoursSpent = duration.inHours;

      // Calculate the total Akofa tokens to credit based on the time spent logged in
      final double tokensToCredit = (hoursSpent * dailyLimit);

      // Ensure that the monthly limit of 6 Akofa isn't exceeded
      if (tokensToCredit <= monthlyLimit) {
        await creditTokensToUser(tokensToCredit.toString());

        setState(() {
          isMining = false;
        });
      } else {
        setState(() {
          isMining = false;
        });
        print("Monthly mining limit reached.");
      }
    }
  }

  Future<void> creditTokensToUser(String amount) async {
    final KeyPair distributionKeyPair =
        KeyPair.fromSecretSeed(distributionAccountSecret);

    final Asset akofaCoin =
        AssetTypeCreditAlphaNum4('AKOFA', distributionKeyPair.accountId);

    final account = await sdk.accounts.account(distributionKeyPair.accountId);

    // ignore: unnecessary_nullable_for_final_variable_declarations
    final stellarSdk.Transaction transaction = TransactionBuilder(account)
        .addOperation(
            PaymentOperationBuilder(widget.walletAddress, akofaCoin, amount)
                .build())
        .build();

    transaction.sign(distributionKeyPair, Network.TESTNET);

    try {
      await sdk.submitTransaction(transaction);
      // You can update any balance UI here if needed.
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> loadWalletData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? privateKey = prefs.getString('privateKey');
    if (privateKey != null) {
      final walletProvider = WalletProvider();
      await walletProvider.loadPrivateKey();
      EthereumAddress address = await walletProvider.getPublicKey(privateKey);

      setState(() {
        walletAddress = address.hex;
        pvKey = privateKey;
      });

      EtherAmount balanceInWei = await ethClient.getBalance(address);
      String latestBalanceInEther =
          balanceInWei.getValueInUnit(EtherUnit.ether).toString();

      setState(() {
        balance = latestBalanceInEther;
      });
    }
  }

  // ignore: unused_field
  final List<Widget> _pages = [
    // Replace these with your desired pages

    // Page 1
    const Placeholder(), // Page 2
    const Placeholder(), // Page 3
    const Placeholder(), // Page 4
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different pages based on the selected index
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(walletAddress: '')),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WalletPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WalletPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                NFTListPage(address: walletAddress, chain: 'sepolia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.green,
          ),
          onPressed: () {},
        ),
        actions: const [
          Icon(
            Icons.notifications,
            color: Colors.green,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(2),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 15),
            const Text(
              'Countries we support',
              style: TextStyle(
                color: Color.fromARGB(255, 79, 79, 79),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: 100,
                width: 360,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var imageDetails in [
                      {
                        'path': 'assets/images/Kenya.jpg',
                        'text': 'Kenya',
                      },
                      {
                        'path': 'assets/images/Ghana.jpg',
                        'text': 'Ghana',
                      },
                      {
                        'path': 'assets/images/Morocco.jpg',
                        'text': 'Morocco',
                      },
                      {
                        'path': 'assets/images/Nigeria.jpg',
                        'text': 'Nigeria',
                      },
                      {
                        'path': 'assets/images/Mali.jpg',
                        'text': '',
                      },
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Column(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                  image: AssetImage(
                                    imageDetails['path'] as String,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(imageDetails['text'] as String),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              child: SizedBox(
                height: 169,
                width: MediaQuery.of(context).size.width,
                child: Card(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  elevation: 8,
                  color: const Color(0xFF008000),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Current Balance',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Earning Rate',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                balance.isNotEmpty
                                    ? '$balance Akf'
                                    : 'Loading...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            // Assuming there's a widget for the "Earning Rate"
                            const Text(
                              'Earning Rate Value', // Replace with actual value
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        isMining
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: widget.walletAddress.isNotEmpty
                                    ? startMining
                                    : null,
                                child: Text('Start Mining'),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: SizedBox(
                height: 200, // Height of the image container
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var imageDetails in [
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image1'
                      },
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image2'
                      },
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image3'
                      },
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image4'
                      },
                    ])
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Container(
                                height: 169,
                                width: MediaQuery.of(context).size.width * 1.1,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      imageDetails['path'] as String,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(imageDetails['text'] as String),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.only(right: 250),
              child: Text(
                'Retail',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                height: 100,
                width: 360,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var imageDetails in [
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image1',
                      },
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image2',
                      },
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image3',
                      },
                      {
                        'path': 'assets/images/background1.jpg',
                        'text': 'Image4',
                      },
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                image: DecorationImage(
                                  image: AssetImage(
                                    imageDetails['path'] as String,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(imageDetails['text'] as String),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      // Show the selected page from _pages
    );
  }
}
