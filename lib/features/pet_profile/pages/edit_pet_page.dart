import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/pet_profile_provider.dart';

class EditPetPage extends StatelessWidget {
  const EditPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EditPetView();
  }
}

class _EditPetView extends StatefulWidget {
  const _EditPetView();

  @override
  State<_EditPetView> createState() => _EditPetViewState();
}

class _EditPetViewState extends State<_EditPetView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _noteController;
  late TextEditingController _birthDateController;

  String? _selectedSpecies;
  String? _selectedGender;
  File? _imageFile;
  String? _existingImagePath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _speciesList = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other'];
  final List<String> _genderList = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    final pet = context.read<PetProfileProvider>().selectedPet;
    _nameController = TextEditingController(text: pet?.name);
    _breedController = TextEditingController(text: pet?.breed);
    _weightController = TextEditingController(text: pet?.weight?.toString());
    _noteController = TextEditingController(text: pet?.note);
    _birthDateController = TextEditingController(text: pet?.birthDate);
    _selectedSpecies = pet?.species;
    _selectedGender = pet?.gender;
    _existingImagePath = pet?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _noteController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_birthDateController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthDateController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final petProvider = context.read<PetProfileProvider>();
      final currentPet = petProvider.selectedPet;
      if (currentPet == null) return;

      final updatedPet = currentPet.copyWith(
        name: _nameController.text.trim(),
        species: _selectedSpecies,
        breed: _breedController.text.trim(),
        gender: _selectedGender,
        birthDate: _birthDateController.text,
        weight: double.tryParse(_weightController.text),
        note: _noteController.text.trim(),
        imagePath: _imageFile?.path ?? _existingImagePath,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final error = await petProvider.updatePet(updatedPet);

      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thông tin thành công!'),
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
    final isLoading = context.watch<PetProfileProvider>().isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phần chọn ảnh
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : (_existingImagePath != null &&
                                _existingImagePath!.isNotEmpty)
                          ? ClipOval(
                              child: Image.file(
                                File(_existingImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tên thú cưng
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên thú cưng *',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Vui lòng nhập tên thú cưng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Loài và Giới tính
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSpecies,
                    decoration: const InputDecoration(
                      labelText: 'Loài',
                      border: OutlineInputBorder(),
                    ),
                    items: _speciesList
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSpecies = v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Giới tính',
                      border: OutlineInputBorder(),
                    ),
                    items: _genderList
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Giống
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Giống (Breed)',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Ngày sinh và Cân nặng
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: const InputDecoration(
                      labelText: 'Ngày sinh *',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Chọn ngày' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cân nặng (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = double.tryParse(v);
                      if (n == null) return 'Phải là số';
                      if (n <= 0) return 'Phải > 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ghi chú
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Ghi chú đặc biệt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Nút Lưu
            ElevatedButton(
              onPressed: isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'CẬP NHẬT THÔNG TIN',
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
