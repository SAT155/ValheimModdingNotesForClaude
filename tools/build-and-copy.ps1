<#
.SYNOPSIS
  Build a SnakeSquad mod locally and copy the DLL into a Thunderstore Mod Manager / r2modman profile.

.DESCRIPTION
  Run from anywhere. Expects the mod repos cloned next to this notes repo:
    <dev folder>\ValheimModdingNotesForClaude\tools\build-and-copy.ps1
    <dev folder>\SnakewaySurfer\SnakewaySurfer\SnakewaySurfer.csproj
    ...

  - Compiles against the game's Managed DLLs (read only) and the profile's BepInEx\core.
  - Never writes into the Steam install: passes GamePath=__none__, which turns off the
    csproj "Copy" target that would otherwise drop the DLL into <Steam>\Valheim\BepInEx\plugins.
  - Finds the plugin folder in the profile that already holds <Assembly>.dll (the imported
    release) and overwrites that DLL, keeping the release copy once as <Assembly>.dll.release-bak.
    If none is installed, creates BepInEx\plugins\SAT-<Assembly>-dev.
  - Local builds report "<version> (local build)" in LogOutput.log (BuildNumber stays 0), so a
    local build is easy to tell apart from a CI release.

.EXAMPLE
  .\build-and-copy.ps1 -Mod SnakewaySurfer
  .\build-and-copy.ps1 -Mod SnakeSailing -Project SnakeSkills\SnakeSkills.csproj
  .\build-and-copy.ps1 -Mod SnakewaySurfer -Restore   # put the release DLL back
#>
param(
    [Parameter(Mandatory = $true)][string]$Mod,          # repo folder name next to the notes repo
    [string]$Project = "",                               # csproj path inside the repo; default <Mod>\<Mod>.csproj
    [string]$Profile = "2026",                           # mod manager profile name
    [string]$ProfilesRoot = "",                          # default: Thunderstore Mod Manager, then r2modman
    [string]$ValheimDir = "",                            # default: found through Steam library folders
    [string]$Configuration = "Release",
    [switch]$NoCopy,
    [switch]$Restore
)
$ErrorActionPreference = "Stop"

$devRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$repo = Join-Path $devRoot $Mod
if (-not (Test-Path $repo)) { throw "Repo not found: $repo" }
if (-not $Project) { $Project = "$Mod\$Mod.csproj" }
$csproj = Join-Path $repo $Project
if (-not (Test-Path $csproj)) { throw "Project not found: $csproj (pass -Project)" }

# --- Profile -------------------------------------------------------------------------------
if (-not $ProfilesRoot) {
    $candidates = @(
        (Join-Path $env:APPDATA "Thunderstore Mod Manager\DataFolder\Valheim\profiles"),
        (Join-Path $env:APPDATA "r2modmanPlus-local\Valheim\profiles")
    )
    $ProfilesRoot = $candidates | Where-Object { Test-Path (Join-Path $_ $Profile) } | Select-Object -First 1
    if (-not $ProfilesRoot) { throw "Profile '$Profile' not found under: $($candidates -join '; ')" }
}
$bepinex = Join-Path $ProfilesRoot "$Profile\BepInEx"
if (-not (Test-Path "$bepinex\core\BepInEx.dll")) { throw "No BepInEx\core in profile: $bepinex" }

# --- Valheim (read only) -------------------------------------------------------------------
if (-not $ValheimDir) {
    $steam = (Get-ItemProperty HKCU:\Software\Valve\Steam -ErrorAction SilentlyContinue).SteamPath
    if (-not $steam) { throw "Steam not found in the registry; pass -ValheimDir" }
    $libs = @($steam) + (Select-String -Path "$steam\steamapps\libraryfolders.vdf" -Pattern '"path"\s+"([^"]+)"' |
        ForEach-Object { $_.Matches[0].Groups[1].Value -replace '\\\\', '\' })
    $ValheimDir = $libs | ForEach-Object { Join-Path $_ "steamapps\common\Valheim" } |
        Where-Object { Test-Path "$_\valheim_Data\Managed\assembly_valheim.dll" } | Select-Object -First 1
    if (-not $ValheimDir) { throw "Valheim not found in any Steam library; pass -ValheimDir" }
}
$managed = Join-Path $ValheimDir "valheim_Data\Managed"

[xml]$xml = Get-Content $csproj
$asm = ($xml.Project.PropertyGroup | ForEach-Object { $_.AssemblyName } | Where-Object { $_ } | Select-Object -First 1)
if (-not $asm) { $asm = [IO.Path]::GetFileNameWithoutExtension($csproj) }

# --- Find the installed plugin folder -------------------------------------------------------
$plugins = Join-Path $bepinex "plugins"
$installed = Get-ChildItem $plugins -Recurse -Filter "$asm.dll" -ErrorAction SilentlyContinue | Select-Object -First 1
$target = if ($installed) { $installed.FullName } else { Join-Path $plugins "SAT-$asm-dev\$asm.dll" }
$backup = "$target.release-bak"

if ($Restore) {
    if (-not (Test-Path $backup)) { throw "No backup to restore at $backup" }
    Copy-Item $backup $target -Force
    Remove-Item $backup
    Write-Host "Restored release DLL: $target"
    return
}

Write-Host "Repo     : $repo"
Write-Host "Managed  : $managed"
Write-Host "BepInEx  : $bepinex"
Write-Host "Target   : $target"

# GamePath=__none__ keeps the csproj Copy target from writing into the Steam install.
& dotnet build $csproj -c $Configuration -nologo -v:q "-p:GamePath=__none__" "-p:ManagedDir=$managed" "-p:BepInExDir=$bepinex"
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

$built = Get-ChildItem (Split-Path $csproj) -Recurse -Filter "$asm.dll" |
    Where-Object { $_.FullName -match "\\bin\\$Configuration\\" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $built) { throw "Built DLL not found under bin\$Configuration" }
Write-Host "Built    : $($built.FullName)"
if ($NoCopy) { return }

$running = Get-Process valheim -ErrorAction SilentlyContinue
if ($running) { throw "Valheim is running; close it before copying (the DLL is locked)." }

New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
if ((Test-Path $target) -and -not (Test-Path $backup)) { Copy-Item $target $backup }
Copy-Item $built.FullName $target -Force
Write-Host "Copied   : $target"
