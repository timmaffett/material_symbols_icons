# Uninstall-Font.ps1
param($file)

$signature = @'
[DllImport("gdi32.dll")]
public static extern bool RemoveFontResource(string lpszFilename);
'@

$type = Add-Type -MemberDefinition $signature `
    -Name FontUtils -Namespace RemoveFontResource `
    -Using System.Text -PassThru
   
$type::RemoveFontResource($file)
