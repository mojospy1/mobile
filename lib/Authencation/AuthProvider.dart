import 'package:apphoctienganh/home/home.dart';
import 'package:apphoctienganh/Authencation/login.dart';
import 'package:apphoctienganh/Authencation/register.dart';
import 'package:apphoctienganh/Authencation/sendemailpassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  User? get user => _user;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '903116171238-i65g2ggefo7c5lcgcr9mcrnr7ebfitvb.apps.googleusercontent.com',
  );

  //  hide password in client
  bool _isObscure = true;
  bool get isObscure => _isObscure;
  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
  Future<void> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Chuyển đến màn hình đăng ký sau khi đăng nhập thành công
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Đăng nhập thất bại";
    }
  }

  // Đăng ký tài khoản mới
  Future<void> registerAccount(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Sau khi đăng ký thành công, có thể chuyển sang màn hình khác hoặc hiện thông báo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Đăng ký thất bại";
    }
  }

  void goToRegisterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Register_Screen()),
    );
  }

  void goToResetpassPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EnterEmailScreen()),
    );
  }

  // Đăng xuất khỏi Google cả  phần email
  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Điều hướng tường minh về màn hình đăng nhập
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false, // Xóa toàn bộ stack
      );
    } catch (e) {
      print('Đăng xuất thất bại: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra khi đăng xuất!')));
    }
  }

  // method hide  password
  void toggleObscure() {
    _isObscure = !_isObscure;
    notifyListeners();
  }

  // Phương thức gửi email reset mật khẩu
  Future<void> sendResetPasswordEmail(
    String email,
    BuildContext context,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Thông báo người dùng nếu gửi email thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi email để đặt lại mật khẩu vui lòng kiểm tra email ',
          ),
        ),
      );
    } catch (e) {
      // Thông báo lỗi nếu gửi email thất bại
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  // Đăng nhập với Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Mở màn hình đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      // Kiểm tra nếu người dùng huỷ đăng nhập
      if (googleUser == null) {
        print('Người dùng đã huỷ đăng nhập.');
        return null;
      }

      // Lấy thông tin xác thực từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential từ accessToken và idToken
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase với credential vừa tạo
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Lỗi trong quá trình đăng nhập với Google: $e');
      rethrow;
    }
  }

  // lấy profile
  Map<String, dynamic>? getCurrentUserProfile() {
    User? user = _auth.currentUser;

    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'phoneNumber': user.phoneNumber,
        'isEmailVerified': user.emailVerified,
      };
    }

    return null; // Người dùng chưa đăng nhập
  }
}
