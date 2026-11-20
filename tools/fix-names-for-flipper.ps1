<#
.SYNOPSIS
  Rename folders/files so Flipper Zero (official FW FatFS, CP850) can keep long names.

.DESCRIPTION
  Official Flipper firmware returns FatFS fname after Unicode->OEM (CP850) conversion.
  If ANY character in a long name fails that conversion (curly apostrophe U+2019,
  macron o U+014D, etc.), FatFS discards the whole LFN and the Flipper shows the
  8.3 short name (LINK'S~1, YOSHI'~1, GAKUTO~1).

  This script walks a tree (your Amiibo Full Set copy, or the SD card db folder),
  depth-first, and renames entries to ASCII-safe LFNs:
    - curly/smart quotes -> straight ' or "
    - en/em dashes -> -
    - accented letters -> ASCII base (Sogetsu, Pokken) via .NET FormKD
    - other non-ASCII -> _

  Dry-run by default. Pass -Apply to rename. Pass -WhatIf is not used; use default
  dry-run instead.

.PARAMETER Path
  Root folder to walk (e.g. "C:\Users\...\Downloads\Amiibo Full Set"
  or "E:\apps_data\flipper_amiibo\db").

.PARAMETER Apply
  Actually rename. Without this flag, only prints planned renames.

.EXAMPLE
  .\fix-names-for-flipper.ps1 -Path "C:\Users\dmolt\Downloads\Amiibo Full Set"
  .\fix-names-for-flipper.ps1 -Path "E:\apps_data\flipper_amiibo\db" -Apply
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Path,

    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FlipperSafeName {
    param([Parameter(Mandatory = $true)][string]$Name)

    $map = @{
        [char]0x2018 = "'"
        [char]0x2019 = "'"
        [char]0x201A = "'"
        [char]0x201B = "'"
        [char]0x2032 = "'"
        [char]0x02BC = "'"
        [char]0x201C = '"'
        [char]0x201D = '"'
        [char]0x2013 = '-'
        [char]0x2014 = '-'
        [char]0x2212 = '-'
        [char]0x00A0 = ' '
        [char]0x202F = ' '
        [char]0x2009 = ' '
    }

    $sb = New-Object System.Text.StringBuilder
    foreach ($ch in $Name.ToCharArray()) {
        if ($map.ContainsKey($ch)) {
            [void]$sb.Append([string]$map[$ch])
        } else {
            [void]$sb.Append($ch)
        }
    }
    $s = $sb.ToString()

    # Decompose accents (o + combining macron, e + acute, ...) then drop marks.
    $s = $s.Normalize([Text.NormalizationForm]::FormKD)
    $sb2 = New-Object System.Text.StringBuilder
    foreach ($ch in $s.ToCharArray()) {
        $cat = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($ch)
        if ($cat -eq [Globalization.UnicodeCategory]::NonSpacingMark -or
            $cat -eq [Globalization.UnicodeCategory]::SpacingCombiningMark -or
            $cat -eq [Globalization.UnicodeCategory]::EnclosingMark) {
            continue
        }
        $code = [int][char]$ch
        if ($code -ge 0x20 -and $code -le 0x7E) {
            [void]$sb2.Append($ch)
        } else {
            [void]$sb2.Append('_')
        }
    }
    $s = $sb2.ToString()
    while ($s.Contains('  ')) { $s = $s.Replace('  ', ' ') }
    $s = $s.Trim(' ', '.')
    if ([string]::IsNullOrWhiteSpace($s)) { $s = 'unnamed' }
    return $s
}

function Get-UniqueName {
    param(
        [Parameter(Mandatory = $true)][string]$Directory,
        [Parameter(Mandatory = $true)][string]$Desired,
        [Parameter(Mandatory = $true)][string]$CurrentFullName
    )
    $candidate = $Desired
    $n = 2
    while ($true) {
        $full = Join-Path $Directory $candidate
        if (-not (Test-Path -LiteralPath $full)) { return $candidate }
        # Already the same path (case-only / identical) — leave alone.
        if ([string]::Equals(
                (Resolve-Path -LiteralPath $full).Path,
                (Resolve-Path -LiteralPath $CurrentFullName).Path,
                [StringComparison]::OrdinalIgnoreCase)) {
            return $candidate
        }
        $base = [IO.Path]::GetFileNameWithoutExtension($Desired)
        $ext = [IO.Path]::GetExtension($Desired)
        $candidate = "{0} ({1}){2}" -f $base, $n, $ext
        $n++
    }
}

$root = (Resolve-Path -LiteralPath $Path).Path
if (-not (Test-Path -LiteralPath $root -PathType Container)) {
    throw "Path is not a folder: $root"
}

Write-Host "Root: $root"
if ($Apply) {
    Write-Host "Mode: APPLY (renaming)"
} else {
    Write-Host "Mode: dry-run (pass -Apply to rename)"
}
Write-Host ""

# Deepest paths first so child renames do not invalidate parent walks.
$items = Get-ChildItem -LiteralPath $root -Recurse -Force |
    Sort-Object { $_.FullName.Length } -Descending

$planned = 0
$changed = 0
$skipped = 0

foreach ($item in $items) {
    $oldName = $item.Name
    $newName = Get-FlipperSafeName -Name $oldName
    if ($newName -eq $oldName) {
        $skipped++
        continue
    }

    $dir = $item.DirectoryName
    if ($item.PSIsContainer) {
        $dir = Split-Path -Parent $item.FullName
    }
    $unique = Get-UniqueName -Directory $dir -Desired $newName -CurrentFullName $item.FullName
    $dest = Join-Path $dir $unique

    $planned++
    $kind = if ($item.PSIsContainer) { 'DIR ' } else { 'FILE' }
    Write-Host ("{0}  {1}" -f $kind, $item.FullName)
    Write-Host ("      -> {0}" -f $unique)

    if ($Apply) {
        Rename-Item -LiteralPath $item.FullName -NewName $unique
        $changed++
    }
}

Write-Host ""
Write-Host ("Would change / changed: {0} / {1}  |  already safe: {2}" -f $planned, $changed, $skipped)
if (-not $Apply -and $planned -gt 0) {
    Write-Host "Re-run with -Apply to perform renames, then copy/sync to the Flipper SD."
}
