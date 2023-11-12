import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/io.dart';

class Interact extends ChangeNotifier {
  Client httpClient = Client();
  final String rpcUrl = dotenv.env['URL']!;
  final String wsUrl = dotenv.env['WSURL']!;

  // final String myAddress = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8";

  final String privateKey = dotenv.env['PRIVATE_KEY']!;

  final String contractName = "MyTest";

  int balance = 0;
  bool loading = false;

  Future<List<dynamic>> query(String funcName, List<dynamic> args) async {
    print(rpcUrl);
    Web3Client ethClient = Web3Client(rpcUrl, httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(funcName);
    List<dynamic> result = await ethClient.call(
      contract: contract,
      function: function,
      params: args,
    );
    return result;
  }

  Future<DeployedContract> getContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(abi, contractName),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<String> transaction(String functionName, List<dynamic> args) async {
    Web3Client ethClient = Web3Client(rpcUrl, httpClient, socketConnector: () {
      return IOWebSocketChannel.connect(rpcUrl).cast<String>();
    });
    EthPrivateKey credential = EthPrivateKey.fromHex(privateKey);
    DeployedContract contract = await getContract();
    ContractFunction function = contract.function(functionName);
    dynamic result = await ethClient.sendTransaction(
      credential,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: args,
      ),
      chainId: 31337,
    );

    return result;
  }

  Future<void> getBalance() async {
    loading = true;
    notifyListeners();
    List<dynamic> result = await query('balance', []);
    balance = int.parse(result[0].toString());
    loading = false;
    notifyListeners();
  }

  Future<void> deposit(amount) async {
    loading = true;
    notifyListeners();
    String result = await transaction('deposit', [BigInt.from(amount)]);
    print(result);
    loading = false;
    notifyListeners();
    getBalance();
  }

  Future<void> withdraw() async {
    loading = true;
    notifyListeners();
    String result = await transaction('withdraw', [BigInt.from(1)]);
    print(result);
    loading = false;
    notifyListeners();
    getBalance();
  }
}
