import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mileage_provider.dart';
import '../providers/room_provider.dart';

class PaymentInstructionScreen extends StatelessWidget {
  final String roomId;

  PaymentInstructionScreen({required this.roomId});

  @override
  Widget build(BuildContext context) {
    final mileageProvider = Provider.of<MileageProvider>(context);
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('송금 안내'),
      ),
      body: Center(
        child: Text('송금 안내 화면입니다. Room ID: $roomId'),
      ),
    );
  }
}