# Amiibo Emulator

Flipper Zero app that emulates NTAG215 dumps and can present a new tag UID on each scan.

The original `.bin` keeps its UID until you press Save. A new UID is signed in memory, the same way a Joysfusion / Pixl.js unit does it. Nintendo's key file is not included.

## Install

Build with the Flipper SDK:

```
ufbt
ufbt launch
```

Copy `dist/flipper_amiibo.fap` to `SD Card/apps/NFC/` if you are installing it by hand.

## SD card

```
apps_data/flipper_amiibo/key_retail.bin
apps_data/flipper_amiibo/db/
```

`key_retail.bin` is 160 bytes: the 80-byte data key (`unfixed-info.bin`) followed by the 80-byte tag key (`locked-secret.bin`). The app also checks `/ext/nfc/assets/amiibo_keys.bin` and `/ext/nfc/amiibo_keys.bin`.

Put `.bin` dumps (540 bytes) or Flipper `.nfc` files under `db/`, in series folders if you want. A folder named `ZE` always uses a new UID. A folder named `SSB` always keeps the UID stored in the file.

All NFC files must be added the the DB folder before use. You can find these files online, in various places. Some sources have thousands of Amiibo files available, for use in many different games.

## On device

- Browse dumps, then Emulate.
- Auto UID, when on, signs a new 7-byte UID before the tag is presented. Press Next ID on the emulate screen for another serial without leaving the screen.
- New UID does the same thing once, without leaving the detail screen.
- Save writes the current UID and any pages the console wrote back to the same file.

Games that remember the tag serial treat each new UID as another figure. Games that remember the character still apply that character's own limit.
