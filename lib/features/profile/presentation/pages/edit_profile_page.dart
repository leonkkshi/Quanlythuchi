// lib/features/profile/presentation/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../application/providers/profile_provider.dart';

/// Màn hình chỉnh sửa hồ sơ với validate.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarSeedController = TextEditingController();

  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initForm());
  }

  Future<void> _initForm() async {
    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    final user = await authService.getCurrentUser();
    if (user == null || !mounted) return;

    _userId = user.id;
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    await provider.loadProfile(user.id);

    final profile = provider.profile;
    _nameController.text = profile?.name ?? user.name;
    _emailController.text = profile?.email ?? user.email;
    _phoneController.text = profile?.phone ?? '';

    var seed = profile?.name ?? user.name;
    final avatar = profile?.avatar ?? user.avatarUrl;
    if (avatar != null) {
      try {
        seed = Uri.parse(avatar).queryParameters['seed'] ?? seed;
      } catch (_) {}
    }
    _avatarSeedController.text = seed;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarSeedController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    final provider = Provider.of<ProfileProvider>(context, listen: false);
    provider.clearError();

    final success = await provider.updateProfile(
      userId: _userId!,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      avatarSeed: _avatarSeedController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật hồ sơ thành công!')),
      );
      context.pop();
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chỉnh Sửa Hồ Sơ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(IconlyLight.profile),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tên không được để trống';
                      }
                      if (value.trim().length < 2) {
                        return 'Tên phải có ít nhất 2 ký tự';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(IconlyLight.message),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email không được để trống';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(IconlyLight.call),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Số điện thoại không được để trống';
                      }
                      if (!RegExp(r'^[0-9]{9,11}$').hasMatch(value.trim())) {
                        return 'Số điện thoại phải gồm 9–11 chữ số';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _avatarSeedController,
                    decoration: const InputDecoration(
                      labelText: 'Từ khóa avatar (seed)',
                      prefixIcon: Icon(IconlyLight.image),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Từ khóa avatar không được để trống';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: provider.isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                    ),
                    child: provider.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Lưu thay đổi'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
