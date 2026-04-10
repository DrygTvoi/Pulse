import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_status.dart';

class StatusService {
  static StatusService instance = StatusService._();
  StatusService._();

  /// Replace the singleton for testing.
  @visibleForTesting
  static void setInstanceForTesting(StatusService inst) => instance = inst;

  static const String _ownStatusKey = 'my_status';
  static String _contactKey(String contactId) => 'contact_status_$contactId';

  SharedPreferences? _prefs;
  Future<SharedPreferences> _getPrefs() async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<UserStatus?> getOwnStatus() async {
    final prefs = await _getPrefs();
    final json = prefs.getString(_ownStatusKey);
    final status = UserStatus.tryFromJsonString(json);
    if (status != null && status.isExpired) {
      await clearOwnStatus();
      return null;
    }
    return status;
  }

  Future<void> setOwnStatus(UserStatus status) async {
    final prefs = await _getPrefs();
    await prefs.setString(_ownStatusKey, status.toJsonString());
  }

  Future<void> clearOwnStatus() async {
    final prefs = await _getPrefs();
    await prefs.remove(_ownStatusKey);
  }

  Future<UserStatus?> getContactStatus(String contactId) async {
    final prefs = await _getPrefs();
    final json = prefs.getString(_contactKey(contactId));
    final status = UserStatus.tryFromJsonString(json);
    if (status != null && status.isExpired) {
      await _clearContactStatus(contactId);
      return null;
    }
    return status;
  }

  Future<void> saveContactStatus(String contactId, UserStatus status) async {
    final prefs = await _getPrefs();
    await prefs.setString(_contactKey(contactId), status.toJsonString());
  }

  Future<void> _clearContactStatus(String contactId) async {
    final prefs = await _getPrefs();
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
