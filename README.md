Provides a Utility to construct and handle encryption for Commet's encrypted url previews.

## Getting started

This package is intended to be used in conjunction with a matrix client. 

## Usage

```dart
    final urlGetter = EncryptedUrlPreview(
        serverUrl: Uri.parse("https://proxy.commet.chat"),
        // Server public key
        publicKeyPem: """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmfaEN1UrIYYyBI8sj7DBnugOZQPM1DvHj88cAooH/KYw4spB/iN7WcETneDIXRoARYkBb03gsOrFvgIZImCqn2Fc2rrYvY+TYN9bGFefhKyKN7uCj+C15vB+xzEbDeV0a2POkz5hfi4S31qM5YHLnYDF+dUfiiL1amQ6BOnHOinDuaz/uXf6qgRz9eQSrsx6A+B06Ol9m1j6n5JrgNU0dUanXK/CMk45ybs55MB/wuu8v/UYdFd6aTQA3ctdJmyIlDbsR8jZeJg5NwSko8YKEmm6lT1/gY+7jxcZG/3pwDuVCmyZcorkzry9/s90o3wp0zO0NKxMiXPflPBxKRQgpwIDAQAB
-----END PUBLIC KEY-----""");


    var privateUrl = urlGetter.getPrivatePreviewUrl(Uri.parse("https://youtu.be/D6SeNBm_US8"));

    var response = await matrixClient.request(
        matrix.RequestType.GET, "/media/v3/preview_url",
        query: {"url": privateUrl.toString()});

    var encryptedKey = response['og:commet:content_key'] as String;
    var key = urlGetter!.decryptContentKey(encryptedKey);

    var title = response['og:title'] as String?;
    title = urlGetter!.decryptContentString(title!, key);
```

## How does it work?
See [ABOUT.md](ABOUT.md)


