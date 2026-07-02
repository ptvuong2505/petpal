import 'package:flutter/foundation.dart';

import '../models/shop_setting.dart';
import '../repositories/shop_setting_repository.dart';

class ShopSettingProvider extends ChangeNotifier {
  ShopSettingProvider({required ShopSettingRepository repository})
      : _repository = repository;

  final ShopSettingRepository _repository;

  ShopSetting? setting;
  bool isLoading = false;

  Future<void> loadSetting() async {
    isLoading = true;
    notifyListeners();

    setting = await _repository.getSetting();

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveSetting(ShopSetting value) async {
    await _repository.saveSetting(value);
    setting = value;
    notifyListeners();
  }
}
