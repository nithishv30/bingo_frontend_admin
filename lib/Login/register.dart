import 'package:flutter/material.dart';
import '../Api/auth_api_service.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  bool otpSent = false;
  bool loading = false;

  // ✅ SEND OTP (HERE you use AuthApiService.sendRegisterOtp)
  Future<void> sendOtp() async {
    setState(() => loading = true);

    try {
      final res = await AuthApiService.sendRegisterOtp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      print("API RESPONSE: $res"); // 🔥 DEBUG

      setState(() {
        loading = false;
        otpSent = res['success'] == true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Error')),
      );
    } catch (e) {
      setState(() => loading = false);

      print("ERROR: $e"); // 🔥 DEBUG

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // ✅ VERIFY OTP (HERE you use AuthApiService.verifyRegisterOtp)
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter OTP")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await AuthApiService.verifyRegisterOtp(
        email: emailController.text.trim(),
        otp: otpController.text.trim(),
      );

      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration success')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  Widget input(String hint, TextEditingController c, {bool pass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: pass,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            input('Name', nameController),
            input('Email', emailController),
            input('Password', passwordController, pass: true),

            if (otpSent)
              input('Enter OTP', otpController),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : (otpSent ? verifyOtp : sendOtp),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(otpSent ? 'Verify OTP' : 'Send OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}