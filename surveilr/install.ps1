$ErrorActionPreference = 'Stop'

$RepoOwner = 'opsfolio'
$RepoName = 'releases.opsfolio.com'
$Target = 'x86_64-pc-windows-gnu'
$Version = $null

if ($Args.Length -eq 1) {
  $Version = $Args.Get(0)
}

if (-not $Version) {
  $Version = (curl.exe -s "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest" | ConvertFrom-Json).tag_name
}

$DownloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/$Version/resource-surveillance_${Version}_${Target}.zip"

Write-Output "Download URL: $DownloadUrl"
Write-Output "Version: $Version"
Write-Output "Target: $Target"

$InstallDir = "$HOME\.surveilr"
$BinDir = "$InstallDir\bin"
$SurveilrZip = "$BinDir\surveilr.zip"
$SurveilrExe = "$BinDir\surveilr.exe"

if (!(Test-Path $BinDir)) {
  New-Item $BinDir -ItemType Directory | Out-Null
}

Write-Output "Downloading the file to $SurveilrZip..."
curl.exe -Lo $SurveilrZip $DownloadUrl

if ($SurveilrZip.EndsWith(".zip")) {
    Write-Output "Extracting the .zip file..."
    try {
        Expand-Archive -Path $SurveilrZip -DestinationPath $BinDir -Force
    } catch {
        Write-Output "Error extracting .zip file: $_"
        Remove-Item $SurveilrZip
        Exit 1
    }
} else {
    Write-Output "Unsupported file format: $SurveilrZip"
    Exit 1
}

Remove-Item $SurveilrZip
Write-Output "Extraction completed."

$User = [System.EnvironmentVariableTarget]::User
$Path = [System.Environment]::GetEnvironmentVariable('Path', $User)
if (!(";${Path};".ToLower() -like "*;${BinDir};*".ToLower())) {
  [System.Environment]::SetEnvironmentVariable('Path', "${Path};${BinDir}", $User)
  $Env:Path += ";${BinDir}"
}

Write-Output "Surveilr was installed successfully to ${SurveilrExe}"
Write-Output "Run 'surveilr --help' to get started."
Write-Output "Need help? Reach out to support at https://github.com/$RepoOwner/$RepoName/issues"
