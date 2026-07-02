import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_loading.dart';
import '../models/shop_setting.dart';
import '../providers/shop_setting_provider.dart';

class ShopSettingPage extends StatefulWidget {
  const ShopSettingPage({super.key});

  @override
  State<ShopSettingPage> createState() => _ShopSettingPageState();
}

class _ShopSettingPageState extends State<ShopSettingPage> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bookingPolicyController = TextEditingController();
  final _logoPathController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _didPopulate = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<ShopSettingProvider>();
      if (provider.setting == null && !provider.isLoading) {
        provider.loadSetting();
      }
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _descriptionController.dispose();
    _bookingPolicyController.dispose();
    _logoPathController.dispose();
    super.dispose();
  }

  void _populateForm(ShopSetting? setting) {
    if (_didPopulate) return;
    if (setting == null) return;

    _shopNameController.text = setting.shopName;
    _phoneController.text = setting.phone ?? '';
    _emailController.text = setting.email ?? '';
    _addressController.text = setting.address ?? '';
    _openTimeController.text = setting.openTime ?? '';
    _closeTimeController.text = setting.closeTime ?? '';
    _descriptionController.text = setting.description ?? '';
    _bookingPolicyController.text = setting.bookingPolicy ?? '';
    _logoPathController.text = setting.logoPath ?? '';
    _didPopulate = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<ShopSettingProvider>();
    final current = provider.setting;
    final setting = ShopSetting(
      id: current?.id ?? 1,
      shopName: _shopNameController.text.trim(),
      phone: _emptyToNull(_phoneController.text),
      email: _emptyToNull(_emailController.text),
      address: _emptyToNull(_addressController.text),
      openTime: _emptyToNull(_openTimeController.text),
      closeTime: _emptyToNull(_closeTimeController.text),
      description: _emptyToNull(_descriptionController.text),
      bookingPolicy: _emptyToNull(_bookingPolicyController.text),
      logoPath: _emptyToNull(_logoPathController.text),
      updatedAt: DateTime.now().toIso8601String(),
    );

    try {
      await provider.saveSetting(setting);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu cài đặt cửa hàng.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể lưu cài đặt cửa hàng.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetForm() {
    _didPopulate = false;
    final setting = context.read<ShopSettingProvider>().setting;
    if (setting == null) {
      _clearForm();
    } else {
      _populateForm(setting);
    }
    setState(() {});
  }

  void _clearForm() {
    _shopNameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _openTimeController.clear();
    _closeTimeController.clear();
    _descriptionController.clear();
    _bookingPolicyController.clear();
    _logoPathController.clear();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _pickLogo() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    setState(() {
      _logoPathController.text = pickedFile.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopSettingProvider>();

    if (provider.isLoading && provider.setting == null) {
      return const AppLoading();
    }

    _populateForm(provider.setting);

    return SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _BrandCard(
              logoPathController: _logoPathController,
              onPickLogo: _pickLogo,
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              title: 'Thông tin cơ bản',
              icon: Icons.storefront,
              children: [
                _LabeledField(
                  label: 'Tên cửa hàng',
                  controller: _shopNameController,
                  icon: Icons.store_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên cửa hàng';
                    }
                    return null;
                  },
                ),
                _LabeledField(
                  label: 'Số điện thoại liên hệ',
                  controller: _phoneController,
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                ),
                _LabeledField(
                  label: 'Email',
                  controller: _emailController,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return null;
                    if (!text.contains('@')) {
                      return 'Email chưa hợp lệ';
                    }
                    return null;
                  },
                ),
                _LabeledField(
                  label: 'Địa chỉ cửa hàng',
                  controller: _addressController,
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsCard(
              title: 'Hoạt động & giới thiệu',
              icon: Icons.schedule,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        label: 'Giờ mở cửa',
                        controller: _openTimeController,
                        icon: Icons.access_time,
                        readOnly: true,
                        onTap: () => _pickTime(_openTimeController),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _LabeledField(
                        label: 'Giờ đóng cửa',
                        controller: _closeTimeController,
                        icon: Icons.access_time_filled,
                        readOnly: true,
                        onTap: () => _pickTime(_closeTimeController),
                      ),
                    ),
                  ],
                ),
                _LabeledField(
                  label: 'Mô tả cửa hàng',
                  controller: _descriptionController,
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                _LabeledField(
                  label: 'Chính sách đặt lịch & hủy',
                  controller: _bookingPolicyController,
                  icon: Icons.policy_outlined,
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ActionBar(
              isSaving: _isSaving,
              onCancel: _resetForm,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final initialTime = _parseTime(controller.text) ?? TimeOfDay.now();
    final value = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (value == null) return;

    controller.text =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.logoPathController,
    required this.onPickLogo,
  });

  final TextEditingController logoPathController;
  final VoidCallback onPickLogo;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Ảnh đại diện',
      icon: Icons.image_outlined,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: logoPathController,
              builder: (context, value, child) {
                return _LogoPreview(path: value.text.trim());
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Logo cửa hàng',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Chọn ảnh từ thư viện. Đường dẫn ảnh sẽ được lưu vào logo_path.',
                    style: TextStyle(color: AppColors.subText, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onPickLogo,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Chọn logo'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: logoPathController,
                    builder: (context, value, child) {
                      final path = value.text.trim();
                      if (path.isEmpty) {
                        return const Text(
                          'Chưa chọn ảnh logo.',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        );
                      }
                      return Text(
                        path,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    Widget child = const Icon(Icons.pets, color: AppColors.primary, size: 40);

    if (path.startsWith('http://') || path.startsWith('https://')) {
      child = Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: AppColors.primary);
        },
      );
    } else if (path.isNotEmpty) {
      child = Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: AppColors.primary);
        },
      );
    }

    return Container(
      width: 96,
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.28),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondaryContainer, width: 2),
      ),
      child: child,
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._withSpacing(children),
        ],
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> items) {
    return [
      for (var index = 0; index < items.length; index++) ...[
        items[index],
        if (index != items.length - 1) const SizedBox(height: 14),
      ],
    ];
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }
}

InputDecoration _inputDecoration({required String label, IconData? icon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.surfaceVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
  );
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;
        final buttons = [
          OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hủy bỏ'),
          ),
          FilledButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ];

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [buttons[1], const SizedBox(height: 10), buttons[0]],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [buttons[0], const SizedBox(width: 12), buttons[1]],
        );
      },
    );
  }
}
