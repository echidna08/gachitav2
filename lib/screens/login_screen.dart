import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mileage_provider.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final mileageProvider = Provider.of<MileageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('로그인', style: TextStyle(fontSize: 30, fontFamily: 'WAGURI')),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authProvider.signIn(emailController.text, passwordController.text, mileageProvider);
                  Navigator.pushReplacementNamed(context, '/main');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('로그인에 실패했습니다.')),
                  );
                }
              },
              child: Text('로그인', style: TextStyle(fontSize: 22, fontFamily: 'WAGURI')),
            ),
          ],
        ),
      ),
    );
  }
}