import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/mileage_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String selectedAmount;

  const PaymentScreen({Key? key, required this.selectedAmount}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String cardNumber;
  late String expirationDate;
  late String cvc;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제하기', style: TextStyle(fontFamily: 'WAGURI')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '충전할 금액: ${widget.selectedAmount} 마일리지',
              style: TextStyle(fontSize: 18, fontFamily: 'WAGURI'),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: '카드 번호'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => cardNumber = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '유효기간 (MM/YY)'),
              keyboardType: TextInputType.datetime,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => expirationDate = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'CVC'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => cvc = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('결제하기', style: TextStyle(fontFamily: 'WAGURI')),
              onPressed: isProcessing ? null : _processPayment,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      isProcessing = true;
    });

    // 여기에 실제 결제 로직을 구현합니다.
    // 이 예제에서는 단순히 지연을 주고 성공했다고 가정합니다.
    await Future.delayed(Duration(seconds: 2));

    // 결제 성공 후 마일리지 충전
    final mileageProvider = Provider.of<MileageProvider>(context, listen: false);
    await mileageProvider.rechargeMileage(int.parse(widget.selectedAmount));

    setState(() {
      isProcessing = false;
    });

    Navigator.of(context).pop(true); // true를 반환하여 결제 성공을 알립니다.
  }
}