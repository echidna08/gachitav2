import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class RoomProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RoomModel> _rooms = [];

  List<RoomModel> get rooms => _rooms;

  // 실시간 방 목록 스트림
  Stream<List<RoomModel>> getRoomsStream() {
    return _firestore.collection('rooms').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // 단일 방 스트림 (null 안전성 추가)
  Stream<RoomModel?> getRoomStream(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // 방 생성
  Future<String> createRoom(String creatorUid, String title) async {
    try {
      DocumentReference roomRef = await _firestore.collection('rooms').add({
        'creatorUid': creatorUid,
        'title': title,
        'users': [creatorUid],
        'payments': {},
        'history': [],
        'isSettling': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return roomRef.id;
    } catch (e) {
      print('Error creating room: $e');
      throw e;
    }
  }

  // 방 참가
  Future<bool> joinRoom(String roomId, String userId) async {
    try {
      DocumentSnapshot room =
          await _firestore.collection('rooms').doc(roomId).get();
      if (room.exists) {
        List<dynamic> users = room.get('users') as List<dynamic>;
        if (users.length < 4) {
          await _firestore.collection('rooms').doc(roomId).update({
            'users': FieldValue.arrayUnion([userId]),
          });
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error joining room: $e');
      return false;
    }
  }

  // 방 나가기
  Future<void> leaveRoom(String roomId, String userId) async {
    try {
      DocumentSnapshot room =
          await _firestore.collection('rooms').doc(roomId).get();
      if (room.exists) {
        await _firestore.collection('rooms').doc(roomId).update({
          'users': FieldValue.arrayRemove([userId]),
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error leaving room: $e');
    }
  }

  // 방 삭제
  Future<void> deleteRoom(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting room: $e');
    }
  }

  // 결제 상태 업데이트
  Future<void> updatePaymentStatus(
      String roomId, String userId, bool status) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'payments.$userId': status,
      });
      notifyListeners();
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

  // 정산 상태 업데이트
  Future<void> updateRoomSettleStatus(String roomId, bool isSettling) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'isSettling': isSettling,
        'settle': isSettling,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      print('Error updating settle status: $e');
    }
  }

  // 방 정보 가져오기
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        return RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting room: $e');
      return null;
    }
  }

  // 방 목록 새로고침
  Future<void> fetchRooms() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('rooms').get();
      _rooms = snapshot.docs
          .map((doc) =>
              RoomModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching rooms: $e');
    }
  }

  Future<void> startSettlement(String roomId) async {
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'isSettling': true, // 정산 시작 상태로 변경
      });
    } catch (e) {
      print('Error starting settlement: $e');
      throw e;
    }
  }
}
