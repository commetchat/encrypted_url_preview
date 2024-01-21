import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:encrypted_url_preview/encrypted_url_preview.dart';
import 'package:pointycastle/export.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

//final String serverPublicKeyB64 = ;

void main() {
  group('A group of tests', () {
    final urlGetter = EncryptedUrlPreview(
        proxyServerUrl: Uri.parse("https://proxy.commet.chat"),
        publicKeyPem: """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyvjz5ZFY6ry7i/QL1QK9
zPXKgUYEQOuNsuRN16GjXJuuFZgKSjENPAQQK++dCVfSx65+7yFPpozR1en0O740
6rcDk9trhvPZQqR4TchTUEd9/HDuSg/ZqX3PpGHBKZppU8qnuaYleCh/DQU52gwj
YM5B89fF88F6uPoutToiW5q/PyeYZ6z/u/fE69T/RXVKpCg8+IUtl8EhSaX5ScBo
BrIyz1V+up9z2tGOT9ok4d95pzQ8P/hEKlHMCaiXV8YOZhQbaEsm5osZHn8cPdhH
QEkaf0edvFSpJHYAV4JP7WOhDmsmRj930xuE5Ue/yg2NhZxUmnmTZjn25d35yZ1x
UQIDAQAB
-----END PUBLIC KEY-----""");

    test("Generating Key Pair", () async {
      var random = urlGetter.makeSecureRandom();
      var keys = urlGetter.generateRSAkeyPair(random);

      var privateKey = CryptoUtils.encodeRSAPrivateKeyToPem(keys.privateKey);

      var publicKey = CryptoUtils.encodeRSAPublicKeyToPem(keys.publicKey);

      print(privateKey);

      print(publicKey);

      print("Private Key B64:");
      print(base64Encode(utf8.encode(privateKey)));

      print("Public Key B64:");
      print(base64Encode(utf8.encode(publicKey)));
    });

    test('Get title test', () async {
      var uri = urlGetter.getProxyUrl(
          Uri.parse("https://www.youtube.com/watch?v=jNQXAC9IVRw"));
      print("Asking server to get preview of url:");
      print(uri);

      var response = (await http.get(uri)).body;
      print("Received response:");
      print(response);

      var html = parse(response);

      var metaTags = html.head!.children;

      var keyTag = metaTags
          .where(
            (element) =>
                element.attributes.containsValue("og:commet:content_key"),
          )
          .first;
      var keyContent = keyTag.attributes["content"] as String;

      var contentKey = urlGetter.decryptContentKeyB64(keyContent);

      var titleTag = metaTags
          .where(
            (element) => element.attributes.containsValue("og:title"),
          )
          .first;

      var imageTag = metaTags
          .where(
            (element) => element.attributes.containsValue("og:image"),
          )
          .first;

      var titleContent = titleTag.attributes["content"] as String;
      var title = urlGetter.decryptContentString(titleContent, contentKey);
      expect(title, equals("Me at the zoo"));

      var imageUrl = Uri.parse(imageTag.attributes["content"] as String);
      var imageEncryptedBytes = (await http.get(imageUrl)).bodyBytes;

      var imageBytes = urlGetter.decryptContentImage(imageEncryptedBytes);

      var hash = SHA256Digest().process(imageBytes);
      expect(base64Encode(hash),
          equals("jMBD9PpZ+2SSwYByyGIbu7Lhol3/a1CII6aiKf3ByLI="));
    });
  });
}
