import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:test_web3/interaction/interaction.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => Interact())],
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController controller = TextEditingController();
  int _value = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<Interact>().getBalance();
    });
  }

  @override
  Widget build(BuildContext context) {
    Interact provider = Provider.of<Interact>(context);
    int balance = context.watch<Interact>().balance;
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text('Balance : ${balance.toString()}'),
            ),
            SizedBox(
              height: 20,
            ),

            // Button to get balance
            ElevatedButton(
              onPressed: () async {
                await provider.getBalance();
              },
              child: provider.loading
                  ? CircularProgressIndicator()
                  : Text('Get Balance'),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter amount to deposit',
              ),
              onChanged: (value) => _value = int.parse(value),
            ),
            // Button to deposit
            ElevatedButton(
              onPressed: () async {
                await provider.deposit(_value);
              },
              child: provider.loading
                  ? CircularProgressIndicator()
                  : Text('Deposit'),
            ),
          ],
        ),
      ),
    );
  }
}
