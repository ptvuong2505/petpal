import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import '../repositories/pet_profile_repository.dart';

class PetProfileProvider extends ChangeNotifier {
  PetProfileProvider({required PetProfileRepository repository})
    : _repository = repository;

  final PetProfileRepository _repository;

  List<Pet> pets = [];
  bool isLoading = false;

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

  Future<void> addPet(Pet pet) async {
    await _repository.addPet(pet);
    await loadPets(pet.userId);
  }
}
