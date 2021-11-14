# cryptsetup-usbkey
A set of scripts and config files to have a cryptsetup encryption passphrase in a file on a usb stick

## How to use
Create a (random) key and store it on your usb stick, p.ex.

```bash
 dd if=/dev/urandom of=<keyfile> bs=4096 count=1
```

The keyfile must reside on the root directory of your USB (or MMC) stick and must be named `<crypt target>.luksKey`.

Also, the label of your USB stick (you'll find it in `/dev/disk/by-label`) needs to be defined in `/etc/cryptsetup-usbkey/conf`.

Next, add the newly generated key to the crypto container:

```bash
cryptsetup luksAddKey <encrypted partition> <keyfile>
```

Next, you need to update /etc/crypttab and add following option:

```bash
keyscript=/etc/cryptsetup-usbkey/usbkey-keyscript.sh
```

Last, don't forget to re-create a new initrd.

## Not to forget

I created this script on a single afternoon after reading some content throughout the net and studying initrd behaviour on ubuntu 20.04. This script can still contain many errors