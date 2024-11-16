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
  Future<void> leaveRoom(String roomId, String userId, bool isCreator) async {
    try {
      DocumentSnapshot room = await _firestore.collection('rooms').doc(roomId).get();
      if (room.exists) {
        if (isCreator) {
          // 방장이 나가면 방 삭제
          await _firestore.collection('rooms').doc(roomId).delete();
        } else {
          // 일반 참가자가 나가면 users 배열에서 제거
          await _firestore.collection('rooms').doc(roomId).update({
            'users': FieldValue.arrayRemove([userId]),
          });
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error leaving room: $e');
      throw e;
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

  Future<void> completeSettlement(String roomId) async {
    try {
      // 방 정보 가져오기
      DocumentSnapshot roomDoc = await _firestore.collection('rooms').doc(roomId).get();
      Map<String, dynamic> roomData = roomDoc.data() as Map<String, dynamic>;
      
      String creatorUid = roomData['creatorUid'];
      int totalAmount = 4800;
      int numberOfUsers = (roomData['users'] as List).length;
      int amountPerPerson = totalAmount ~/ numberOfUsers;
      int creatorReceiveAmount = amountPerPerson * (numberOfUsers - 1);
      
      // 방장의 마일리지 증가
      await _firestore.runTransaction((transaction) async {
        DocumentReference creatorRef = _firestore.collection('users').doc(creatorUid);
        DocumentSnapshot creatorDoc = await transaction.get(creatorRef);
        
        if (!creatorDoc.exists) {
          throw Exception('Creator user document not found');
        }
        
        Map<String, dynamic> creatorData = creatorDoc.data() as Map<String, dynamic>;
        int currentMileage = creatorData['mileage'] ?? 0;
        transaction.update(creatorRef, {
          'mileage': currentMileage + creatorReceiveAmount
        });
      });
      
      // 정산 완료 기록 저장
      await _firestore.collection('completedSettlements').doc(roomId).set({
        'completedAt': FieldValue.serverTimestamp(),
        'creatorUid': creatorUid,
        'amountReceived': creatorReceiveAmount,
      });
      
      // 방 삭제
      await _firestore.collection('rooms').doc(roomId).delete();
      
      // 5분 후에 completedSettlements 기록 삭제
      Future.delayed(Duration(minutes: 5), () async {
        await _firestore.collection('completedSettlements').doc(roomId).delete();
      });
    } catch (e) {
      print('Error completing settlement: $e');
      throw e;
    }
  }

  // 방이 정산 완료로 인해 삭제되었는지 확인하는 메서드
  Future<bool> wasSettlementCompleted(String roomId) async {
    try {
      // 최근에 정산 완료된 방들의 ID를 저장하는 컬렉션 확인
      DocumentSnapshot doc = await _firestore
          .collection('completedSettlements')
          .doc(roomId)
          .get();
      
      return doc.exists;
    } catch (e) {
      print('Error checking settlement status: $e');
      return false;
    }
  }
}
