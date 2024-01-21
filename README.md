Provides a Utility to construct and handle encryption for Commet's encrypted url previews.

## Getting started

This package is intended to be used in conjunction with a matrix client. 

## Usage

```dart
    final privatePreviewGetter = EncryptedUrlPreview(
        proxyServerUrl: Uri.parse("https://proxy.commet.chat"),
        // Server public key
        publicKeyPem: """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmfaEN1UrIYYyBI8sj7DBnugOZQPM1DvHj88cAooH/KYw4spB/iN7WcETneDIXRoARYkBb03gsOrFvgIZImCqn2Fc2rrYvY+TYN9bGFefhKyKN7uCj+C15vB+xzEbDeV0a2POkz5hfi4S31qM5YHLnYDF+dUfiiL1amQ6BOnHOinDuaz/uXf6qgRz9eQSrsx6A+B06Ol9m1j6n5JrgNU0dUanXK/CMk45ybs55MB/wuu8v/UYdFd6aTQA3ctdJmyIlDbsR8jZeJg5NwSko8YKEmm6lT1/gY+7jxcZG/3pwDuVCmyZcorkzry9/s90o3wp0zO0NKxMiXPflPBxKRQgpwIDAQAB
-----END PUBLIC KEY-----""");

    var proxyUrl = privatePreviewGetter!.getProxyUrl(url);

    var response = await client.request(
        matrix.RequestType.GET, "/media/v3/preview_url",
        query: {"url": proxyUrl.toString()});

    var encryptedKey = response['og:commet:content_key'] as String;
    var key = privatePreviewGetter!.decryptContentKeyB64(encryptedKey);

    var title = response['og:title'] as String?;
    var imageUrl = response['og:image'] as String?;

    ImageProvider? image;

    if (imageUrl != null) {
      var mxcUri = Uri.parse(imageUrl);
      if (mxcUri.scheme == "mxc") {
        var response =
            await client.httpClient.get(mxcUri.getDownloadLink(client));

        var bytes = response.bodyBytes;
        var decrypted = privatePreviewGetter!.decryptContentImage(bytes);

        image = Image.memory(decrypted).image;
      }
    }

    if (title != null)
      title = privatePreviewGetter!.decryptContentString(title, key);
```

## How does it work?
See [ABOUT.md](ABOUT.md)


