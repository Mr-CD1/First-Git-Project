# 生成 Windows 发布版并（若已安装 Inno Setup）编译安装包
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

Write-Host "==> flutter pub get"
flutter pub get

Write-Host "==> 生成各平台启动图标"
dart run flutter_launcher_icons

Write-Host "==> flutter build windows --release"
flutter build windows --release

$ReleaseDir = Join-Path $Root "build\windows\x64\runner\Release"
$Exe = Join-Path $ReleaseDir "facai_road.exe"
if (-not (Test-Path $Exe)) {
    throw "未找到 $Exe，请检查 BINARY_NAME 与构建是否成功。"
}

$Iss = Join-Path $Root "installer\windows\setup.iss"
$Iscc = Get-Command iscc -ErrorAction SilentlyContinue
if (-not $Iscc) {
    $DefaultIscc = "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
    if (Test-Path $DefaultIscc) {
        $Iscc = @{ Source = $DefaultIscc }
    }
}

if ($Iscc) {
    Write-Host "==> 编译安装包 (Inno Setup)"
    & $Iscc.Source $Iss
    $Dist = Join-Path $Root "dist\FacaiRoad_Setup_1.0.0.exe"
    if (Test-Path $Dist) {
        Write-Host "安装包已生成: $Dist"
    } else {
        Write-Host "ISCC 已运行，请在 dist 目录查看输出文件。"
    }
} else {
    $DistDir = Join-Path $Root "dist"
    New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
    $ZipPath = Join-Path $DistDir "FacaiRoad_1.0.0_portable.zip"
    if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
    Compress-Archive -Path (Join-Path $ReleaseDir "*") -DestinationPath $ZipPath
    Write-Host ""
    Write-Host "未检测到 Inno Setup (iscc)。已生成便携包（解压到任意目录即可运行）:"
    Write-Host "  $ZipPath"
    Write-Host ""
    Write-Host "若需要带安装向导的 .exe，请安装 Inno Setup 6 后重新运行本脚本，或打开:"
    Write-Host "  $Iss"
}
