import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:tabung/home.dart';
import 'package:tabung/test_home.dart';

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool isNotificationHandled = false; // Flag to prevent duplicate navigation

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print("Notification tapped in background");

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!isNotificationHandled) {
      isNotificationHandled = true; // Set the flag to true
      navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (BuildContext context) {
        return HomePage();
      }));
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  await setupInteractedMessage();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/is_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: notificationTapBackground,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await initializeFirebaseMessaging();
  runApp(const MyApp());
}

Future<void> initializeFirebaseMessaging() async {
  await FirebaseMessaging.instance.subscribeToTopic('tabung');

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");

  if (fcmToken == null) {
    print("Failed to retrieve FCM token");
  }

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        '1',
        'tabung1',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? 'Title',
        message.notification?.body ?? 'Body',
        notificationDetails,
        payload: 'item x',
      );
    }
  });

  await setupInteractedMessage();
}

Future<void> setupInteractedMessage() async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  WidgetsFlutterBinding.ensureInitialized();
  if (initialMessage != null) {
    print("App opened from terminated state via notification");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isNotificationHandled) {
        isNotificationHandled = true;
        _handleNotification(initialMessage);
      }
    });
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (!isNotificationHandled) {
      isNotificationHandled = true;
      _handleNotification(message);
    }
  });
}

void _handleNotification(RemoteMessage message) {
  print("Notification tapped");
  if (navigatorKey.currentState?.canPop() ?? false) {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => HomePage()),
    (route) => false,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'IntelliSafe',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade100,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
