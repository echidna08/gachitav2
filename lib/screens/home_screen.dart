import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        title: Text(
          '같이TA',
          style: TextStyle(
            fontSize: 50,
            fontFamily: 'WAGURI',
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/symbol.png',
              width: 300,
              height: 300,
            ),
            SizedBox(height: 20),
            const Text(
              '로그인을 해주세요!',
              style: TextStyle(
                fontSize: 23,
                fontFamily: 'WAGURI',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 65),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'WAGURI',
                  ),
                ),
              ),
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
    );
  }
}