import "dart:convert";
import "dart:typed_data";

import "package:basic_utils/basic_utils.dart";
import "package:pointycastle/export.dart";
import 'package:http/http.dart' as http;
import "package:pointycastle/pointycastle.dart";
import 'package:pointycastle/src/platform_check/platform_check.dart';

class EncryptedUrlPreview {
  Uri proxyServerUrl;
  String basePath;
  late RSAPublicKey serverPublicKey;
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> userKeys;

  EncryptedUrlPreview(
      {required this.proxyServerUrl,
      this.basePath = "/url_preview/encrypted",
      required publicKeyPem}) {
    serverPublicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPem);
    userKeys = generateRSAkeyPair(makeSecureRandom());
  }

  Uri getProxyUrl(Uri uri) {
    String clientPublicKey = encodeClientPublicKey();
    String encryptedUrl = encryptAndEncodeRequestUrl(uri);

    var proxyUrl = proxyServerUrl.replace(
        path: "$basePath/$clientPublicKey/$encryptedUrl");
    return proxyUrl;
  }

  String decryptContentString(String encodedContent, Uint8List key) {
    return utf8.decode(decryptContent(encodedContent, key));
  }

  Uint8List decryptContent(String encodedContent, Uint8List key) {
    var bytes = base64Decode(encodedContent);
    var iv = bytes.sublist(0, 16);
    var cipherBytes = bytes.sublist(16);

    var decryptor = GCMBlockCipher(AESEngine())
      ..init(false, ParametersWithIV(KeyParameter(key), iv));

    var result = decryptor.process(cipherBytes);

    return result;
  }

  Uint8List decryptContentKey(String encryptedKey) {
    var bytes = base64Decode(encryptedKey);
    var decryptor = OAEPEncoding.withSHA256(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(userKeys.privateKey));

    var decrypted = decryptor.process(bytes);

    return decrypted;
  }

  String encodeClientPublicKey() {
    var userPublicKey = CryptoUtils.encodeRSAPublicKeyToPem(userKeys.publicKey);
    var userKeyB64 = base64Encode(utf8.encode(userPublicKey));
    var userKey = Uri.encodeComponent(userKeyB64);
    return userKey;
  }

  String encryptAndEncodeRequestUrl(Uri uri) {
    var encryptor = OAEPEncoding.withSHA256(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(serverPublicKey));

    var urlBytes = utf8.encode(uri.toString());
    var data = Uint8List.fromList(urlBytes);
    var encrypted = encryptor.process(data);
    var b64 = base64Encode(encrypted);
    var requestUrl = Uri.encodeComponent(b64);

    return requestUrl;
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      SecureRandom secureRandom,
      {int bitLength = 2048}) {
    final keyGen = RSAKeyGenerator();

    keyGen.init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom));

    final pair = keyGen.generateKeyPair();

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  SecureRandom makeSecureRandom() {
    final secureRandom = SecureRandom('Fortuna')
      ..seed(
          KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
    return secureRandom;
  }
}
