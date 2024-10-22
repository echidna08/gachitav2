import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
import '../models/room_model.dart';
import 'room_list_screen.dart';

class SettlementConfirmationScreen extends StatelessWidget {
  final String roomId;

  SettlementConfirmationScreen({required this.roomId});

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '정산 확인',
          style: TextStyle(
            fontFamily: 'WAGURI',
            fontSize: 30,
          ),
        ),
      ),
      body: StreamBuilder<RoomModel?>(
        stream: roomProvider.getRoomStream(roomId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('방을 찾을 수 없습니다.'));
          }

          RoomModel room = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '다른 사용자들이 송금했는지 확인합니다.',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'WAGURI',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ...room.users.where((userId) => userId != room.creatorUid).map((userId) {
                  bool hasPaid = room.payments[userId] ?? false;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userId, // 실제로는 사용자 이름을 표시해야 합니다
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'WAGURI',
                        ),
                      ),
                      Icon(
                        hasPaid ? Icons.check_circle : Icons.cancel,
                        color: hasPaid ? Colors.green : Colors.red,
                        size: 30.0,
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _confirmPayments(context),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'WAGURI',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmPayments(BuildContext context) async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '확인',
            style: TextStyle(
              fontFamily: 'WAGURI',
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정말 모든 사용자들이 송금했는지',
                style: TextStyle(
                  fontFamily: 'WAGURI',
                  fontSize: 15,
                ),
              ),
              Text(
                '확인하셨습니까?',
                style: TextStyle(
                  fontFamily: 'WAGURI',
                  color: Colors.red,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'WAGURI',
                  fontSize: 15,
                  color: Colors.blue,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'WAGURI',
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirm) {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      try {
        await roomProvider.deleteRoom(roomId);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoomListScreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('방을 삭제하는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
}