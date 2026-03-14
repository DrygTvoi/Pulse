import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_status.dart';

class StatusService {
  static final StatusService instance = StatusService._();
  StatusService._();

  static const String _ownStatusKey = 'my_status';
  static String _contactKey(String contactId) => 'contact_status_$contactId';

  Future<UserStatus?> getOwnStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_ownStatusKey);
    final status = UserStatus.tryFromJsonString(json);
    if (status != null && status.isExpired) {
      await clearOwnStatus();
      return null;
    }
    return status;
  }

  Future<void> setOwnStatus(UserStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ownStatusKey, status.toJsonString());
  }

  Future<void> clearOwnStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ownStatusKey);
  }

  Future<UserStatus?> getContactStatus(String contactId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_contactKey(contactId));
    final status = UserStatus.tryFromJsonString(json);
    if (status != null && status.isExpired) {
      await _clearContactStatus(contactId);
      return null;
    }
    return status;
  }

  Future<void> saveContactStatus(String contactId, UserStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contactKey(contactId), status.toJsonString());
  }

  Future<void> _clearContactStatus(String contactId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_contactKey(contactId));
  }

  /// Returns active (non-expired) statuses for the given contact IDs.
  Future<Map<String, UserStatus>> getAllActiveStatuses(List<String> contactIds) async {
    final result = <String, UserStatus>{};
    for (final id in contactIds) {
      final s = await getContactStatus(id);
      if (s != null) result[id] = s;
    }
    return result;
  }
}
