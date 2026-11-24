import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// O emulador usa um projeto fictício. A nuvem usa as opções do app Android.
Future<void> iniciarFirebase() async {
  const emulador = bool.fromEnvironment('FIREBASE_EMULADOR');
  if (emulador) {
    const host = String.fromEnvironment(
      'FIREBASE_HOST',
      defaultValue: '10.0.2.2',
    );
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'sonoleve-emulador-chave-publica',
        appId: '1:1234567890:android:0123456789abcdef',
        messagingSenderId: '1234567890',
        projectId: 'demo-sonoleve',
      ),
    );
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    return;
  }

  const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  const appId = String.fromEnvironment('FIREBASE_APP_ID');
  const senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  if ([apiKey, appId, senderId, projectId].any((valor) => valor.isEmpty)) {
    throw StateError(
      'Preencha firebase.local.json ou use FIREBASE_EMULADOR=true.',
    );
  }
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: senderId,
      projectId: projectId,
    ),
  );
}
