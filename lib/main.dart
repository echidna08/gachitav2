import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './providers/auth_provider.dart' as app_auth;
import './providers/mileage_provider.dart';
import './providers/room_provider.dart';
import './screens/login_screen.dart';
import './screens/new_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => MileageProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
      ],
      child: MaterialApp(
        title: '같이TA',
        theme: ThemeData(
          primaryColor: Color(0xFF4A55A2),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Pretendard',
        ),
        home: LoginScreen(),
      ),
    );
  }
}
