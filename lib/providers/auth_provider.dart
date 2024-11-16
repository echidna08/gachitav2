import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../providers/mileage_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  Map<String, String> _userEmails = {};

  UserModel? get user => _user;

  Future<void> signIn(
      String email, String password, MileageProvider mileageProvider) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _user = await _firebaseService.getUserData(userCredential.user!.uid);
        if (_user != null) {
          await mileageProvider.initializeUserMileage();
          notifyListeners();
        } else {
          throw '사용자 정보를 불러올 수 없습니다.';
        }
      }
    } catch (e) {
      print('Login error: $e'); // 디버깅을 위한 로그
      if (e.toString().contains('503')) {
        await Future.delayed(Duration(seconds: 2));
        try {
          final UserCredential userCredential = 
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          
          if (userCredential.user != null) {
            _user = await _firebaseService.getUserData(userCredential.user!.uid);
            if (_user != null) {
              await mileageProvider.initializeUserMileage();
              notifyListeners();
            }
          }
        } catch (retryError) {
          throw '서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.';
        }
      } else {
        throw e.toString();
      }
    }
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<String> getUserName(String userId) async {
    return await _firebaseService.getUserName(userId);
  }

  Future<String?> getUserEmail(String uid) async {
    if (user?.uid == uid) {
      return user?.email;
    }

    if (_userEmails.containsKey(uid)) {
      return _userEmails[uid];
    }

    try {
      String? email = await _firebaseService.getUserEmail(uid);
      if (email != null) {
        _userEmails[uid] = email;
      }
      return email;
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }
}
