# Geocoder

This CLI uses the [Geocoding](https://developers.google.com/maps/documentation/geocoding/start#sample-request) API to obtain the latitude and longitude coordinates of a given location.

## Usage

_Note: You must [obtain an API key](https://developers.google.com/maps/documentation/geocoding/get-api-key) in order to use the Geocoding API._

Replace `thisIsMyAPIKEY` in `geocode.ps1` line 5 with your actual API key.

Input is provided as a CSV containing the location information. The locations.csv file provides sample input data. Output is presented as a CSV containing the latitude and longitude coordinates.

Use the `-inputFile` flag to provide the input file.

```Powershell
.\geocode.ps1 -inputFile "locations.csv"
```
