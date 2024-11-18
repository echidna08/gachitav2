import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../models/room_model.dart';
import '../screens/room_list_screen.dart';

class PaymentInstructionScreen extends StatelessWidget {
  final String roomId;

  const PaymentInstructionScreen({
    Key? key, 
    required this.roomId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            '송금 안내',
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: StreamBuilder<RoomModel?>(
          stream: roomProvider.getRoomStream(roomId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final room = snapshot.data!;
            if (!room.isSettling) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => RoomListScreen()),
                  (route) => false,
                );
              });
            }

            return Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment_rounded,
                      size: 64,
                      color: Color(0xFF4A55A2),
                    ),
                    SizedBox(height: 24),
                    Text(
                      '송금 안내',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '방장이 정산을 시작했습니다.\n송금 정보를 확인해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A55A2)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}