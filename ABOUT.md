# Encrypted URL Preview

The intent for this package is to provide a private method to fetch URL previews for messages in an End to End Encrypted chat.

### This is achieved by ensuring no one party has access to enough information to tie requests back to users:

Your homeserver will know who is requesting a preview, but not what they are requesting a preview of, nor the preview content. 
 
The preview proxy server will know what site a preview is being requested of, but not who is requesting it.

For this to be effective, the proxy server and the home server should be run by seperate entities. 


## How does it work?

The lifecycle of an encrypted url preview is as follows:

#### Client -> Homeserver
`Client` wants to get a preview of `https://example.com`, and so encrypts `https://example.com` using `ProxyServer`'s public key (referred to as `ENCRYPTED_URL`). 

`Client` generates their own public/private key pair

`Client` creates a url (referred to as `PROXY_URL`) like so: `https://proxy.commet.chat/url_preview/encrypted/metadata/$CLIENT_PUBLIC_KEY/$ENCRYPTED_URL` and requests their homeserver to fetch a preview of this new url.

### Homeserver <-> Proxy

`Homeserver` makes an http request to `PROXY_URL`

`ProxyServer` decrypts the `ENCRYPTED_URL` content of `PROXY_URL` using `SERVER_PRIVATE_KEY`, to get the original url requested (`https://example.com`), and gets the page.

`ProxyServer` parses page html for metadata tags, and encrypts the tag content using a newly generated encryption key (referred to as `CONTENT_KEY`)

`ProxyServer` encrypts `CONTENT_KEY` using `CLIENT_PUBLIC_KEY` (now referred to as `ENCRYPTED_CONTENT_KEY`)

#### Image Handling
If the metadata contains an image, `ProxyServer` will encrypt the image URL using `SERVER_PRIVATE_KEY` and adjust it to point to itself like so: `https://proxy.commet.chat/url_preview/encrypted/image/$CLIENT_PUBLIC_KEY/$ENCRYPTED_IMAGE_URL`, reusing the `CLIENT_PUBLIC_KEY` from the current request. 

The `/encrypted/image` endpoint will download the image and encrypt it with a new content key (`IMAGE_CONTENT_KEY`), which is then encrypted using `CLIENT_PUBLIC_KEY`.

#### HTML Response

`ProxyServer` returns a new html page with metadata tags containing the encrypted tag content, and adds a new tag including `ENCRYPTED_CONTENT_KEY`

### Homeserver -> Client

`Homeserver` parses the html returned from proxy server the same way it would a regular page, and sends the resulting metadata back to `Client`. if the response contains an `ENCRYPTED_IMAGE_URL`, `Homeserver` will fetch the encrypted image here.

`Client` decrypts `ENCRYPTED_CONTENT_KEY` using `CLIENT_PRIVATE_KEY`

`Client` decrypts metadata using `CONTENT_KEY`

if there is an image, `Client` will download the image from `Homeserver` and decrypt the image

`Client` enjoys looking at the url preview :)

### Privacy Achieved!

As you can see, the proxy server is never in direct communcation with the client so cannot know who is requesting the url, And the homeserver never has access to the keys required to know the origin or content of the URL preview