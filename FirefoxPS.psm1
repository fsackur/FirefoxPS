#region build-inlines
$Folders = "$PSScriptRoot/private", "$PSScriptRoot/public" | Resolve-Path -ea Ignore
$Folders |
    Get-ChildItem -File -Recurse -Filter *.ps1 |
    ForEach-Object {. $_}
#endregion build-inlines
