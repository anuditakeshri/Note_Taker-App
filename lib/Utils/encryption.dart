import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pointycastle/asymmetric/api.dart';

class EncryptionService {
  Encrypter? encrypter;
  Future initialise() async {
    // final publKey = await <RSAPublicKey>(publicKey);
    // final privKey = await <RSAPrivateKey>(priKey);
    var pub = await rootBundle.loadString('assets/public.pem');
    var pri = await rootBundle.loadString('assets/private.pem');
    final parser = RSAKeyParser();
    final RSAPublicKey publKey = parser.parse(pub) as RSAPublicKey;
    final RSAPrivateKey privKey = parser.parse(pri) as RSAPrivateKey;
    encrypter = Encrypter(RSA(publicKey: publKey, privateKey: privKey));
  }

  List<String> encrypt(String text) {
    List<String> encryptedText = <String>[];
    int maxLength = 50;
    if (text.length > maxLength) {
      int numberOfTimes = text.length ~/ maxLength;

      int startIndex = 0;
      for (int i = 0; i < numberOfTimes; i++) {
        encryptedText.add(encrypter!
            .encrypt(text.substring(
                startIndex, min(startIndex + maxLength, text.length)))
            .base64);
        startIndex = startIndex + maxLength + 1;
      }
      if (startIndex < text.length) {
        encryptedText.add(encrypter!
            .encrypt(text.substring(
                startIndex, min(startIndex + maxLength, text.length)))
            .base64);
      }
      return encryptedText;
    } else {
      return [encrypter!.encrypt(text).base64];
    }
  }

  String decrypt(List<dynamic> encryptedList) {
    String decryptedText = '';
    for (var value in encryptedList) {
      decryptedText += encrypter!.decrypt64(value);
    }
    return decryptedText;
  }
}
