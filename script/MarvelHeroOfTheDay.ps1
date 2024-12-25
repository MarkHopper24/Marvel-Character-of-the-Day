param(
    [Parameter(Mandatory = $True)]
    [string]$marvelApiPublicKey,
    [Parameter(Mandatory = $True)]
    [string]$marvelApiPrivateKey
) 

$BaseURL = "https://gateway.marvel.com:443/"
$APIVersion = "v1/public/"

function Get-MarvelApiParameters {
    param (
        [string]$marvelApiPublicKey,
        [string]$marvelApiPrivateKey
    )

    $ts = [DateTime]::UtcNow.ToString("yyyyMMddHHmmssfff") + (Get-Random -Minimum 0 -Maximum 20).ToString()
    $hashInput = $ts + $marvelApiPrivateKey + $marvelApiPublicKey
    $hash = [System.BitConverter]::ToString((New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hashInput))).Replace("-", "").ToLower()

    $params = @{
        ts     = $ts
        apikey = $marvelApiPublicKey
        hash   = $hash
    }

    return $params
}

function Get-MarvelApiData {
    param (
        [string]$endpoint,
        [hashtable]$queryParams = @{}
    )
    
    $params = Get-MarvelApiParameters -marvelApiPublicKey $marvelApiPublicKey -marvelApiPrivateKey $marvelApiPrivateKey
    $authString = "ts=" + $params.ts + "&apikey=" + $params.apikey + "&hash=" + $params.hash

    $queryString = ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join "&"
    $url = $BaseURL + $APIVersion + $endpoint + "?" + $queryString + "&" + $authString

    $response = Invoke-RestMethod -Uri $url -Method Get
    return $response
}

function Get-RandomMarvelCharacter {
    $characters = Get-Characters
    $randomCharacter = $characters | Get-Random
    
    return $randomCharacter
}

function Get-Characters {
    $limit = 100
    try {
        $total = (Get-MarvelApiData -endpoint "characters" -queryParams @{limit = 1; }).data.total
        $pages = [math]::Ceiling($total / $limit)
        $offsets = 0..($pages - 1) | ForEach-Object { $_ * $limit }
        #Set the length of the array to the total number of characters
        $characters = New-Object 'object[,]' 1, $total

        $offsets | ForEach-Object -Parallel {

            ##Public and private keys
            $marvelApiPublicKey = $marvelApiPublicKey
            $marvelApiPrivateKey = "$marvelApiPrivateKey"
            $BaseURL = "https://gateway.marvel.com:443/"
            $APIVersion = "v1/public/"
            function Get-MarvelApiParameters {
                param (
                    [string]$marvelApiPublicKey,
                    [string]$marvelApiPrivateKey
                )
            
                $ts = [DateTime]::UtcNow.ToString("yyyyMMddHHmmssfff") + (Get-Random -Minimum 0 -Maximum 20).ToString()
                $hashInput = $ts + $marvelApiPrivateKey + $marvelApiPublicKey
                $hash = [System.BitConverter]::ToString((New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hashInput))).Replace("-", "").ToLower()
            
                $params = @{
                    ts     = $ts
                    apikey = $marvelApiPublicKey
                    hash   = $hash
                }
            
                return $params
            }
            function Get-MarvelApiData {
                param (
                    [string]$endpoint,
                    [hashtable]$queryParams = @{}
                )
                
                $params = Get-MarvelApiParameters -marvelApiPublicKey $marvelApiPublicKey -marvelApiPrivateKey $marvelApiPrivateKey
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
            Get-MarvelApiData -endpoint $params.endpoint -queryParams $params.queryParams
            #starting at the index of the offset, add each character to the array
            
        } -ThrottleLimit 10 | ForEach-Object {
            $index = $_.data.offset
            $_.data.results | ForEach-Object {
                $characters[0, $index++] = $_
            }
        }

        return $characters 

    }
    catch {
        throw $_.Exception
    }
}

#Function to save all characters to a JSON file
function Save-Characters {
    #$characters = Get-Characters | Where-Object { $_.description -ne "" }
    $characters | ConvertTo-Json -Depth 10 | Set-Content -Path ".\characters.json" -Force
}

Function Import-Characters {
    $characters = Get-Content -Path ".\characters.json" | ConvertFrom-Json
    return $characters
}

#Function to get the first comic of a character
function Get-FirstCharacterComic {
    param (
        [string]$characterId
    )

    #Get the comics of the character sorted by date
    <# #If no comics are found, get another random character
    while ($null -eq $firstComic -or $firstComic.count -eq 0) {
        $randomCharacter = $characters | Get-Random
        $firstComic = Get-FirstCharacterComic -characterId $randomCharacter.id
    } #>

    $comics = Get-MarvelApiData -endpoint "characters/$characterId/comics" -queryParams @{ orderBy = 'onsaleDate'; limit = 1 }

    #Sort the comics by onsaleDate
    return $comics.data.results[0]
}

Function Test-URL {
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

Function Save-CharacterData {
    param (
        [object]$character,
        [object]$firstComic
    )

    $characterName = $character.name
    $characterDescription = $character.description
    $characterImageURL = $character.thumbnail.path + "." + $character.thumbnail.extension

    if ($characterImageURL -contains "image_not_available") {
        $characterImageURL = $null
    }
    else {
        #Download the image
        Invoke-WebRequest -Uri $characterImageURL -OutFile "character.jpg"    
    }

    $firstComicTitle = $firstComic.title
    $firstComicDescription = $firstComic.description
    $releaseDate = $firstComic.dates | Where-Object { $_.type -eq "onsaleDate" } | Select-Object -ExpandProperty date
    
    try {
        $releaseDate = [DateTime]::Parse($releaseDate).ToShortDateString()
    }
    catch {
        $releaseDate = $null
    }
    #Show only the date not the time
    $wikiURL = $character.urls | Where-Object { $_.type -eq "wiki" } | Select-Object -ExpandProperty url
    $comicsUrl = $character.urls | Where-Object { $_.type -eq "comiclink" } | Select-Object -ExpandProperty url
    $characterUrl = $character.urls | Where-Object { $_.type -eq "detail" } | Select-Object -ExpandProperty url

    #Test the URLs to see if they are valid and respond with a 200 status code. If not, set the URL to $null
    if ($null -ne $wikiURL) {
        $wikiURL = Test-URL -url $wikiURL
        if ($null -ne $wikiURL) {
            $wikiUrlQrCode = Save-QRCode -url $wikiURL -fileName "wiki"
        }
    }
    if ($null -ne $comicsUrl) {
        $comicsUrl = Test-URL -url $comicsUrl
        if ($null -ne $comicsUrl) {
            $comicsUrlQrCode = Save-QRCode -url $comicsUrl -fileName "comics"
        }
    }
    if ($null -ne $characterUrl) {
        $characterUrl = Test-URL -url $characterUrl
        if ($null -ne $characterUrl) {
            Save-QRCode -url $characterUrl
            $characterUrlQrCode = Save-QRCode -url $characterUrl -fileName "character"
        }
    }

    #store the properties in a character object
    $characterObject = [PSCustomObject]@{
        Name               = $characterName
        Description        = $characterDescription
        ImageURL           = $characterImageURL
        FirstComicTitle    = $firstComicTitle
        FirstAppearance    = $releaseDate
        WikiURL            = $wikiURL
        ComicsURL          = $comicsUrl
        CharacterURL       = $characterUrl
        WikiURLQRCode      = $wikiUrlQrCode
        ComicsURLQRCode    = $comicsUrlQrCode
        CharacterURLQRCode = $characterUrlQrCode
    }

    Invoke-Item "character.jpg"

    #Save the character object to a JSON file
    $characterObject | ConvertTo-Json -Depth 10 | Set-Content -Path ".\MarvelHeroOfTheDay.json" -Force

    return $characterObject
}

#function to save a URL as a QR code
function Save-QRCode {
    param (
        [string]$url,
        [string]$fileName
    )

    $qrCode = $fileName + ".png"
    $qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$url"
    Invoke-WebRequest -Uri $qrCodeUrl -OutFile $qrCode
    return $qrCode
}

function Invoke-RandomCharacterProcessing {
    Save-Characters
    $characters = Import-Characters
    $randomCharacter = $characters | Get-Random
    $firstComic = Get-FirstCharacterComic -characterId $randomCharacter.id
    $characterObject = Save-CharacterData -character $randomCharacter -firstComic $firstComic
    return $characterObject
}

Invoke-RandomCharacterProcessing
