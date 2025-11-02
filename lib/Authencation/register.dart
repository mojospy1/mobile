import 'package:apphoctienganh/Authencation/AuthProvider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Register_Screen extends StatefulWidget {
  const Register_Screen({super.key});

  @override
  State<Register_Screen> createState() => _Register_ScreenState();
}

class _Register_ScreenState extends State<Register_Screen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _cfPassController = TextEditingController();
  bool _isObscure = true;
  bool _isObscureCf = true;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Tạo tài khoản ', style: TextStyle(fontSize: 20)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildLabel("Email"),
                _buildTextField(
                  _emailController,
                  "Email",
                  false,
                  _emailValidator,
                ),
                const SizedBox(height: 15),
                _buildLabel("Mật khẩu"),
                _buildPasswordField1(),
                const SizedBox(height: 15),
                _buildLabel("Xác nhận mật khẩu"),
                _buildPasswordField2(),
                const SizedBox(height: 18),
                _buildCheckbox(),
                const SizedBox(height: 18),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(83, 209, 197, 1),
                  ),
                  onPressed: _onRegisterPressed,
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool obscure,
    String? Function(String?) validator,
  ) => TextFormField(
    controller: controller,
    obscureText: obscure,
    decoration: _inputDecoration(hint),
    validator: validator,
  );

  Widget _buildPasswordField1() => TextFormField(
    controller: _passController,
    obscureText: _isObscure,
    decoration: _inputDecoration("Mật khẩu").copyWith(
      suffixIcon: IconButton(
        icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _isObscure = !_isObscure;
          });
        },
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
      if (value.length < 6) return 'Mật khẩu ít nhất 6 ký tự';
      return null;
    },
  );

  Widget _buildPasswordField2() => TextFormField(
    controller: _cfPassController,
    obscureText: _isObscureCf,
    decoration: _inputDecoration("Xác nhận mật khẩu").copyWith(
      suffixIcon: IconButton(
        icon: Icon(_isObscureCf ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _isObscureCf = !_isObscureCf;
          });
        },
      ),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
      if (value != _passController.text) return 'Mật khẩu không khớp';
      return null;
    },
  );

  Widget _buildCheckbox() => Row(
    children: [
      Checkbox(
        value: _isChecked,
        onChanged: (val) => setState(() => _isChecked = val!),
      ),
      const SizedBox(width: 5),
      Expanded(
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: [
              const TextSpan(text: 'Tôi chấp nhận '),
              TextSpan(
                text: 'Điều khoản sử dụng',
                style: const TextStyle(fontWeight: FontWeight.bold),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () => print('Điều khoản sử dụng'),
              ),
              const TextSpan(text: ' và '),
              TextSpan(
                text: 'Chính sách bảo mật',
                style: const TextStyle(fontWeight: FontWeight.bold),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap = () => print('Chính sách bảo mật'),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
  );

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  void _onRegisterPressed() async {
    if (_formKey.currentState!.validate()) {
      if (!_isChecked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn cần chấp nhận điều khoản")),
        );
        return;
      }
      try {
        await Provider.of<AuthProvider>(context, listen: false).registerAccount(
          _emailController.text.trim(),
          _passController.text.trim(),
          context,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
