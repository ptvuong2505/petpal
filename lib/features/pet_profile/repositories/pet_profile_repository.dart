import '../data/pet_profile_dao.dart';
import '../models/pet.dart';

class PetProfileRepository {
  PetProfileRepository({required PetProfileDao dao}) : _dao = dao;

  final PetProfileDao _dao;

  Future<List<Pet>> getPets() {
    return _dao.getPets();
  }

  Future<int> addPet(Pet pet) {
    return _dao.insertPet(pet);
  }
}
