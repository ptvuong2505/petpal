import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import '../repositories/pet_profile_repository.dart';

class PetProfileProvider extends ChangeNotifier {
  PetProfileProvider({required PetProfileRepository repository})
    : _repository = repository;

  final PetProfileRepository _repository;

  List<Pet> pets = [];
  Pet? selectedPet;
  bool isLoading = false;

  void selectPet(Pet pet) {
    selectedPet = pet;
    notifyListeners();
  }

  Future<void> loadPets(int userId) async {
    isLoading = true;
    notifyListeners();

    try {
      pets = await _repository.getPets(userId);
    } catch (e) {
      debugPrint('Error loading pets: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addPet(Pet pet) async {
    isLoading = true;
    notifyListeners();

    try {
      final id = await _repository.addPet(pet);
      if (id > 0) {
        await loadPets(pet.userId);
        return null; // Success
      }
      return 'Không thể thêm thú cưng';
    } catch (e) {
      debugPrint('Error adding pet: $e');
      return 'Có lỗi xảy ra: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deletePet(int petId, int userId) async {
    isLoading = true;
    notifyListeners();

    try {
      final rowsAffected = await _repository.deletePet(petId);
      if (rowsAffected > 0) {
        await loadPets(userId);
        return null;
      }
      return 'Không thể xóa thú cưng';
    } catch (e) {
      debugPrint('Error deleting pet: $e');
      return 'Có lỗi xảy ra khi xóa: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
