import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
import '../models/room_model.dart';
import 'settlement_confirmation_screen.dart';
import 'payment_instruction_screen.dart';

class RoomScreen extends StatelessWidget {
  final String roomId;

  const RoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return WillPopScope(
      onWillPop: () => _handleBackPress(context, authProvider.user!.uid),
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFFFFFF),
          title: Text(
            '방',
            style: TextStyle(
              fontFamily: 'WAGURI',
              fontSize: 30,
              color: Colors.black,
            ),
          ),
          elevation: 0,
        ),
        body: StreamBuilder<RoomModel?>(
          stream: roomProvider.getRoomStream(roomId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        '알림',
                        style: TextStyle(
                          fontFamily: 'WAGURI',
                          fontSize: 20,
                        ),
                      ),
                      content: Text(
                        '방이 삭제되었습니다.',
                        style: TextStyle(
                          fontFamily: 'WAGURI',
                          fontSize: 17,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/rooms',
                                  (route) => false,
                            );
                          },
                          child: Text(
                            '확인',
                            style: TextStyle(
                              fontFamily: 'WAGURI',
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              });
              return Center(child: CircularProgressIndicator());
            }

            RoomModel room = snapshot.data!;
            bool isCreator = room.creatorUid == authProvider.user!.uid;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: room.users.length,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      String userId = room.users[index];
                      bool isUserCreator = userId == room.creatorUid;
                      return ListTile(
                        title: Text(
                          userId,
                          style: TextStyle(
                            fontFamily: 'WAGURI',
                            fontSize: 25,
                            fontWeight: isUserCreator ? FontWeight.bold : FontWeight.normal,
                            color: isUserCreator ? Colors.blue : Colors.black,
                          ),
                        ),
                        leading: isUserCreator ? Icon(Icons.star, color: Colors.blue) : null,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      if (isCreator)
                        ElevatedButton(
                          onPressed: () => _settleCosts(context, room),
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(200, 65),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            '정산하기',
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'WAGURI',
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _handleBackPress(context, authProvider.user!.uid),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(200, 65),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '방 나가기',
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'WAGURI',
                          ),
                        ),
                      ),
                      SizedBox(height: 150),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<bool> _handleBackPress(BuildContext context, String userId) async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    RoomModel? room = await roomProvider.getRoom(roomId);

    if (room == null) return true;

    if (room.creatorUid == userId) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            '방 나가기',
            style: TextStyle(
              fontFamily: 'WAGURI',
              fontSize: 20,
            ),
          ),
          content: Text(
            '방장이 나가면 방이 삭제됩니다.\n정말 나가시겠습니까?',
            style: TextStyle(
              fontFamily: 'WAGURI',
              fontSize: 17,
            ),
          ),
          actions: [
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
                '나가기',
                style: TextStyle(
                  fontFamily: 'WAGURI',
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ) ?? false;

      if (result) {
        await roomProvider.deleteRoom(roomId);
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/rooms',
              (route) => false,
        );
      }
      return false;
    } else {
      await roomProvider.leaveRoom(roomId, userId);
      Navigator.pop(context);
      return true;
    }
  }

  void _settleCosts(BuildContext context, RoomModel room) async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '정산하기',
          style: TextStyle(
            fontFamily: 'WAGURI',
            fontSize: 20,
          ),
        ),
        content: Text(
          '정산을 시작하시겠습니까?\n모든 참가자에게 송금 요청이 전송됩니다.',
          style: TextStyle(
            fontFamily: 'WAGURI',
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              '취소',
              style: TextStyle(
                fontFamily: 'WAGURI',
                fontSize: 15,
                color: Colors.grey,
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
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        final roomProvider = Provider.of<RoomProvider>(context, listen: false);
        await roomProvider.updateRoomSettleStatus(room.id, true);

        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SettlementConfirmationScreen(roomId: room.id),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '정산 처리 중 오류가 발생했습니다.',
              style: TextStyle(
                fontFamily: 'WAGURI',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}