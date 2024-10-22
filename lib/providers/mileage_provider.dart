import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MileageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  int _currentMileage = 0;

  int get currentMileage => _currentMileage;

  Future<void> initializeUserMileage() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // 새 사용자인 경우 초기 마일리지 5000 설정
        await _firestore.collection('users').doc(user.uid).set({
          'mileage': 5000,
        });
        _currentMileage = 5000;
      } else {
        _currentMileage = userDoc['mileage'] ?? 0;
      }
      notifyListeners();
    }
  }


  Future<void> fetchCurrentMileage() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _currentMileage = userDoc['mileage'] ?? 0;
        notifyListeners();
      }
    }
  }

  Future<void> rechargeMileage(int amount) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          int currentMileage = userSnapshot['mileage'] ?? 0;
          int newMileage = currentMileage + amount;

          transaction.update(userRef, {'mileage': newMileage});

          _currentMileage = newMileage;
        }
      });

      notifyListeners();
    }
  }

  Future<bool> deductMileage(int amount) async {
    User? user = _auth.currentUser;
    if (user != null) {
      bool success = false;

      await _firestore.runTransaction((transaction) async {
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);
        DocumentSnapshot userSnapshot = await transaction.get(userRef);

        if (userSnapshot.exists) {
          int currentMileage = userSnapshot['mileage'] ?? 0;
          if (currentMileage >= amount) {
            int newMileage = currentMileage - amount;
            transaction.update(userRef, {'mileage': newMileage});
            _currentMileage = newMileage;
            success = true;
          }
        }
      });

      notifyListeners();
      return success;
    }
    return false;
  }
}