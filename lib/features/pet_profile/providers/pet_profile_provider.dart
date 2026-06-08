import 'package:flutter/foundation.dart';

import '../models/pet.dart';
import '../repositories/pet_profile_repository.dart';

class PetProfileProvider extends ChangeNotifier {
  PetProfileProvider({required PetProfileRepository repository})
    : _repository = repository;

  final PetProfileRepository _repository;

  List<Pet> pets = [];
  bool isLoading = false;

  Future<void> loadPets() async {
    isLoading = true;
    notifyListeners();

    pets = await _repository.getPets();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addPet(Pet pet) async {
    await _repository.addPet(pet);
    await loadPets();
  }
}
