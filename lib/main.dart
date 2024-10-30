import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:skyline_project/notification.dart';
import 'package:skyline_project/pushNotification.dart';
import "login_screen.dart";
import "content.dart";
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

Future _firebaseMessangingBackground(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handle message ${message.messageId} ");
  RemoteMessage? inititalMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (inititalMessage != null) {
    PushNotification notification = PushNotification(
        title: inititalMessage.notification?.title ?? "",
        body: inititalMessage.notification?.body ?? "",
        dataTitle: inititalMessage.data["title"] ?? "",
        dataBody: inititalMessage.data["body"] ?? '');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      //options: DefaultFirebaseOptions.currentPlatform,
      );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessangingBackground);
  NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    firebaseMessaging
        .getToken()
        .then((token) => print("firebase token :$token"));
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skyline Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
