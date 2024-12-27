<#
.SYNOPSIS
This script updates the README.md file with the Marvel Character of the Day information.

.DESCRIPTION
This script reads the MarvelCharacterOfTheDay.json file to get the character information and then updates the README.md file with the character's name, image, description, first appearance, and comic gallery link.

.NOTES
File Name      : ReadMeUpdater.ps1
Author         : Marvel Character of the Day
Prerequisite   : MarvelCharacterOfTheDay.json file should be present in the parent directory.

.EXAMPLE
.\ReadMeUpdater.ps1
#>

# Read the JSON file
$marvelCharacter = Get-Content -Path ..\MarvelCharacterOfTheDay.json | ConvertFrom-Json

# Read the existing README content
$readmeContent = Get-Content -Path ..\README.md -Raw

# Create the new character section
$characterSection = @"
## $($marvelCharacter.Name)
<p align="center">
<img src="$($marvelCharacter.ImageURL)" width="600" height="auto"/>
</p>

$($marvelCharacter.Description)

**First Appearance:** $($marvelCharacter.FirstComicTitle)

[Comic Gallery]($($marvelCharacter.ComicsURL))
"@

# Replace the content between the Marvel logo and "What is this repository?" section
$pattern = "(?s)(?<=<\/p>\r?\n\r?\n).*?(?=<h2>What is this repository\?)"
$newContent = $readmeContent -replace $pattern, "$characterSection`n`n"

# Save the updated content back to README.md
#$newContent | Set-Content -Path "README.md" -NoNewline

# Display the updated content
Write-Output $newContent