<#
.SYNOPSIS
    This script interacts with the Comic Vine API to retrieve and process data about Marvel characters.

.PARAMETER comicVineApiKey
    The API key for accessing the Comic Vine API.

.DESCRIPTION
    This script provides functions to interact with the Comic Vine API, retrieve a random Marvel character, save it to a JSON file, and generate QR codes for character URLs. It includes functions to fetch data from the API, retrieve a random character by offset, save character data, and generate QR codes.

.FUNCTIONS
    Get-ComicVineApiData
        Fetches data from the Comic Vine API for a specified endpoint or full URL and query parameters.

    Get-RandomCharacter
        Retrieves a single random Marvel character from the Comic Vine API using a random offset.

    Get-FirstCharacterComic
        Retrieves the first comic appearance of a specified character.

    Test-URL
        Tests if a given URL is reachable.

    Save-CharacterData
        Saves detailed data about a character, including generating QR codes for character URLs.

    Save-QRCode
        Generates a QR code for a given URL and saves it as an image file.

    Invoke-RandomCharacterProcessing
        Orchestrates the process of selecting a random character, retrieving their first comic, and saving the character data.

.EXAMPLE
     .\MarvelCharacterOfTheDay.PS1 -comicVineApiKey "your_api_key"
     This command runs the script with the specified Comic Vine API key.

.NOTES
     File Name      : MarvelCharacterOfTheDay.ps1
     Author         : Mark Hopper
     Prerequisite   : The MarvelCharacterOfTheDay.json and README.md files should be present in the parent directory.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$comicVineApiKey
) 

# Set the Comic Vine API key and base URL
$apiKey = $comicVineApiKey
$BaseURL = "https://comicvine.gamespot.com/api/"

<#
.SYNOPSIS
Function to fetch data from the Comic Vine API for a specified endpoint and query parameters.

.DESCRIPTION
This function makes a GET request to the Comic Vine API for a specified endpoint path (relative to the base URL) or a full API URL. It automatically appends the API key and JSON format parameters.

.PARAMETER endpoint
The API endpoint path (relative to base URL) or a full API URL to fetch data from.

.PARAMETER queryParams
Optional additional query parameters to include in the request.

.EXAMPLE
Get-ComicVineApiData -endpoint "characters" -queryParams @{ limit = 10; filter = "publisher:31" }

.NOTES
This function is used to interact with the Comic Vine API and retrieve data based on the specified endpoint and query parameters. It returns the response data from the API.
#>
function Get-ComicVineApiData {
    param (
        [string]$endpoint,
        [hashtable]$queryParams = @{}
    )

    $queryParams["api_key"] = $apiKey
    $queryParams["format"] = "json"

    $queryString = ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"

    if ($endpoint -like "http*") {
        $url = $endpoint + "?" + $queryString
    }
    else {
        $url = $BaseURL + $endpoint + "?" + $queryString
    }

    $maxRetries = 5
    $retryDelay = 10
    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            $response = Invoke-RestMethod -Uri $url -Method Get
            return $response
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            if ($null -ne $statusCode -and $statusCode -eq 420 -and $attempt -lt $maxRetries) {
                Write-Warning "Rate limited (420). Waiting $retryDelay seconds before retry $attempt of $($maxRetries - 1)..."
                Start-Sleep -Seconds $retryDelay
                $retryDelay = $retryDelay * 2
            }
            else {
                throw $_
            }
        }
    }
}

<#
.SYNOPSIS
Helper function to strip HTML tags from a string.

.DESCRIPTION
Removes all HTML tags from the provided string and returns the plain text content.

.PARAMETER html
The HTML string to strip tags from.

.EXAMPLE
Remove-HtmlTags -html "<p>Some <b>bold</b> text</p>"
#>
function Remove-HtmlTags {
    param (
        [string]$html
    )
    if ($null -eq $html -or $html -eq "") { return "" }
    return ($html -replace '<[^>]+>', '').Trim()
}

<#
.SYNOPSIS
Function to retrieve a single random Marvel character from the Comic Vine API.

.DESCRIPTION
This function retrieves the total count of Marvel characters, generates a random offset, and fetches a single character at that offset. It retries with a new random offset if the selected character does not meet quality criteria (must have a description, a first appearance, and a valid image).

.EXAMPLE
Get-RandomCharacter

.NOTES
This function uses the Comic Vine API offset and limit parameters to efficiently select a random character without fetching the full character list.
#>
function Get-RandomCharacter {
    $maxAttempts = 20
    try {
        # Get the total number of Marvel characters (publisher ID 31)
        $countResponse = Get-ComicVineApiData -endpoint "characters" -queryParams @{ limit = 1; filter = "publisher:31" }
        $total = $countResponse.number_of_total_results

        for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
            # Pick a random offset and fetch a single character at that position
            $randomOffset = Get-Random -Minimum 0 -Maximum $total
            $response = Get-ComicVineApiData -endpoint "characters" -queryParams @{
                offset = $randomOffset
                limit  = 1
                filter = "publisher:31"
            }
            $character = $response.results | Select-Object -First 1

            # Verify the character meets quality criteria before returning
            if ($null -ne $character -and
                $null -ne $character.deck -and $character.deck -ne "" -and
                $null -ne $character.first_appeared_in_issue -and
                $character.image.medium_url -notlike "*image_not_available*") {
                return $character
            }

            Write-Verbose "Character at offset $randomOffset did not meet criteria. Attempt $attempt of $maxAttempts."
        }

        throw "Could not find a suitable character after $maxAttempts attempts."
    }
    catch {
        throw $_
    }
}

<#
.SYNOPSIS
Function to retrieve the first comic appearance of a specified character.

.DESCRIPTION
This function fetches the first comic appearance of a character using the issue URL stored in the character's first_appeared_in_issue field from the Comic Vine API.

.PARAMETER character
The character object containing the first_appeared_in_issue field with the issue's API detail URL.

.EXAMPLE
Get-FirstCharacterComic -character $character

.NOTES
This function uses the Get-ComicVineApiData function to fetch the issue data from the Comic Vine API and returns the issue result object.
#>
function Get-FirstCharacterComic {
    param (
        [object]$character
    )

    if ($null -eq $character.first_appeared_in_issue) { return $null }

    $issueApiUrl = $character.first_appeared_in_issue.api_detail_url
    $issueResponse = Get-ComicVineApiData -endpoint $issueApiUrl

    return $issueResponse.results
}

<#
.SYNOPSIS
Function to test if a given URL is reachable.

.DESCRIPTION
This function tests if a given URL is reachable by making a HEAD request to the URL and checking the response status code.

.PARAMETER url
The URL to test.

.EXAMPLE
Test-URL -url "https://www.example.com"

.NOTES
This function uses the Invoke-WebRequest cmdlet with the HEAD method to check the URL's status code. It returns the URL if reachable, otherwise null.
#>
function Test-URL {
    param (
        [string]$url
    )

    try {
        $request = Invoke-WebRequest -Uri $url -Method Head -ErrorAction SilentlyContinue 
        if ($request.StatusCode -eq 200) {
            return $url
        }
    }
    catch {
        return $null
    }
}

<#
.SYNOPSIS
Function to save detailed data about a character, including generating QR codes for character URLs.

.DESCRIPTION
This function processes and saves detailed data about a character, including their name, description, image URL, first comic appearance, URLs, and QR codes for character-related links. It maps fields from the Comic Vine API response to the standard output format.

.PARAMETER character
The character object from the Comic Vine API to process.

.PARAMETER firstComic
The first comic appearance issue object for the character.

.EXAMPLE
Save-CharacterData -character $character -firstComic $firstComic

.NOTES
This function uses the Invoke-WebRequest cmdlet to download the character image, generates QR codes for character-related URLs, and saves the character data to a JSON file.
#>
Function Save-CharacterData {
    param (
        [object]$character,
        [object]$firstComic
    )

    $characterName = $character.name

    $characterDescription = $character.deck
    if ($null -eq $characterDescription -or $characterDescription -eq "") {
        $characterDescription = Remove-HtmlTags -html $character.description
    }

    $characterImageURL = $character.image.medium_url

    Invoke-WebRequest -Uri $characterImageURL -OutFile "character.jpg"

    $firstComicTitle = $null
    $firstComicDescription = $null
    $releaseDate = $null

    if ($null -ne $firstComic) {
        $volumeName = $firstComic.volume.name
        $issueNumber = $firstComic.issue_number
        if ($null -ne $volumeName -and $null -ne $issueNumber) {
            $firstComicTitle = $volumeName + " #" + $issueNumber
        }
        elseif ($null -ne $volumeName) {
            $firstComicTitle = $volumeName
        }
        else {
            $firstComicTitle = $firstComic.name
        }

        $firstComicDescription = $firstComic.deck
        if ($null -eq $firstComicDescription -or $firstComicDescription -eq "") {
            $firstComicDescription = Remove-HtmlTags -html $firstComic.description
        }

        $releaseDate = $firstComic.cover_date
        try {
            $releaseDate = [DateTime]::Parse($releaseDate).ToShortDateString()
        }
        catch {
            $releaseDate = $null
        }
    }

    $characterUrl = $character.site_detail_url
    $comicsUrl = if ($null -ne $firstComic) { $firstComic.site_detail_url } else { $null }

    $comicsUrlQrCode = $null
    $characterUrlQrCode = $null

    if ($null -ne $comicsUrl -and $comicsUrl -ne "") {
        $comicsUrl = Test-URL -url $comicsUrl
        if ($null -ne $comicsUrl -and $comicsUrl -ne "") {
            $comicsUrlQrCode = Save-QRCode -url $comicsUrl -fileName "comicsQR"
        }
    }
    if ($null -ne $characterUrl -and $characterUrl -ne "") {
        $characterUrl = Test-URL -url $characterUrl
        if ($null -ne $characterUrl -and $characterUrl -ne "") {
            $characterUrlQrCode = Save-QRCode -url $characterUrl -fileName "character"
        }
    }

    $date = Get-Date -Format "yyyy"
    $attribution = "Data provided by Comic Vine. © $date Comic Vine"

    $characterObject = [PSCustomObject]@{
        Name                  = $characterName
        Description           = $characterDescription
        ImageURL              = $characterImageURL
        FirstComicTitle       = $firstComicTitle
        FirstComicDescription = $firstComicDescription
        FirstAppearance       = $releaseDate
        WikiURL               = $null
        ComicsURL             = $comicsUrl
        CharacterURL          = $characterUrl
        WikiURLQRCode         = $null
        ComicsURLQRCode       = $comicsUrlQrCode
        CharacterURLQRCode    = $characterUrlQrCode
        Date                  = $date
        Attribution           = $attribution
    }

    # Save character data to a JSON file
    $characterObject | ConvertTo-Json -Depth 10 | Set-Content -Path ".\MarvelCharacterOfTheDay.json" -Force

    return $characterObject
}

<#
.SYNOPSIS
Function to generate a QR code for a given URL and save it as an image file.

.DESCRIPTION
This function generates a QR code for a given URL using the QR code generation service and saves it as an image file.

.PARAMETER url
The URL to generate the QR code for.

.PARAMETER fileName
The name of the file to save the QR code as.

.EXAMPLE
Save-QRCode -url "https://www.example.com" -fileName "example"

.NOTES
This function uses the Invoke-WebRequest cmdlet to download the QR code image from the QR code generation service and saves it as a JPG file.
#>
function Save-QRCode {
    param (
        [string]$url,
        [string]$fileName
    )

    $qrCode = $fileName + ".jpg"
    $qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$url"
    Invoke-WebRequest -Uri $qrCodeUrl -OutFile $qrCode
    return $qrCode
}

<#
.SYNOPSIS
Function to orchestrate the process of selecting a random character, retrieving their first comic, and saving the character data.

.DESCRIPTION
This function orchestrates the process of selecting a random Marvel character by offset, retrieving their first comic appearance, and saving the detailed character data.

.EXAMPLE
Invoke-RandomCharacterProcessing

.NOTES
This function combines the functionality of other functions to automate the process of selecting a random Marvel character, fetching their first comic appearance, and saving the character data.
#>
function Invoke-RandomCharacterProcessing {
    $randomCharacter = Get-RandomCharacter
    $firstComic = Get-FirstCharacterComic -character $randomCharacter
    Save-CharacterData -character $randomCharacter -firstComic $firstComic
}

Invoke-RandomCharacterProcessing