import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuth {
  static final _auth = LocalAuthentication();

  static Future<bool> _canAuthenticate() async =>
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    try {
      if (!await _canAuthenticate()) return false;

      final List<BiometricType> biometrics =
          await _auth.getAvailableBiometrics();

      print(biometrics);

      return await _auth.authenticate(
        authMessages: [
          AndroidAuthMessages(
              signInTitle: "تسجيل الدخول", cancelButton: "الغاء"),
          IOSAuthMessages(cancelButton: "الغاء")
        ],
        localizedReason: 'تسجيل الدخول',
        options: const AuthenticationOptions(
            useErrorDialogs: true, stickyAuth: true, biometricOnly: true),
      );
    } catch (error) {
      print(error);
      return false;
    }
  }
}
