import 'dart:convert';

import 'package:encrypted_url_preview/encrypted_url_preview.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('A group of tests', () {
    final urlGetter = EncryptedUrlPreview(
        proxyServerUrl: Uri.parse("http://10.0.10.17:8787"),
        publicKeyPem: """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmfaEN1UrIYYyBI8sj7DBnugOZQPM1DvHj88cAooH/KYw4spB/iN7WcETneDIXRoARYkBb03gsOrFvgIZImCqn2Fc2rrYvY+TYN9bGFefhKyKN7uCj+C15vB+xzEbDeV0a2POkz5hfi4S31qM5YHLnYDF+dUfiiL1amQ6BOnHOinDuaz/uXf6qgRz9eQSrsx6A+B06Ol9m1j6n5JrgNU0dUanXK/CMk45ybs55MB/wuu8v/UYdFd6aTQA3ctdJmyIlDbsR8jZeJg5NwSko8YKEmm6lT1/gY+7jxcZG/3pwDuVCmyZcorkzry9/s90o3wp0zO0NKxMiXPflPBxKRQgpwIDAQAB
-----END PUBLIC KEY-----""");

    test('First Test', () async {
      var uri = urlGetter.getProxyUrl(Uri.parse(
          "https://www.youtube.com/watch?v=eSW2LVbPThw&list=RDjgW7w-SCnAs&index=12"));

      print("Asking server to get preview of url:");
      print(uri);

      var response = jsonDecode((await http.get(uri)).body);
      print(response);

      var key = response['commet:content_key'];
      var contentKey = urlGetter.decryptContentKey(key);

      print(
          "Unencrypted title: ${urlGetter.decryptContentString(response["og:title"], contentKey)}");
      print(
          "Unencrypted description: ${urlGetter.decryptContentString(response["og:description"], contentKey)}");
    });
  });
}
