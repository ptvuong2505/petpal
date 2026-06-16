import '../data/pet_profile_dao.dart';
import '../models/pet.dart';

class PetProfileRepository {
  PetProfileRepository({required PetProfileDao dao}) : _dao = dao;

  final PetProfileDao _dao;

  Future<List<Pet>> getPets(int userId) {
    return _dao.getPetsByUserId(userId);
  }

  Future<int> addPet(Pet pet) {
    return _dao.insertPet(pet);
  }

  Future<int> deletePet(int petId) {
    return _dao.deletePet(petId);
  }
}
