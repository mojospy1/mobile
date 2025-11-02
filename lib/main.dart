import 'package:apphoctienganh/Authencation/AuthProvider.dart';
import 'package:apphoctienganh/Authencation/start_screen.dart';
import 'package:apphoctienganh/Flashcash/FlashcardProvider.dart';
import 'package:apphoctienganh/game_learn/BigFlashcardProvider.dart';
import 'package:apphoctienganh/game_learn/FillInTheBlankProvider.dart';
import 'package:apphoctienganh/game_learn/WordScrambleProvider.dart';
import 'package:apphoctienganh/game_learn/popupprovider.dart';
import 'package:apphoctienganh/game_learn/question_answer_provider.dart';
import 'package:apphoctienganh/game_learn/quizprovider.dart';
import 'package:apphoctienganh/game_learn/speakquestionprovider.dart';
import 'package:apphoctienganh/game_learn/word_guessing_provider.dart';
import 'package:apphoctienganh/home/HomeProvider.dart';
import 'package:apphoctienganh/home/SpeechProvider';
import 'package:apphoctienganh/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Đổi tên import firebase_auth
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

const apiKey = 'AIzaSyAUAc0KkA1xS1BR9WkoyuhviTjDl4ry6-Y';
// Khởi tạo GlobalKey để sử dụng ScaffoldMessenger
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register firebase
  await Firebase.initializeApp();

  // Register gemini API
  Gemini.init(apiKey: apiKey, enableDebugging: true);

  // Kiểm tra trạng thái đăng nhập khi ứng dụng khởi động
  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;

  // Yêu cầu quyền thông báo cho Android
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Cấu hình Firebase Cloud Messaging
  await FirebaseMessaging.instance.requestPermission();

  // Lấy token FCM để test
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");

  // Lắng nghe khi người dùng nhấn vào thông báo
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message clicked! ${message.notification?.title}');
  });

  // Lắng nghe khi có thông báo trong foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print(
      'Received a message while the app is in the foreground: ${message.notification?.title}',
    );

    // Hiển thị SnackBar với AwesomeSnackbarContent và nền trong suốt
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          "Thông báo từ hệ thống: ${message.notification?.title ?? 'Không có tiêu đề'}\n"
          "${message.notification?.body ?? 'Không có thông tin chi tiết'}",
        ),
        duration: Duration(seconds: 3),
        
      ),
    );
  });

  // Đăng ký xử lý thông báo trong background hoặc khi ứng dụng bị đóng
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SpeechProvider()),
        ChangeNotifierProvider(create: (_) => QuestionAnswerProvider()),
        ChangeNotifierProvider(create: (_) => BigFlashcardProvider()),
        ChangeNotifierProvider(create: (_) => Popupprovider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => WordGuessProvider()),
        ChangeNotifierProvider(create: (_) => WordScrambleProvider()),
        ChangeNotifierProvider(create: (_) => FillInTheBlankProvider()),
        ChangeNotifierProvider(create: (_) => SpeechQuestionProvider()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey:
            scaffoldMessengerKey, // Sử dụng global key cho ScaffoldMessenger
        home: user != null ? HomePage() : Start_Screen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

// Xử lý thông báo trong nền (background)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
