import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/navigation_service.dart';
import '../../booking/models/service.dart';
import '../providers/admin_service_provider.dart';

class AdminEditServicePage extends StatefulWidget {
  const AdminEditServicePage({this.service, super.key});

  final Service? service;

  @override
  State<AdminEditServicePage> createState() => _AdminEditServicePageState();
}

class _AdminEditServicePageState extends State<AdminEditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late String _status;

  bool get _isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descController = TextEditingController(text: widget.service?.description ?? '');
    _priceController = TextEditingController(text: widget.service?.price.toInt().toString() ?? '0');
    _durationController = TextEditingController(text: widget.service?.durationMinutes.toString() ?? '30');
    _status = widget.service?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final service = Service(
      id: widget.service?.id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      durationMinutes: int.tryParse(_durationController.text) ?? 30,
      status: _status,
    );

    final provider = context.read<AdminServiceProvider>();
    bool success;
    if (_isEdit) {
      success = await provider.updateService(service);
    } else {
      success = await provider.addService(service);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Cập nhật thành công' : 'Thêm mới thành công')),
      );
      NavigationService.goBack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên dịch vụ*', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Giá (VNĐ)*', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Thời lượng (phút)*', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'active', child: Text('Hoạt động')),
                DropdownMenuItem(value: 'inactive', child: Text('Tạm ngưng')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Mô tả', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _save,
                child: Text(_isEdit ? 'Lưu thay đổi' : 'Thêm dịch vụ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
