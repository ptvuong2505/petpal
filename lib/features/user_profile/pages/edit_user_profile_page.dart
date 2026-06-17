import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class EditUserProfilePage extends StatelessWidget {
  const EditUserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EditUserProfileView();
  }
}

class _EditUserProfileView extends StatefulWidget {
  const _EditUserProfileView();

  @override
  State<_EditUserProfileView> createState() => _EditUserProfileViewState();
}

class _EditUserProfileViewState extends State<_EditUserProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Regex mật khẩu: ít nhất 1 hoa, 1 thường, 1 số, tối thiểu 8 ký tự
  final _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _fullNameController = TextEditingController(text: user?.fullName);
    _emailController = TextEditingController(text: user?.email);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController(text: user?.phone);
    _addressController = TextEditingController(text: user?.address);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final currentUser = authProvider.currentUser;

      if (currentUser == null) return;

      // Nếu mật khẩu để trống thì giữ nguyên mật khẩu cũ
      final String newPassword = _passwordController.text.isEmpty
          ? (currentUser.password ?? '')
          : _passwordController.text;

      final updatedUser = currentUser.copyWith(
        fullName: _fullNameController.text.trim(),
        password: newPassword,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      final error = await authProvider.updateProfile(updatedUser);

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật hồ sơ thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    // Chỉ trả về nội dung Body, bỏ Scaffold và AppBar vì đã có AppLayout bọc bên ngoài
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chỉnh sửa thông tin cá nhân',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Email
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email (Không thể thay đổi)',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Họ tên
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 16),

            // Mật khẩu mới
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới (Để trống nếu không đổi)',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != null && v.isNotEmpty) {
                  if (!_passwordRegex.hasMatch(v)) {
                    return 'Mật khẩu phải có ít nhất 8 ký tự, gồm chữ hoa, chữ thường và số';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Xác nhận mật khẩu mới
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: const Icon(Icons.lock_reset),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (v) {
                if (_passwordController.text.isNotEmpty) {
                  if (v == null || v.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu mới';
                  }
                  if (v != _passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Số điện thoại
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                prefixIcon: Icon(Icons.phone_android_outlined),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Địa chỉ
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Nút Lưu
            ElevatedButton(
              onPressed: isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'LƯU THAY ĐỔI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
