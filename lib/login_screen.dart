import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:skyline_project/Login_response.dart';
import 'package:skyline_project/commonTextWidget.dart';
import 'package:http/http.dart' as http;
import 'package:skyline_project/content.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skyline_project/notification.dart';
import 'package:skyline_project/pushNotification.dart';

Future<void> FirebaseMessangingInBackgroundHandler(
    RemoteMessage message) async {}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordVisible = false;
  bool checkBoxChecked = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late FirebaseMessaging messaging;
  int totalNotification = 0;
  late PushNotification notificationInfo;

  void registerNotification() async {
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(
        FirebaseMessangingInBackgroundHandler);
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("message title: ${message.notification?.title}");

        PushNotification notification = PushNotification(
            title: message.notification?.title ?? "",
            body: message.notification?.body ?? "",
            dataTitle: message.data["title"] ?? "",
            dataBody: message.data["body"] ?? '');

        setState(() {
          notificationInfo = notification;
          totalNotification++;
        });
        if (notificationInfo != null) {
          showSimpleNotification(Text(notification.title ?? ""),
              subtitle: Text(notification.body ?? ""),
              duration: Duration(seconds: 2),
              background: Colors.cyan.shade700);
        }
      });
    } else {
      print("user declined or has not accepted permission");
    }
  }

  checkInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      PushNotification notification = PushNotification(
          title: initialMessage.notification?.title ?? "",
          body: initialMessage.notification?.body ?? "",
          dataTitle: initialMessage.data["title"] ?? "",
          dataBody: initialMessage.data["body"] ?? '');

      setState(() {
        notificationInfo = notification;
        totalNotification++;
      });
    }
  }

  @override
  void initState() {
    totalNotification = 0;
    registerNotification();
    checkInitialMessage();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
          title: message.notification?.title ?? "",
          body: message.notification?.body ?? "",
          dataTitle: message.data["title"] ?? "",
          dataBody: message.data["body"] ?? '');

      setState(() {
        notificationInfo = notification;
        totalNotification++;
      });
    });
    super.initState();
    NotificationService().initialize();
  }

  Future<void> login() async {
    final String url = 'https://test.bookinggksm.com/api/auth/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text,
          "password": passwordController.text,
          "user_type": 4,
          //  "device_token": "temp"
          "device_token": await FirebaseMessaging.instance.getToken() ?? ""
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginInResponse.fromJson(jsonResponse);

        if (loginResponse.status == true) {
          // Successfully logged in
          NotificationService().showNotification(
              title: "Login Successful",
              body: loginResponse.message ?? "Welcome to the app!");
          //  NotificationService().subscribeToTopic('your_topic_name');
          print(loginResponse.message);
          print("API TOKEN: ${loginResponse.token}");

          // Navigate to next screen or update UI
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ContentWidget(token: loginResponse.token ?? "")),
          );
        } else {
          // Handle login failure
          print('Login failed: ${loginResponse.message}');
          NotificationService().showNotification(
              title: "Login Failed",
              body: loginResponse.message ?? "Please check your credentials");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${loginResponse.message}"),
            ),
          );
        }
      } else {
        print('Error: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("${response.reasonPhrase} Please Enter Valid Details"),
          ),
        );
      }
    } catch (error) {
      print('Error occurred: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please Enter Valid Details"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      const Text(
                        "Log in Now",
                        style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFF03467D),
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      const Align(
                        child: Text(
                          'Please Login to continue using our app',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF757B80)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 56),
                      const CommonTextWidget(
                          hintText: "Associate", isDisabled: true),
                      const SizedBox(height: 12),
                      CommonTextWidget(
                          controller: emailController, hintText: "Email"),
                      const SizedBox(height: 12),
                      CommonTextWidget(
                        controller: passwordController,
                        hintText: "Password",
                        obscureText: !isPasswordVisible,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF03467D)),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                              value: checkBoxChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  checkBoxChecked = value ?? false;
                                });
                              }),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                                color: Color(0xFF03467D),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password',
                              style: TextStyle(
                                  color: Color(0xFF03467D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            backgroundColor: Color(0xFF03467D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF03467D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
