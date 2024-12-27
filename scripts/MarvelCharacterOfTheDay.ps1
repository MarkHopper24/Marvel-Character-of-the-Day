<#
.SYNOPSIS
    This script interacts with the Marvel API to retrieve and process data about Marvel characters.

.PARAMETER marvelApiPublicKey
    The public key for accessing the Marvel API.

.PARAMETER marvelApiPrivateKey
    The private key for accessing the Marvel API.

.DESCRIPTION
    This script provides functions to interact with the Marvel API, retrieve character data, save it to a JSON file, and generate QR codes for character URLs. It includes functions to get Marvel API parameters, fetch data from the API, retrieve random Marvel characters, save character data, and generate QR codes.

.FUNCTIONS
    Get-MarvelApiParameters
        Generates the necessary parameters (timestamp, API key, and hash) for authenticating requests to the Marvel API.

    Get-MarvelApiData
        Fetches data from the Marvel API for a specified endpoint and query parameters.

    Get-RandomMarvelCharacter
        Retrieves a random Marvel character from the API.

    Get-Characters
        Retrieves all Marvel characters from the API, with pagination support.

    Save-Characters
        Saves the retrieved Marvel characters to a JSON file.

    Import-Characters
        Imports Marvel characters from a JSON file.

    Get-FirstCharacterComic
        Retrieves the first comic appearance of a specified Marvel character.

    Test-URL
        Tests if a given URL is reachable.

    Save-CharacterData
        Saves detailed data about a Marvel character, including generating QR codes for character URLs.

    Save-QRCode
        Generates a QR code for a given URL and saves it as an image file.

    Invoke-RandomCharacterProcessing
        Orchestrates the process of saving characters, importing them, selecting a random character, retrieving their first comic, and saving the character data.

.EXAMPLE
    .\Marvel.PS1 -marvelApiPublicKey "your_public_key" -marvelApiPrivateKey "your_private_key"
    This command runs the script with the specified Marvel API public and private keys.

.NOTES
    Ensure you have the necessary permissions and network access to reach the Marvel API and the QR code generation service.
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$marvelApiPublicKey,
    [Parameter(Mandatory = $true)]
    [string]$marvelApiPrivateKey
) 

# Set the Marvel API keys, base URL, and API version variables
$publicKey = $marvelApiPublicKey
$privateKey = $marvelApiPrivateKey
$BaseURL = "https://gateway.marvel.com:443/"
$APIVersion = "v1/public/"

<#
.SYNOPSIS
Function to generate the necessary parameters for authenticating requests to the Marvel API.

.DESCRIPTION
This function generates the timestamp, API key, and hash required for authenticating requests to the Marvel API.

.PARAMETER publicKey
Marvel API public key.

.PARAMETER privateKey
Marvel API private key.

.EXAMPLE
Get-MarvelApiParameters -publicKey "your_public_key" -privateKey "your_private_key"

.NOTES
This function is used internally by other functions to generate the required authentication parameters. It returns a hashtable with the timestamp, API key, and hash.
#>
function Get-MarvelApiParameters {
    param (
        [string]$publicKey,
        [string]$privateKey
    )

    $ts = [DateTime]::UtcNow.ToString("yyyyMMddHHmmssfff") + (Get-Random -Minimum 0 -Maximum 20).ToString()
    $hashInput = $ts + $privateKey + $publicKey
    $hash = [System.BitConverter]::ToString((New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hashInput))).Replace("-", "").ToLower()

    $params = @{
        ts     = $ts
        apikey = $publicKey
        hash   = $hash
    }

    return $params
}

<#
.SYNOPSIS
Function to fetch data from the Marvel API for a specified endpoint and query parameters.

.DESCRIPTION
This function makes a GET request to the Marvel API for a specified endpoint and query parameters, using the provided public and private keys for authentication.

.PARAMETER endpoint
The API endpoint to fetch data from.

.PARAMETER queryParams
Optional query parameters to include in the request.

.EXAMPLE
Get-MarvelApiData -endpoint "characters" -queryParams @{ limit = 10 }

.NOTES
This function is used to interact with the Marvel API and retrieve data based on the specified endpoint and query parameters. It returns the response data from the API.
#>
function Get-MarvelApiData {
    param (
        [string]$endpoint,
        [hashtable]$queryParams = @{}
    )
    
    $params = Get-MarvelApiParameters -publicKey $publicKey -privateKey $privateKey
    $authString = "ts=" + $params.ts + "&apikey=" + $params.apikey + "&hash=" + $params.hash

    $queryString = ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
    $url = $BaseURL + $APIVersion + $endpoint + "?" + $queryString + "&" + $authString

    $response = Invoke-RestMethod -Uri $url -Method Get
    return $response
}

<#
.SYNOPSIS
Function to retrieve and save the full list of Marvel characters from the API.

.DESCRIPTION
This function retrieves all Marvel characters from the API, handling pagination to fetch the complete list of characters. It returns an array of character objects.

.EXAMPLE
Get-Characters

.NOTES
This function uses parallel processing to improve performance when fetching data from the API. It retrieves the total number of characters, calculates the number of pages needed for pagination, and fetches characters in parallel with a specified limit.
#>
function Get-Characters {
    # Set the limit for characters per request. Maximum limit is 100.
    $limit = 100
    try {
        #First, find the count of total characters in the first request
        $total = (Get-MarvelApiData -endpoint "characters" -queryParams @{limit = 1; }).data.total

        # Calculate the number of pages needed for pagination
        $pages = [math]::Ceiling($total / $limit)
        $offsets = 0..($pages - 1) | ForEach-Object { $_ * $limit }
        $characters = New-Object 'object[,]' 1, $total

        # Fetch characters in parallel with a specified limit
        $offsets | ForEach-Object -Parallel {

            $publicKey = $using:publicKey
            $privateKey = $using:privateKey
            $BaseURL = "https://gateway.marvel.com:443/"
            $APIVersion = "v1/public/"
            function Get-MarvelApiParameters {
                param (
                    [string]$publicKey,
                    [string]$privateKey
                )
            
                $ts = [DateTime]::UtcNow.ToString("yyyyMMddHHmmssfff") + (Get-Random -Minimum 0 -Maximum 20).ToString()
                $hashInput = $ts + $privateKey + $publicKey
                $hash = [System.BitConverter]::ToString((New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hashInput))).Replace("-", "").ToLower()
            
                $params = @{
                    ts     = $ts
                    apikey = $publicKey
                    hash   = $hash
                }
            
                return $params
            }
            function Get-MarvelApiData {
                param (
                    [string]$endpoint,
                    [hashtable]$queryParams = @{},
                    [string]$publicKey,
                    [string]$privateKey
                )
                
                $params = Get-MarvelApiParameters -publicKey $publicKey -privateKey $privateKey
                $authString = "ts=" + $params.ts + "&apikey=" + $params.apikey + "&hash=" + $params.hash
            
                $queryString = ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
                $url = $BaseURL + $APIVersion + $endpoint + "?" + $queryString + "&" + $authString
            
                $response = Invoke-RestMethod -Uri $url -Method Get
                return $response
            }

            $params = @{
                endpoint    = "characters"
                queryParams = @{ offset = $_; limit = $using:limit }
            }

            Get-MarvelApiData -endpoint $params.endpoint -queryParams $params.queryParams -publicKey $publicKey -privateKey $privateKey
            
        } -ThrottleLimit 10 | ForEach-Object {
            $index = $_.data.offset
            $_.data.results | ForEach-Object {
                $characters[0, $index++] = $_
            }
        }

        # Filter out characters with no description and no first appearance and with image_not_available in the thumbnail path
        $characters = $characters | Where-Object { $_.description -ne "" -and $_.comics.available -gt 0 -and $_.thumbnail.path -notlike "*image_not_available*" }

        return $characters 
    }
    catch {
        throw $_.Exception
    }
}

<#
.SYNOPSIS
Function to save the retrieved Marvel characters to a JSON file.

.DESCRIPTION
This function retrieves the Marvel characters using the Get-Characters function and saves them to a JSON file named "characters.json" in the current directory.

.EXAMPLE
Save-Characters

.NOTES
This function uses the ConvertTo-Json cmdlet to convert the character objects to JSON format and writes the output to a file.
#>
function Save-Characters {
    $characters = Get-Characters
    $characters | ConvertTo-Json -Depth 10 | Set-Content -Path ".\characters.json"
}

<#
.SYNOPSIS
Function to import Marvel characters from a JSON file.

.DESCRIPTION
This function reads the character data from a JSON file named "characters.json" in the current directory and converts it back to PowerShell objects.

.EXAMPLE
Import-Characters

.NOTES
This function uses the ConvertFrom-Json cmdlet to read the JSON file and convert the data back to PowerShell objects.
#>
Function Import-Characters {
    $characters = Get-Content -Path ".\characters.json" | ConvertFrom-Json
    return $characters
}

<#
.SYNOPSIS
Function to retrieve the first comic appearance of a specified Marvel character.

.DESCRIPTION
This function fetches the first comic appearance of a specified Marvel character based on the character ID.

.PARAMETER characterId
The ID of the Marvel character to retrieve the first comic appearance for.

.EXAMPLE
Get-FirstCharacterComic -characterId 1011334

.NOTES
This function uses the Get-MarvelApiData function to fetch the comic data for the specified character ID and returns the first comic result.
#>
function Get-FirstCharacterComic {
    param (
        [string]$characterId
    )
    $comics = Get-MarvelApiData -endpoint "characters/$characterId/comics" -queryParams @{ orderBy = 'onsaleDate'; limit = 1 }

    return $comics.data.results[0]
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
Function to save detailed data about a Marvel character, including generating QR codes for character URLs.

.DESCRIPTION
This function processes and saves detailed data about a Marvel character, including their name, description, image URL, first comic appearance, URLs, and QR codes for character-related links.

.PARAMETER character
The Marvel character object to process.

.PARAMETER firstComic
The first comic appearance of the character.

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
    $characterDescription = $character.description
    $characterImageURL = $character.thumbnail.path + "." + $character.thumbnail.extension

    Invoke-WebRequest -Uri $characterImageURL -OutFile "character.jpg"    

    $firstComicTitle = $firstComic.title
    $firstComicDescription = $firstComic.description
    $releaseDate = $firstComic.dates | Where-Object { $_.type -eq "onsaleDate" } | Select-Object -ExpandProperty date
    
    try {
        $releaseDate = [DateTime]::Parse($releaseDate).ToShortDateString()
    }
    catch {
        $releaseDate = $null
    }

    $wikiURL = $character.urls | Where-Object { $_.type -eq "wiki" } | Select-Object -ExpandProperty url
    $comicsUrl = $character.urls | Where-Object { $_.type -eq "comiclink" } | Select-Object -ExpandProperty url
    $characterUrl = $character.urls | Where-Object { $_.type -eq "detail" } | Select-Object -ExpandProperty url

    if ($null -ne $wikiURL -and $wikiURL -ne "") {
        $wikiURL = Test-URL -url $wikiURL
        if ($null -ne $wikiURL -and $wikiURL -ne "") {
            $wikiUrlQrCode = Save-QRCode -url $wikiURL -fileName "wiki"
        }
    }
    if ($null -ne $comicsUrl -and $comicsUrl -ne "") {
        $comicsUrl = Test-URL -url $comicsUrl
        if ($null -ne $comicsUrl -and $comicsUrl -ne "") {
            $comicsUrlQrCode = Save-QRCode -url $comicsUrl -fileName "comicsQR"
        }
    }
    if ($null -ne $characterUrl -and $characterUrl -ne "") {
        $characterUrl = Test-URL -url $characterUrl
        if ($null -ne $characterUrl -and $characterUrl -ne "") {
            Save-QRCode -url $characterUrl
            $characterUrlQrCode = Save-QRCode -url $characterUrl -fileName "character"
        }
    }

    $date = Get-Date -Format "yyyy"
    $attribution = "Data provided by Marvel. © 2024 Marvel"

    $characterObject = [PSCustomObject]@{
        Name                  = $characterName
        Description           = $characterDescription
        ImageURL              = $characterImageURL
        FirstComicTitle       = $firstComicTitle
        FirstComicDescription = $firstComicDescription
        FirstAppearance       = $releaseDate
        WikiURL               = $wikiURL
        ComicsURL             = $comicsUrl
        CharacterURL          = $characterUrl
        WikiURLQRCode         = $wikiUrlQrCode
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
Function to orchestrate the process of saving characters, importing them, selecting a random character, retrieving their first comic, and saving the character data.

.DESCRIPTION
This function orchestrates the process of saving characters, importing them, selecting a random character, retrieving their first comic appearance, and saving the detailed character data.

.EXAMPLE
Invoke-RandomCharacterProcessing

.NOTES
This function combines the functionality of other functions to automate the process of selecting a random Marvel character, fetching their first comic appearance, and saving the character data.
#>
function Invoke-RandomCharacterProcessing {
    Save-Characters
    $characters = Import-Characters
    $randomCharacter = $characters | Get-Random
    $firstComic = Get-FirstCharacterComic -characterId $randomCharacter.id
    Save-CharacterData -character $randomCharacter -firstComic $firstComic
}

Invoke-RandomCharacterProcessing