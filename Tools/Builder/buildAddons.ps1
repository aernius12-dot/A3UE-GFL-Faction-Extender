param (
    [string]$modFileName = "mod.cpp",
    [string]$metaFileName = "meta.cpp"
)

#find witch folder is the modfolder
$folders = Get-Childitem "$PSScriptRoot\..\.." -Directory
foreach ($folder in $folders) {
    $folderName = $folder.Name
    $subFolders = Get-Childitem "$PSScriptRoot\..\..\$folderName" -Directory
    $subFolders = $subFolders | Where-Object { $_.Name -eq "addons" }
    if (($subFolders | Measure-Object).Count -gt 0) {
        $addonName = $folderName
        break
    }
}

#replace this with the modfolder name
#$addonName = "A3AE" # this is automated in the code block above
"Meta file name: $metaFileName`n`n"

Push-Location
Set-Location "$PSScriptRoot\..\..\$addonName"

"`n`nSetup temporary directories..."
if (Test-Path "..\build") {
    Remove-Item -Path "..\build" -Recurse -Force
}
New-Item -Path "..\build" -ItemType Directory -Force > $null
New-Item -Path "..\build\$addonName" -ItemType Directory -Force > $null
New-Item -Path "..\build\$addonName\addons" -ItemType Directory -Force > $null
New-Item -Path "..\build\$addonName\Keys" -ItemType Directory -Force > $null

$addonLocation = "." # We are here already
$addonOutLocation = "$PSScriptRoot\..\..\build\$addonName"
$addonsOutLocation = "$addonOutLocation\addons"

"`nBuild addons..."
$modules = Get-Childitem "$addonLocation\addons" -Directory
foreach ($module in $modules) {
    $pboName = "$($module.Name).pbo"
    #"Building $pboName...  $addonLocation\addons\$($module.Name)   -> $addonsOutLocation\$pboName"
    "Building $pboName ..."
    .$PSScriptRoot\hemtt armake pack --force $module.fullName "$addonsOutLocation\$pboName"
}

"`nCopy mod.cpp..."
Copy-Item "$modFileName" $addonOutLocation
Push-Location
Set-Location $addonOutLocation
Rename-Item $modFileName "mod.cpp"
Pop-Location

"`nCopy mod assets..."
Copy-Item "$addonLocation\addons\templates\data\gnk_logo_co.paa" $addonOutLocation
Copy-Item "$addonLocation\addons\templates\data\gnk_logo.png"    $addonOutLocation

"`nCopy meta.cpp..."
Copy-Item "meta\$metaFileName" $addonOutLocation
Push-Location
Set-Location $addonOutLocation
Rename-Item $metaFileName "meta.cpp"
Pop-Location

Pop-Location

Pop-Location

Pop-Location

"`nDeploy to Steam workshop..."
$steamModPath = "D:\Steam\steamapps\workshop\content\107410\A3UE GFL"
if (Test-Path $steamModPath) {
    Copy-Item "$addonOutLocation\addons\*.pbo" "$steamModPath\addons\" -Force
    Copy-Item "$addonOutLocation\mod.cpp"         "$steamModPath\mod.cpp" -Force
    Get-ChildItem "$addonOutLocation\*.paa" | ForEach-Object { Copy-Item $_.FullName "$steamModPath\$($_.Name)" -Force }
    Get-ChildItem "$addonOutLocation\*.png" | ForEach-Object { Copy-Item $_.FullName "$steamModPath\$($_.Name)" -Force }
    "Deployed to $steamModPath"
} else {
    "Steam mod path not found, skipping deploy"
}

$displayTime = Get-Date -DisplayHint DateTime
"Antistasi builder ran at: $displayTime"
