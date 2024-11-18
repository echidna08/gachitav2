import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
import '../models/room_model.dart';
import 'room_screen.dart';
import 'settlement_confirmation_screen.dart';
import 'new_main_screen.dart';

class RoomListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.user?.uid;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => NewMainScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            '방 목록',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => NewMainScreen()),
                (route) => false,
              );
            },
          ),
        ),
        body: StreamBuilder<List<RoomModel>>(
          stream: roomProvider.getRoomsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4A55A2),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '오류가 발생했습니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      '아직 생성된 방이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }

            List<RoomModel> rooms = snapshot.data!;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  bool isCreator = room.creatorUid == currentUserId;
                  bool isCurrentUserInRoom = room.users.contains(currentUserId);

                  return FutureBuilder<String?>(
                    future: authProvider.getUserEmail(room.creatorUid),
                    builder: (context, creatorSnapshot) {
                      String creatorEmail = creatorSnapshot.data ?? 'Loading...';

                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _joinRoom(context, room, currentUserId!),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF4A55A2).withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.groups_rounded,
                                            color: Color(0xFF4A55A2),
                                            size: 24,
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                room.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${room.users.length}/4',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: 'Pretendard',
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  if (room.creatorUid == currentUserId) ...[
                                                    SizedBox(width: 8),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFEEF0F8),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        '방장',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: 'Pretendard',
                                                          color: Color(0xFF4A55A2),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[400],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createRoom(context),
          backgroundColor: Color(0xFF4A55A2),
          elevation: 0,
          child: Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Future<void> _createRoom(BuildContext context) async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    if (currentUserId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '로그인이 필요합니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red[400],
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String? roomTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputText = '';

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            '방 만들기',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: '방 제목을 입력하세요',
              hintStyle: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 15,
                color: Colors.black38,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Color(0xFF4A55A2)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              color: Colors.black87,
            ),
            onChanged: (value) => inputText = value,
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, inputText),
              child: Text(
                '확인',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A55A2),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (roomTitle == null) return;

    try {
      final roomId = await roomProvider.createRoom(currentUserId, roomTitle);

      if (!context.mounted) return;

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RoomScreen(roomId: roomId),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '방 생성에 실패했습니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red[400],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _joinRoom(BuildContext context, RoomModel room, String userId) async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    if (room.users.length < 4 && !room.users.contains(userId)) {
      await roomProvider.joinRoom(room.id, userId);
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoomScreen(roomId: room.id)),
      );
    } else if (room.users.contains(userId)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoomScreen(roomId: room.id)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '방이 가득 찼습니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void _showSettlementConfirmation(BuildContext context, RoomModel room) {
    if (room.users.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '정산을 시작하려면 최소 2명 이상의 참가자가 필요합니다',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettlementConfirmationScreen(
          roomId: room.id,
          isCreator: false,
        ),
      ),
    );
  }
}
