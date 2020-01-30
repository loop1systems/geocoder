$APIKEY = ""

# Verify that the API key is not empty
if ($APIKEY -eq $null -or $APIKEY -eq "") {
    Write-Output "Please provide an API key."
    Exit
}

# Connect to SolarWinds
$swis = Connect-Swis -Hostname "" -Username "" -Password ""

# Query SolarWinds for distinct values in the City custom property
$cities = Get-SwisData $swis "SELECT DISTINCT City FROM Orion.NodesCustomProperties WHERE City IS NOT NULL"

# Geocoding base url
$url = "https://maps.googleapis.com/maps/api/geocode/json?"

# hash table for storing response
$cityData = @{ }

# Iterate through cities
foreach ($city in $cities) {
    if ($cityData[$city] -ne $null) {
        Continue
    }

    # build the query parameters
    $params = @{ address = $city ; key = $APIKEY }

    # send API request
    $response = Invoke-WebRequest $url -Method Get -Body $params -UseBasicParsing | ConvertFrom-Json

    # check response status
    if ($response.status -ne "OK") {
        $response.error_message
        Exit
    }

    # add the response to the hash map
    if ($response.results.geometry.location -is [system.array]) {
        $cityData[$city] = $response.results.geometry.location.lat[0], $response.results.geometry.location.lng[0]
    }
    else {
        $cityData[$city] = $response.results.geometry.location.lat, $response.results.geometry.location.lng
    }
}

# Query SolarWinds for a list of NodeID & City
$nodes = Get-SwisData $swis "SELECT n.NodeID, cp.City FROM Orion.Nodes n JOIN Orion.NodesCustomProperties cp ON n.NodeID = cp.NodeID WHERE cp.City IS NOT NULL"

# Iterate through each node
foreach ($node in $nodes) {
    # Get the lat/long coordinates matching the node's city
    $coordinates = $cityData[$node.City]

    # Query SolarWinds for a matching point uri
    $pointUri = Get-SwisData $swis "SELECT Uri FROM Orion.WorldMap.Point WHERE InstanceID = $($node.NodeID) AND Instance = 'Orion.Nodes'"

    # If no point exists for this NodeID
    # create Orion.WorldMapPoint
    if ($pointUri -eq $null) {
        "creating point for node $($node.NodeID)"
        $pointProperties = @{
            Instance      = "Orion.Nodes";
            InstanceID    = $node.NodeID;
            Latitude      = $coordinates[0];
            Longitude     = $coordinates[1];
            StreetAddress = $node.City;
        }

        New-SwisObject $swis -EntityType "Orion.WorldMap.Point" -Properties $pointProperties | Out-Null
    }
    # If a point exists for this NodeID
    # Update Orion.WorldMapPoint
    else {
        "updating point for node $($node.NodeID)"
        $pointProperties = @{
            Latitude      = $coordinates[0];
            Longitude     = $coordinates[1];
            StreetAddress = $node.City;
        }

        Set-SwisObject $swis -Uri $pointUri -Properties $pointProperties
    }
}