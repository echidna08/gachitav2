import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../providers/mileage_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;
  Map<String, String> _userEmails = {}; // uid to email mapping

  UserModel? get user => _user;

  Future<void> signIn(
      String email, String password, MileageProvider mileageProvider) async {
    try {
      User? firebaseUser = await _firebaseService.signIn(email, password);
      if (firebaseUser != null) {
        _user = await _firebaseService.getUserData(firebaseUser.uid);
        await mileageProvider.initializeUserMileage();
        notifyListeners();
      }
    } catch (e) {
      print(e);
      rethrow;
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
