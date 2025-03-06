function Get-FirefoxProfile
{
    [CmdletBinding(DefaultParameterSetName = 'Current')]
    param
    (
        [Parameter(ParameterSetName = 'Current')]
        [ValidateScript({$_})]
        [switch]$Current,

        [Parameter(ParameterSetName = 'All', Position = 0)]
        [SupportsWildcards()]
        [ArgumentCompletions('default', 'default-release')]
        [string]$Name = "*"
    )

    $FirefoxProfileRoot = "~/.mozilla/firefox" | Resolve-Path -ErrorAction Stop
    $IniContent = Get-Content -Raw (Join-Path $FirefoxProfileRoot profiles.ini)
    $ProfileChunks = $IniContent -split '(?<=\n)(?=\[\w+\])' | ForEach-Object Trim

    $CurrentProfile = $null
    $Profiles = $ProfileChunks |
        ForEach-Object {
            $Lines = $_ -split "\r?\n"
            $Heading = $Lines[0] -replace '^\[|\]$'
            $Lines = $Lines | Select-Object -Skip 1
            if ($Heading -eq "General")
            {
                return
            }
            if ($Heading.StartsWith("Install"))
            {
                $CurrentProfile = @($Lines) -match "^Default=" -replace "^Default=" | Select-Object -First 1
                return
            }
            $Props = [ordered]@{
                Name = $null
                Path = $null
                IsRelative = $null
                Location = $null
            }
            $Lines | ForEach-Object {
                $Key, $Value = $_ -split '=', 2
                $IntValue = $null
                if ([int]::TryParse($Value, [ref]$IntValue))
                {
                    $Value = if ($IntValue -in (0, 1)) {[bool]$IntValue} else {$IntValue}
                }
                $Props[$Key] = $Value
            }
            $Props.Location = if ($Props.IsRelative) {Join-Path $FirefoxProfileRoot $Props.Path} else {$Props.Path}
            [o]$Props
        }

    if ($PSCmdlet.ParameterSetName -eq 'Current')
    {
        $Profiles | Where-Object Path -eq $CurrentProfile
    }
    else
    {
        $Profiles | Where-Object {$_.Name -like $Name -or $_.Path -like $Name}
    }
}
