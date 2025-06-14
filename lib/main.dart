import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_iot_screen/providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:speech_to_text_iot_screen/providers/classes_provider.dart';
import 'package:speech_to_text_iot_screen/providers/custom_stt_provider.dart';
import 'package:speech_to_text_iot_screen/providers/lectures_provider.dart';
import 'package:speech_to_text_iot_screen/repositories/lectures_repository.dart';
import 'package:speech_to_text_iot_screen/services/notification_service.dart';
import 'package:speech_to_text_iot_screen/ui/authentication/login_screen.dart';
import 'package:speech_to_text_iot_screen/ui/home/home_screen.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  final authProvider = AuthProvider();
  await authProvider.loadUser();
  runApp(MyApp(authProvider: authProvider,));
}

class MyApp extends StatefulWidget {
  final AuthProvider authProvider;
  const MyApp({super.key,required this.authProvider});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final SpeechToText speech = SpeechToText();
  late CustomSttProvider speechProvider;
  late ClassesProvider classesProvider;

  @override
  void initState() {
    super.initState();
    speechProvider = CustomSttProvider(speech);
    classesProvider = ClassesProvider();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    await speechProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<CustomSttProvider>.value(
            value: speechProvider,
          ),
          ChangeNotifierProvider(create: (_)=> classesProvider),
          ChangeNotifierProvider(create: (_) => widget.authProvider),
          ChangeNotifierProvider(create: (_) => LectureProvider(
              repository: LectureRepository(),
              authProvider: widget.authProvider)..fetchLectures()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.blueAccent,
              surface: Colors.white,
              onSecondary: Colors.black54,
            ),
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/home': (context) => const HomeScreen(),
            '/login': (context) => const LoginScreen(),
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
        ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}


