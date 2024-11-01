class RoomModel {
  final String id;
  final String title;
  final String creatorUid;
  final List<String> users;
  final Map<String, bool> payments;
  final List<Map<String, dynamic>> history;
  final bool isSettling;

  RoomModel({
    required this.id,
    required this.title,
    required this.creatorUid,
    required this.users,
    Map<String, bool>? payments,
    List<Map<String, dynamic>>? history,
    this.isSettling = false,
  })  : this.payments = payments ?? {},
        this.history = history ?? [];

  factory RoomModel.fromMap(Map<String, dynamic> data, String id) {
    return RoomModel(
      id: id,
      title: data['title'] ?? '',
      creatorUid: data['creatorUid'] ?? '',
      users: List<String>.from(data['users'] ?? []),
      payments: Map<String, bool>.from(data['payments'] ?? {}),
      history: List<Map<String, dynamic>>.from(data['history'] ?? []),
      isSettling: data['isSettling'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'creatorUid': creatorUid,
      'users': users,
      'payments': payments,
      'history': history,
      'isSettling': isSettling,
    };
  }
}
