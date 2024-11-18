import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
import '../models/room_model.dart';
import 'settlement_confirmation_screen.dart';
import 'payment_instruction_screen.dart';
import 'room_list_screen.dart';

class RoomScreen extends StatelessWidget {
  final String roomId;

  const RoomScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;

    return Scaffold(
      body: StreamBuilder<RoomModel?>(
        stream: roomProvider.getRoomStream(roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          final room = snapshot.data!;
          bool isCreator = room.creatorUid == currentUserId;

          if (room.isSettling) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SettlementConfirmationScreen(
                    roomId: room.id,
                    isCreator: isCreator,
                  ),
                ),
              );
            });
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: room.users.length,
                  itemBuilder: (context, index) {
                    final userId = room.users[index];
                    final isUserCreator = userId == room.creatorUid;
                    final isCurrentUser = userId == currentUserId;

                    return FutureBuilder<String?>(
                      future: authProvider.getUserEmail(userId),
                      builder: (context, emailSnapshot) {
                        if (emailSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final userEmail = emailSnapshot.data ?? 'Unknown';

                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4A55A2).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF4A55A2),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              userEmail,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isCurrentUser) ...[
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '나',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Pretendard',
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (isUserCreator) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          '방장',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF4A55A2),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    if (isCreator) ...[
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _settleCosts(context, room),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A55A2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '정산하기',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () async {
                            try {
                              if (currentUserId != null) {
                                // 로딩 표시
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                );

                                // 방 존재 여부 확인
                                final roomExists = await roomProvider.checkRoomExists(roomId);
                                if (!roomExists) {
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => RoomListScreen()),
                                    (route) => false,
                                  );
                                  return;
                                }

                                await roomProvider.leaveRoom(roomId, currentUserId, isCreator);
                                
                                if (!context.mounted) return;
                                // 로딩 다이얼로그 닫기
                                Navigator.of(context).pop();
                                
                                // 방 목록으로 이동
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => RoomListScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (!context.mounted) return;
                              // 로딩 다이얼로그 닫기
                              Navigator.of(context).pop();
                              
                              // 에러 메시지 표시
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '방을 나가는 중 오류가 발생했습니다. 다시 시도해주세요.',
                                    style: TextStyle(fontFamily: 'Pretendard'),
                                  ),
                                  backgroundColor: Colors.red[400],
                                ),
                              );
                              
                              // 에러가 발생해도 방 목록으로 이동
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => RoomListScreen()),
                                (route) => false,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Color(0xFF4A55A2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            '나가기',
                            style: TextStyle(
                              fontSize: 17,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4A55A2),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _handleBackPress(BuildContext context, String userId) async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final room = await roomProvider.getRoom(roomId);

    if (room == null) return true;

    if (room.creatorUid == userId) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red[400],
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '방 나가기',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '방장이 나가면 방이 삭제됩니다.',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  '정말 나가시겠습니까?',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '취소',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.red[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '나가기',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ) ?? false;

      if (result) {
        await roomProvider.leaveRoom(roomId, userId, true);
        if (!context.mounted) return true;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoomListScreen()),
          (route) => false,
        );
        return true;
      }
      return false;
    } else {
      await roomProvider.leaveRoom(roomId, userId, false);
      if (!context.mounted) return true;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RoomListScreen()),
        (route) => false,
      );
      return true;
    }
  }

  void _settleCosts(BuildContext context, RoomModel room) async {
    if (room.users.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '정산을 시작하려면 최소 2명 이상의 참가자가 필요합니다',
            style: TextStyle(fontFamily: 'Pretendard'),
          ),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      await roomProvider.startSettlement(room.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('정산을 시작할 수 없습니다.'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  void _showLeaveConfirmationDialog(BuildContext context, bool isCreator) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '방 나가기',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            isCreator ? '방장이 나가면 방이 삭제됩니다.\n정말 나가시겠습니까?' : '정말 나가시겠습니까?',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final roomProvider = Provider.of<RoomProvider>(context, listen: false);
                final userId = Provider.of<AuthProvider>(context, listen: false).user!.uid;
                
                Navigator.of(context).pop(); // 다이얼로그 닫기
                
                await roomProvider.leaveRoom(roomId, userId, isCreator);
                
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => RoomListScreen()),
                  (route) => false,
                );
              },
              child: Text(
                '나가기',
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
  }

  Future<void> _leaveRoom(BuildContext context, bool isCreator) async {
    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final userId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
      
      if (userId == null) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 방이 존재하는지 먼저 확인
      final roomExists = await roomProvider.checkRoomExists(roomId);
      if (!roomExists) {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoomListScreen()),
          (route) => false,
        );
        return;
      }

      await roomProvider.leaveRoom(roomId, userId, isCreator);
      
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RoomListScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // 에러 발생 시 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '방 나가는 중 오류가 발생했습니다. 다시 시도해주세요.',
            style: TextStyle(
              fontFamily: 'Pretendard',
            ),
          ),
          backgroundColor: Colors.red[400],
          duration: Duration(seconds: 2),
        ),
      );
      
      // 에러가 발생해도 방 목록으로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => RoomListScreen()),
        (route) => false,
      );
    }
  }
}
