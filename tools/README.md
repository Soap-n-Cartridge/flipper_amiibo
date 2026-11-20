# Tools

## `fix-names-for-flipper.ps1` / `fix-names-for-flipper.py`

Official Flipper Zero firmware (FatFS, OEM code page 850) drops a whole long file name if any character cannot convert to OEM. The Flipper then shows the 8.3 short name (`LINK'S~1`, `YOSHI'~1`, `GAKUTO~1`).

These scripts walk a folder tree and rename entries to ASCII-safe long names (curly `’` → `'`, `ō` → `o`, and so on). Dry-run by default.

```powershell
.\fix-names-for-flipper.ps1 -Path "C:\Users\dmolt\Downloads\Amiibo Full Set"
.\fix-names-for-flipper.ps1 -Path "E:\apps_data\flipper_amiibo\db" -Apply
```

```bash
python3 fix-names-for-flipper.py "/path/to/Amiibo Full Set"
python3 fix-names-for-flipper.py "/path/to/db" --apply
```

Run on your PC library or on the SD card while it is mounted in Windows, then use the renamed tree on the Flipper.
