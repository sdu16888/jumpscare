# Safe fullscreen jumpscare video player
# Expects the downloaded video at: %TEMP%\js\jumpscare.mp4

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$VideoPath = Join-Path $env:TEMP 'js\jumpscare.mp4'

if (-not (Test-Path -LiteralPath $VideoPath -PathType Leaf)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Video not found:`n$VideoPath`n`nMake sure the MP4 has been downloaded and extracted.",
        "Jumpscare video not found",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
    exit
}

# Wait for the user to move the mouse; this does not send keystrokes
# or change any keyboard/system settings.
$startX = [System.Windows.Forms.Cursor]::Position.X
$startY = [System.Windows.Forms.Cursor]::Position.Y

while ($true) {
    Start-Sleep -Milliseconds 150
    $pos = [System.Windows.Forms.Cursor]::Position
    if (($pos.X -ne $startX) -or ($pos.Y -ne $startY)) {
        break
    }
}

[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Video Player"
        WindowState="Maximized"
        WindowStyle="None"
        ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen"
        Background="Black"
        Topmost="True">
    <MediaElement Name="VideoPlayer"
                  Stretch="Uniform"
                  LoadedBehavior="Manual"
                  UnloadedBehavior="Stop" />
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $XAML
$Window = [Windows.Markup.XamlReader]::Load($reader)
$VideoPlayer = $Window.FindName('VideoPlayer')

$VideoPlayer.Volume = 1.0
$VideoPlayer.Source = [Uri]::new((Resolve-Path -LiteralPath $VideoPath).Path)

$VideoPlayer.Add_MediaEnded({
    $Window.Close()
})

$Window.Add_ContentRendered({
    $VideoPlayer.Play()
})

$Window.ShowDialog() | Out-Null
