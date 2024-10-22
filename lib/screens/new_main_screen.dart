import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mileage_provider.dart';
import '../models/user_model.dart';
import 'mileage_recharge_screen.dart';
import 'room_list_screen.dart';

class NewMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final mileageProvider = Provider.of<MileageProvider>(context);
    final UserModel? user = authProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 버튼 비활성화
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFFFFFF),
          title: Text(
            '같이TA',
            style: TextStyle(
              fontSize: 50,
              fontFamily: 'WAGURI',
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => _navigateToMileageRechargeScreen(context),
                    icon: Icon(Icons.monetization_on),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '마일리지: ${mileageProvider.currentMileage}',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'WAGURI',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/symbol.png',
                      width: 300,
                      height: 300,
                    ),
                    SizedBox(height: 20),
                    if (mileageProvider.currentMileage >= 3500)
                      const Text(
                        '방을 찾아보세요!',
                        style: TextStyle(
                          fontSize: 23,
                          fontFamily: 'WAGURI',
                        ),
                      ),
                    SizedBox(height: 20),
                    if (mileageProvider.currentMileage >= 3500)
                      ElevatedButton(
                        onPressed: () => _navigateToRoomListScreen(context),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(200, 65),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: const Text(
                            '방 찾기!',
                            style: TextStyle(
                              fontSize: 22,
                              fontFamily: 'WAGURI',
                            ),
                          ),
                        ),
                      ),
                    if (mileageProvider.currentMileage < 3500)
                      Column(
                        children: [
                          Text(
                            '마일리지가 부족하여 매칭을 시작할 수 없습니다.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontFamily: 'WAGURI',
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '\$',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey,
                                    fontFamily: 'WAGURI',
                                  ),
                                ),
                                TextSpan(
                                  text: ' 를 눌러 마일리지를 충전하세요.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                    fontFamily: 'WAGURI',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '(최소 3500이상 필요)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontFamily: 'WAGURI',
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 150),
                    Text(
                      'made by Software',
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'WAGURI',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMileageRechargeScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MileageRechargeScreen(),
      ),
    );
  }

  void _navigateToRoomListScreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('경로 안내',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'WAGURI',
          ),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('출발지 : 장전역 4번 출구',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'WAGURI',
                color: Colors.orange,
              ),),
            SizedBox(height: 8),
            Text('도착지 : 부산가톨릭대학교 정문',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'WAGURI',
                color: Colors.orange,
              ),),
            SizedBox(height: 10),
            Text('출발지와 도착지가 정해져있습니다.',
              style: TextStyle(
                fontSize: 17,
                fontFamily: 'WAGURI',
              ),),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'WAGURI',
              ),),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoomListScreen()),
              );
            },
            child: Text('확인',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'WAGURI',
              ),),
          ),
        ],
      ),
    );
  }
}