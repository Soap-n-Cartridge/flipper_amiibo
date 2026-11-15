# Amiibo Emulator

This app can back up Amiibos you already own.

You do not need a downloaded Amiibo database. You do not need a key file for that.

1. Scan a real Amiibo.
2. It stays under **Scanned Amiibos**. **Fav** keeps a copy in **Favorites**.
3. Press **Emulate** and hold the Flipper on the game reader. The game sees that same Amiibo.

The app cannot include Nintendo's key file. You add that file yourself.

**New UID** and **Auto UID** cannot change the ID unless that key file is on the SD card. **Emulate** of a scanned Amiibo still works without it. It uses the ID from your Amiibo.

## The key file

If you have the key file, put it here:

`apps_data/flipper_amiibo/key_retail.bin`

If `amiibo_keys.bin` is already in the `nfc` folder, you can leave it there. The app will find it.

Open **Settings** to see if the key is ready. That screen says **Keys: Loaded** or **Keys: Missing**. No other screen shows that line.

Without that file, **New UID** and **Auto UID** leave the ID unchanged.

## Amiibo files

A downloaded database is optional. If you have `.bin` or `.nfc` files, put them here:

`apps_data/flipper_amiibo/db/`

A `.bin` file should be 540 bytes. You can put files in folders inside `db`.

- A folder named `ZE` always makes a new ID. That needs the key file.
- A folder named `SSB` keeps the ID saved in the file.

## Main menu

The main menu is a row of pictures. Left and Right move. OK opens the picture. The row wraps.

1. **Amiibo Database**
2. **Favorites**
3. **Scan Amiibos**
4. **Settings**
5. **Help**

From a section, Left and Right jump to the next section. Back returns to the picture row.

## Amiibo Database

Folders are listed first, then files, A to Z. Up and Down on a tag stay in that folder.

Open a tag. The buttons are **Fav**, **Emulate**, and **New UID**.

- **Emulate** plays the Amiibo. Hold the Flipper on the game reader.
- **Fav** saves a copy in Favorites and stays on this tag. A short message says **Added to Favorites**.
- **New UID** makes a new ID in memory. It does not change the database file. This needs the key file.

## Favorites

Open a saved tag. The buttons are **New UID**, **Emulate**, and **Del**.

- **New UID** asks first. Press Left again to change the ID. Back cancels. The new ID is saved on that favorite. It is not copied to Scanned Amiibos. This needs the key file.
- **Del** asks before it removes the tag. Press **Delete** to remove it. **Cancel** or Back keeps it.

## Scan Amiibos

Hold a real Amiibo on the back of the Flipper. The name is already on it.

The scan stays under **Scanned Amiibos**. **Fav** keeps a copy in Favorites and leaves the scan where it is. The ID stays the same, so **Emulate** is a backup of that Amiibo.

If a scan does not work, press **OK** to try again. Back returns to the Scan menu.

## Settings

- **Auto UID**, when on, makes a new ID each time you emulate a database file. **Next ID** makes another one on that screen. Both need the key file. A scan or a favorite keeps its own ID.
- **Keys** says whether the key file is ready.
- **Clean added tags** removes Favorites and scans. Hold Up for 2 seconds. Database files stay.

## Install by hand

Build with `ufbt`, then copy `dist/flipper_amiibo.fap` to `SD Card/apps/NFC/`.
