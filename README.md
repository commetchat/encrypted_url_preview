Provides a Utility to construct and handle encryption for Commet's encrypted url previews.

## Getting started

This package is intended to be used in conjunction with a matrix client. 

## Usage

```dart
    final privatePreviewGetter = EncryptedUrlPreview(
        proxyServerUrl: Uri.parse("https://proxy.commet.chat"),
        // Server public key
        publicKeyPem: """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyvjz5ZFY6ry7i/QL1QK9
zPXKgUYEQOuNsuRN16GjXJuuFZgKSjENPAQQK++dCVfSx65+7yFPpozR1en0O740
6rcDk9trhvPZQqR4TchTUEd9/HDuSg/ZqX3PpGHBKZppU8qnuaYleCh/DQU52gwj
YM5B89fF88F6uPoutToiW5q/PyeYZ6z/u/fE69T/RXVKpCg8+IUtl8EhSaX5ScBo
BrIyz1V+up9z2tGOT9ok4d95pzQ8P/hEKlHMCaiXV8YOZhQbaEsm5osZHn8cPdhH
QEkaf0edvFSpJHYAV4JP7WOhDmsmRj930xuE5Ue/yg2NhZxUmnmTZjn25d35yZ1x
UQIDAQAB
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


