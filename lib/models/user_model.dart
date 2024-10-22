class UserModel {
  final String uid;
  final String email;
  final String name;
  int mileage;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.mileage = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      mileage: data['mileage'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'mileage': mileage,
    };
  }
}