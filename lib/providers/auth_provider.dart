import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../providers/mileage_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> signIn(String email, String password, MileageProvider mileageProvider) async {
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
}