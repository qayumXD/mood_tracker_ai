import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false; // Web doesn't support biometric
    try {
      final isDeviceSupported = await _auth.canCheckBiometrics;
      return isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    if (kIsWeb) return true; // Web skips biometric
    try {
      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to access your mood tracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      return isAuthenticated;
    } catch (_) {
      return true; // Fail-open: allow access if auth fails
    }
  }
}
