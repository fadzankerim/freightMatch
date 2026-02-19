import 'package:google_sign_in/google_sign_in.dart';

import '../models/user.dart';

class GoogleAuthSession {
  final AppUser user;
  final String? idToken;

  const GoogleAuthSession({
    required this.user,
    required this.idToken,
  });
}

class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;
  static const String _clientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');
  static const String _serverClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID', defaultValue: '');

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    await _googleSignIn.initialize(
      clientId: _clientId.isEmpty ? null : _clientId,
      serverClientId: _serverClientId.isEmpty ? null : _serverClientId,
    );
    _initialized = true;
  }

  Future<GoogleAuthSession> signIn() async {
    await _ensureInitialized();
    final account = await _googleSignIn.authenticate();
    final auth = account.authentication;

    final user = AppUser(
      id: account.id,
      name: account.displayName ?? 'Google Driver',
      email: account.email,
      phone: '',
      userType: UserType.hauler,
      avatarUrl: account.photoUrl,
      homeLocation: const UserLocation(
        city: 'Set home city',
        country: '',
        lat: 0,
        lng: 0,
      ),
      memberSince: DateTime.now(),
      verification: const UserVerification(
        email: true,
        phone: false,
        identity: false,
        insurance: false,
        driverLicense: false,
      ),
    );

    return GoogleAuthSession(user: user, idToken: auth.idToken);
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }
}
