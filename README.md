Provides a Utility to construct and handle encryption for Commet's encrypted url previews.

## Getting started

This package is intended to be used in conjunction with a matrix client. 

## Usage

```dart
    final privatePreviewGetter = EncryptedUrlPreview(
        proxyServerUrl: Uri.parse("https://proxy.commet.chat"),
        // Server public key
        publicKeyPem: """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsHm6BWsALNS8QRGX19w7
60wzxtWOFDJKU2ygrUksDZBNjfErUSEnlyfthGlkDbXLj5jCw350iCPEBL02fdAM
i1vt6Q9o8l0KlUW+5ZkPdxPqS2P+fzdD0XZyTTSHKXOsxxW6BoTyetkjXjyQcUke
81QCBZHbrBrDddzjZanxKtThDTs452lOhdSG/od0y3/8I7YMZ8vRroPTp0DXSf7Y
VMVsGrhN5j+UnsZ9MFTRlsc/n/4MuP3TomyqxFc3XLJaqgCLjnuXbuIZ2bVAbODv
Ba0WQx4DI7vg9aQc7l1KHMJsZlkZ7yiKolxYKURdHTF1QgtVO0N/xwA9SPIHkGPJ
BwIDAQAB
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


