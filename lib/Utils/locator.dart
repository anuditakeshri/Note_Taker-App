import 'package:note_taking_app/Utils/encryption.dart';
import 'package:note_taking_app/main.dart';

void setUpLocator() {
  getIt.registerLazySingleton(() => EncryptionService());
}
