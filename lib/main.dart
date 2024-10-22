import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Providers
import './providers/auth_provider.dart';
import './providers/room_provider.dart';
import './providers/mileage_provider.dart';

// Screens
import './screens/home_screen.dart';
import './screens/login_screen.dart';
import './screens/new_main_screen.dart';
import './screens/room_list_screen.dart';
import './screens/room_screen.dart';
import './screens/settlement_confirmation_screen.dart';
import './screens/payment_instruction_screen.dart';
import './screens/mileage_recharge_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => MileageProvider()),
      ],
      child: MaterialApp(
        title: '같이TA',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'WAGURI',
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => HomeScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => LoginScreen());
            case '/main':
              return MaterialPageRoute(builder: (_) => NewMainScreen());
            case '/rooms':
              return MaterialPageRoute(builder: (_) => RoomListScreen());
            case '/room':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => RoomScreen(roomId: args?['roomId'] ?? ''),
              );
            case '/settlement':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => SettlementConfirmationScreen(roomId: args?['roomId'] ?? ''),
              );
            case '/payment_instruction':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => PaymentInstructionScreen(roomId: args?['roomId'] ?? ''),
              );
            case '/mileage_recharge':
              return MaterialPageRoute(
                builder: (_) => MileageRechargeScreen(),
              );
            default:
              return MaterialPageRoute(builder: (_) => HomeScreen());
          }
        },
      ),
    );
  }
}