# Certum Code Signing in the Cloud container for Linux

This container has everything you need to use [Certum Code Signing in the Cloud](https://shop.certum.eu/code-signing.html) with Linux in a CI/CD system.

Container size: 925MB, it is quite large because the signing app is a graphical application and requires a lot of desktop services to be installed to function.

*This project is not affiliated with or endorsed by Certum*

**There are no pre-built images on any registry for this project. Due to the security sensitive nature of this tool, please built it locally for your own use.**

## How it works

We start the [Certum Simply Sign Desktop](https://support.certum.eu/en/software/procertum-smartsign/) application in an Xvnc session to log in to the signature service. We expose a p11-kit socket outside of the container to then use the cloud session to do automatic signatures.

Note that on each restart of the container, a user that has the SimplySign application installed on a mobile phone must authenticate before the container can be used for signing.

The application can be downloaded here:

 * Android [Play store link](https://play.google.com/store/apps/details?id=com.assecods.certum.simplysign)
 * Apple [App store link](https://apps.apple.com/pl/app/certum-simplysign/id1244415465)

Once logged in, the session will remain active, and the token can be used in automation. There is no need to keep the VNC session active once you have logged in.

## How to use it

Build the container using either podman or docker. When using docker simply substitute `podman` for `docker` in the following examples.

`podman build . -t certum`

And run the container. **Change the vnc password to something different from `password`**

```
mkdir -p /run/user/1000/p11-kit
podman run -it --rm -eVNCPASSWORD=password -p 5999:5900 -v /run/user/1000/p11-kit:/run/p11-kit:z certum
```

Connect to the VNC server (in this case localhost:5999) and log in using your Certum SimplySign credentials with the SimplySign application. Once connected via VNC it is very clear where to put the OTP code from the SimplySign application.

**NOTE** You must press the "close" button once logged in. The Token will not function until the dialog is closed!

After that, using the p11-kit client library we can use the token like normal.

#### Fedora
```
export P11_KIT_SERVER_ADDRESS="unix:path=/run/user/1000/p11-kit/p11kit.sock"
osslsigncode sign -pkcs11module /usr/lib64/pkcs11/p11-kit-client.so -pkcs11cert 'pkcs11:model=SimplySign%20C' -key 'pkcs11:model=SimplySign%20C'  -t http://time.certum.pl/ -n "PT TEST" -i "https://prehensile-tales.com" -in hello.exe -out hello_signed.exe
Engine "pkcs11" set.
Connecting to http://time.certum.pl/
Succeeded
```

#### Ubuntu/Debian
```
export P11_KIT_SERVER_ADDRESS="unix:path=/run/user/1000/p11-kit/p11kit.sock"
osslsigncode sign -pkcs11module /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-client.so -pkcs11cert 'pkcs11:model=SimplySign%20C' -key 'pkcs11:model=SimplySign%20C'  -t http://time.certum.pl/ -n "PT TEST" -i "https://prehensile-tales.com" -in hello.exe -out hello_signed.exe
Engine "pkcs11" set.
Connecting to http://time.certum.pl/
Succeeded
```

**Note:** In this example I have chosen `/run/user/1000/p11-kit` to mount the `p11kit.sock` onto the host system. You can select your own location, and this location may not work if your uid is not 1000, or your distribution does not use `/run/user`.


## Security

Using the cloud signing module like this should not be any less secure than the "normal" way, but be aware that exposing the VNC port to the outside world may be insecure. I recommend exposing the VNC port only to localhost and using an SSH tunnel to actually connect to login to the VNC server.

## Troubleshooting

### Failed to enumerate slots

Either the container is not running, or you forgot to set `P11_KIT_SERVER_ADDRESS` to the same value used when starting the container. The `P11_KIT_SERVER_ADDRESS` environment variable needs to point to the volume you set and `p11kit.sock`.

### The osslsigncode (or other pkcs11 client) process hangs and then exits with Failed to enumerate slots
You are probably not logged into the Certum cloud. Try connecting to the VNC port and logging in.

### The osslsigncode (or other pkcs11 client) process hangs and then exits with Failed to enumerate slots and I have definitely logged in
You probably forgot to press the "close" button on the dialog after the login.

### p11-kit-client.so: cannot open shared object file: No such file or directory
You do not have the p11-kit client libraries installed.

* Fedora `dnf install p11-kit-server`
* Ubuntu/Debian `apt-get install p11-kit-modules`

If you are not on Fedora or Ubuntu/Debian please refer to your distribution's documentation on how to install the p11-kit client libraries and where they are installed.

### Something else is wrong
First use pkcs11-tool to see if the connection is working at all. Make sure that `P11_KIT_SERVER_ADDRESS` is set correctly and then run

#### Fedora
`pkcs11-tool --module /usr/lib64/pkcs11/p11-kit-client.so -L`

#### Ubuntu
`pkcs11-tool --module /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-client.so -L`

You should see something like

```
Available slots:
Slot 0 (0x11): 0000000000000000
  token label        : Code Signing
  token manufacturer : CERTUM
  token model        : SimplySign C
  token flags        : token initialized
  hardware version   : 0.0
  firmware version   : 0.0
  serial num         : 0000000000000000
  pin min/max        : 0/0
  uri                : pkcs11:model=SimplySign%20C;manufacturer=CERTUM;serial=0000000000000000;token=Code%20Signing
```

If this does work then you might need to upgrade osslsigncode. If this also does not work, please file a bug report against this repository.

## References

* [osslsigncode](https://github.com/mtrojnar/osslsigncode)
* [p11-kit](https://p11-glue.github.io/p11-glue/p11-kit.html)
* [Wikipedia article on PKCS#11](https://en.wikipedia.org/wiki/PKCS_11)
* [Certum shop](https://shop.certum.eu/code-signing.html)