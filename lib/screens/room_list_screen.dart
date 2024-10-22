import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/room_provider.dart';
import '../providers/auth_provider.dart';
import '../models/room_model.dart';
import 'room_screen.dart';

class RoomListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '방 목록',
          style: TextStyle(
            fontFamily: 'WAGURI',
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<RoomModel>>(
        stream: roomProvider.getRoomsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('방이 없습니다.'));
          }

          List<RoomModel> rooms = snapshot.data!;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              RoomModel room = rooms[index];
              return ListTile(
                title: Text(room.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'WAGURI',
                  ),
                ),
                subtitle: Text('참가자: ${room.users.length}/4',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'WAGURI',
                  ),),
                onTap: () => _joinRoom(context, room, authProvider.user!.uid),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createRoom(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _joinRoom(BuildContext context, RoomModel room, String userId) async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);

    if (room.users.length < 4 && !room.users.contains(userId)) {
      await roomProvider.joinRoom(room.id, userId);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoomScreen(roomId: room.id)),
      );
    } else if (room.users.contains(userId)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RoomScreen(roomId: room.id)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('방이 가득 찼습니다.')),
      );
    }
  }

  void _createRoom(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    TextEditingController roomTitleController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('방 생성',
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'WAGURI',
            ),),
          content: TextField(
            controller: roomTitleController,
            decoration: InputDecoration(hintText: "방 제목",
              hintStyle: TextStyle(
                fontSize: 17,
                fontFamily: 'WAGURI',
              ),),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'WAGURI',
                ),),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                RoomModel? newRoom = await roomProvider.createRoom(
                    roomTitleController.text,
                    authProvider.user!.uid
                );
                if (newRoom != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoomScreen(roomId: newRoom.id)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('방 생성에 실패했습니다.')),
                  );
                }
              },
              child: Text('확인',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'WAGURI',
                ),),
            ),
          ],
        );
      },
    );
  }
}