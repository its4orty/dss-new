import 'package:shared_preferences/shared_preferences.dart';

/// Simple persistence for the current tenant's Firestore document ID.
/// Used by screens to know whether a tenant is registered and to
/// scope enquiry queries to that tenant.
class TenantSession {
  static const _keyTenantId = 'current_tenant_id';

  TenantSession._();

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns the stored tenant document ID, or `null` if not registered.
  static Future<String?> getTenantId() async {
    final prefs = await _instance;
    return prefs.getString(_keyTenantId);
  }

  /// Persists the tenant document ID so it survives app restarts.
  static Future<void> setTenantId(String id) async {
    final prefs = await _instance;
    await prefs.setString(_keyTenantId, id);
  }

  /// Clears the stored tenant ID (e.g. on logout / re-registration).
  static Future<void> clearTenantId() async {
    final prefs = await _instance;
    await prefs.remove(_keyTenantId);
  }

  /// Convenience: true when a tenant has been registered.
  static Future<bool> isRegistered() async {
    final id = await getTenantId();
    return id != null && id.isNotEmpty;
  }
}
