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
$locData = New-Object System.Collections.ArrayList

# Iterate through locations
foreach ($loc in $locations) {
    # build the query parameters
    $params = @{ address = $loc ; key = $APIKEY }

    # send API request
    $response = Invoke-WebRequest $url -Method Get -Body $params -UseBasicParsing | ConvertFrom-Json

    # check response status
    if ($response.status -ne "OK") {
        $response.error_message
    }

    # build a detailsObject
    $detailsObject = [PSCustomObject]@{
        location = $loc.location
        lat      = $response.results.geometry.location.lat
        lng      = $response.results.geometry.location.lng
    }

    $locData.Add($detailsObject) | Out-Null
}

# Export data to csv
$locData | Export-Csv -Path "lat-long.csv" -NoTypeInformation
