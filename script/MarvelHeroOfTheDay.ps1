param(
    [Parameter(Mandatory = $true)]
    [string]$marvelApiPublicKey,
    [Parameter(Mandatory = $true)]
    [string]$marvelApiPrivateKey
) 
$publicKey = $marvelApiPublicKey
$privateKey = $marvelApiPrivateKey
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
        [hashtable]$queryParams = @{}
    )
    
    $params = Get-MarvelApiParameters -publicKey $publicKey -privateKey $privateKey
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

#function to get all Ids of characters
function Get-Characters {
    $limit = 100
    try {
        $total = (Get-MarvelApiData -endpoint "characters" -queryParams @{limit = 1; }).data.total
        $pages = [math]::Ceiling($total / $limit)
        $offsets = 0..($pages - 1) | ForEach-Object { $_ * $limit }
        $characters = New-Object 'object[,]' 1, $total

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

        $characters = $characters | Where-Object { $_.description -ne "" }
        return $characters 
    }
    catch {
        throw $_.Exception
    }
}

function Save-Characters {
    $characters = Get-Characters
    $characters | ConvertTo-Json -Depth 10 | Set-Content -Path ".\characters.json"
}

Function Import-Characters {
    $characters = Get-Content -Path ".\characters.json" | ConvertFrom-Json
    return $characters
}

function Get-FirstCharacterComic {
    param (
        [string]$characterId
    )
    $comics = Get-MarvelApiData -endpoint "characters/$characterId/comics" -queryParams @{ orderBy = 'onsaleDate'; limit = 1 }
    return $comics.data.results[0]
}

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
            $comicsUrlQrCode = Save-QRCode -url $comicsUrl -fileName "comics"
        }
    }
    if ($null -ne $characterUrl -and $characterUrl -ne "") {
        $characterUrl = Test-URL -url $characterUrl
        if ($null -ne $characterUrl -and $characterUrl -ne "") {
            Save-QRCode -url $characterUrl
            $characterUrlQrCode = Save-QRCode -url $characterUrl -fileName "character"
        }
    }

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
    }

    $characterObject | ConvertTo-Json -Depth 10 | Set-Content -Path ".\MarvelHeroOfTheDay.json" -Force
    return $characterObject
}

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
