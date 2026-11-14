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

Put `.bin` dumps (540 bytes) or Flipper `.nfc` files under `db/`, in series folders if you want. A folder named `ZE` always uses a new UID. A folder named `SSB` always keeps the UID stored in the file. NFC files have to be in the `db` folder before the app can use them.

## How to use this

This app needs a key file and tag files. It does not come with them. Use Google to search for Amiibo databases. Many contain the key files you will need as well.

### The key

The key is a small file that lets the game accept the tag.

1. Find the key file in an Amiibo database.
2. The file has two halves, stuck together in this order:
   - First half: the data key. Its usual name is `unfixed-info.bin`.
   - Second half: the tag key. Its usual name is `locked-secret.bin`.
3. Save that whole file as `key_retail.bin`.
4. Put it on the Flipper SD card in this folder: `apps_data/flipper_amiibo/`.
5. If you already have `amiibo_keys.bin` in the `nfc/assets` folder or the `nfc` folder, you can leave it there. The app will find it.

Open the app and look at the Keys line. It should say "Keys: loaded".

### The tags

A tag file is one figure.

1. Use a `.bin` file or a `.nfc` file from an Amiibo database.
2. A `.bin` file should be 540 bytes long.
3. Copy the files into this folder on the SD card: `apps_data/flipper_amiibo/db/`. The app uses a tag only after it is in that folder.
4. You can make folders inside `db`.
   - A folder named `ZE` always makes a new ID.
   - A folder named `SSB` keeps the ID that is already in the file.
5. On the Flipper, open Amiibo Emulator.
6. Choose Browse dumps and pick a file.
7. Choose Emulate, then hold the Flipper to the game reader.
8. Choose Help on the main menu to read a short version of these steps on the Flipper.

## On device

- Browse dumps, then Emulate.
- Auto UID, when on, signs a new 7-byte UID before the tag is presented. Press Next ID on the emulate screen for another serial without leaving the screen.
- New UID does the same thing once, without leaving the detail screen.
- Save writes the current UID and any pages the console wrote back to the same file.

Games that remember the tag serial treat each new UID as another figure. Games that remember the character still apply that character's own limit.
