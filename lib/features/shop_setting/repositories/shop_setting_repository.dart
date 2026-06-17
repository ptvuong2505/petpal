import '../data/shop_setting_dao.dart';
import '../models/shop_setting.dart';

class ShopSettingRepository {
  ShopSettingRepository({required ShopSettingDao dao}) : _dao = dao;

  final ShopSettingDao _dao;

  Future<ShopSetting?> getSetting() {
    return _dao.getSetting();
  }

  Future<int> saveSetting(ShopSetting setting) {
    return _dao.saveSetting(setting);
  }
}
