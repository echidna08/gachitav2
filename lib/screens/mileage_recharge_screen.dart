import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mileage_provider.dart';

class MileageRechargeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mileageProvider = Provider.of<MileageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('마일리지 충전'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('현재 마일리지: ${mileageProvider.currentMileage}'),
            // 마일리지 충전 UI 구현
          ],
        ),
      ),
    );
  }
}