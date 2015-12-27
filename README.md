# uol-qrcode-auth-thesis
UoL Thesis: QR codes for authentication

Final version of dissertation document was submitted on 2015 December 27.

###Components

- [qr-auth-chrome](https://github.com/chupakabr/uol-qrcode-auth-thesis/qr-auth-chrome), **Desktop component** for Chrome web browser to request authentication from the vault, generates QR code to be scanned by *Mobile component*
- [qr-auth-srv](https://github.com/chupakabr/uol-qrcode-auth-thesis/qr-auth-srv), **Server component** as a lightweight replacement for file sharing service (ex. Dropbox) implementing file exchange between *Mobile component* and *Desktop component*
- [QrAuthVault](https://github.com/chupakabr/uol-qrcode-auth-thesis/QrAuthVault), **Mobile component** acting as credentials vault, access device's camera to scan QR code generated by *Desktop component*

###Links

IT artefacts download page: [http://chupakabr.ru/extra-test-qr-api/download/](http://chupakabr.ru/extra-test-qr-api/download/), also available via secure connection (HTTPS) on [https://chupakabr.ru/extra-test-qr-api/download/](https://chupakabr.ru/extra-test-qr-api/download/)