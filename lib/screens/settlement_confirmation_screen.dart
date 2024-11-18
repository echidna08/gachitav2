import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mileage_provider.dart';
import '../models/room_model.dart';
import 'room_list_screen.dart';
import 'room_screen.dart';
import 'payment_instruction_screen.dart';
import 'new_main_screen.dart';

class SettlementConfirmationScreen extends StatelessWidget {
  final String roomId;
  final bool isCreator;

  SettlementConfirmationScreen({
    required this.roomId,
    required this.isCreator,
  });

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final mileageProvider = Provider.of<MileageProvider>(context);
    bool hasShownSnackBar = false;

    return WillPopScope(
      onWillPop: () async => true,
      child: StreamBuilder<RoomModel?>(
        stream: roomProvider.getRoomStream(roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          final room = snapshot.data!;
          final currentUserId = authProvider.user?.uid;

          if (currentUserId == null) {
            return Scaffold(
              body: Center(child: Text('사용자 정보를 불러올 수 없습니다.')),
            );
          }

          if (!isCreator &&
              room.payments[currentUserId] == true &&
              !hasShownSnackBar) {
            hasShownSnackBar = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '송금이 완료되었습니다',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Color(0xFF4A55A2),
                  duration: Duration(seconds: 2),
                ),
              );
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(
                isCreator ? '정산 관리' : '송금하기',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: FutureBuilder<String?>(
              future: authProvider.user?.uid != null
                  ? authProvider.getUserEmail(authProvider.user!.uid)
                  : Future.value(null),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<RoomModel?>(
                  stream: roomProvider.getRoomStream(roomId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
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

                    final currentUserId = authProvider.user?.uid;

                    if (currentUserId == null) {
                      return Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
                    }

                    final currentUserPaid =
                        room.payments?[currentUserId] ?? false;
                    final isCurrentUserCreator =
                        room.creatorUid == currentUserId;
                    final allPaid = room.users.every((userId) =>
                        userId == room.creatorUid ||
                        (room.payments?[userId] ?? false));

                    if (allPaid && isCreator && !hasShownSnackBar) {
                      hasShownSnackBar = true;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '모든 참가자의 송금이 완료되었습니다',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor: Color(0xFF4A55A2),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      });
                    }

                    return Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCreator ? '참가자 송금 현황' : '송금 정보',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 24),
                          Expanded(
                            child: ListView.builder(
                              itemCount: room.users.length,
                              itemBuilder: (context, index) {
                                final userId = room.users[index];
                                final isPaid = room.payments?[userId] ?? false;
                                final isRoomCreator = userId == room.creatorUid;

                                return FutureBuilder<String?>(
                                  future: authProvider.getUserEmail(userId),
                                  builder: (context, emailSnapshot) {
                                    final userEmail =
                                        emailSnapshot.data ?? 'Loading...';

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Colors.grey[200]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: (isPaid || isRoomCreator)
                                                  ? Color(0xFF4A55A2)
                                                      .withOpacity(0.1)
                                                  : Colors.red[50],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              (isPaid || isRoomCreator)
                                                  ? Icons.check_circle_outline
                                                  : Icons.timer,
                                              size: 20,
                                              color: (isPaid || isRoomCreator)
                                                  ? Color(0xFF4A55A2)
                                                  : Colors.red[400],
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userEmail,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  isRoomCreator
                                                      ? '방장'
                                                      : (isPaid
                                                          ? '송금 완료'
                                                          : '송금 대기'),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          if (!isCreator &&
                              !currentUserPaid &&
                              !isCurrentUserCreator) ...[
                            SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () => _sendPayment(
                                    context, room, mileageProvider),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4A55A2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  '돈 보내기',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (isCreator) ...[
                            SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () =>
                                    _completeSettlement(context, roomId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4A55A2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  '정산 완료',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendPayment(BuildContext context, RoomModel room,
      MileageProvider mileageProvider) async {
    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      final userId = Provider.of<AuthProvider>(context, listen: false).user!.uid;

      int totalAmount = 4800;
      int numberOfUsers = room.users.length;
      int amountPerPerson = totalAmount ~/ numberOfUsers;

      await mileageProvider.deductMileage(amountPerPerson);
      await roomProvider.updatePaymentStatus(room.id, userId, true);

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('송금 완료'),
            content: Text('송금이 완료되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => RoomListScreen()),
                    (route) => false,
                  );
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('송금 처리 중 오류가 발생했습니다'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }

  Future<void> _completeSettlement(BuildContext context, String roomId) async {
    try {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      
      // 모든 사용자가 결제했는지 확인
      final room = await roomProvider.getRoom(roomId);
      if (room == null) return;
      
      final allPaid = room.users.every((userId) =>
          userId == room.creatorUid || (room.payments[userId] ?? false));
          
      if (!allPaid) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('모든 참가자의 송금이 완료되어야 합니다'),
            backgroundColor: Colors.red[400],
          ),
        );
        return;
      }

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('정산 완료'),
            content: Text('정산이 완료되었습니다.'),
            actions: [
              TextButton(
                onPressed: () async {
                  try {
                    // 다이얼로그를 먼저 닫고
                    Navigator.pop(dialogContext);
                    
                    // 방 목록 화면으로 이동
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => RoomListScreen()),
                      (route) => false,
                    );
                    
                    // 그 다음에 정산 완료 처리
                    await roomProvider.completeSettlement(roomId);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('정산 완료 처리 중 오류가 발생했습니다'),
                        backgroundColor: Colors.red[400],
                      ),
                    );
                  }
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('정산 완료 처리 중 오류가 발생했습니다'),
          backgroundColor: Colors.red[400],
        ),
      );
    }
  }
}
