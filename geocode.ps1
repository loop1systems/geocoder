param (
    [Parameter(Mandatory = $true)][string]$inputFile
)

$APIKEY = "thisIsMyAPIKEY"

# Verify that the API key is not empty
if ($APIKEY -eq $null -or $APIKEY -eq "") {
    Write-Output "Please provide an API key."
}

# Read input csv
$locations = Import-Csv -Path $inputFile -Header "location"

# Geocoding endpoint
$url = "https://maps.googleapis.com/maps/api/geocode/json?"

# arraylist for storing response
$response = New-Object System.Collections.ArrayList
foreach ($loc in $locations) {
    # build the query parameters
    $params = @{ address = $loc ; key = $APIKEY }

    # send API request
    $r = Invoke-WebRequest $url -Method Get -Body $params -UseBasicParsing | ConvertFrom-Json | Select results

    $detailsObject = [PSCustomObject]@{
        location = $loc.location
        lat      = $r.results.geometry.location.lat
        lng      = $r.results.geometry.location.lng
    }

    $response.Add($detailsObject) | Out-Null
}

$response | Export-Csv -Path "lat-long.csv" -NoTypeInformation
