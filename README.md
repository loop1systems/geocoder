# Geocoder

This CLI uses the [Geocoding](https://developers.google.com/maps/documentation/geocoding/start#sample-request) API to obtain the latitude and logitude coordinates of a given city.

## Usage

_Note: You must [obtain an API key](https://developers.google.com/maps/documentation/geocoding/get-api-key) in order to use the Geocoding API._

Replace `thisIsMyAPIKEY` in `geocode.ps1` line 5 with your actual API key.

Input is provided as a CSV containing the city and state information. The locations.csv file provides sample input data. Output is presented as a CSV containing the city/state values as well as the latitude and longitute coordinates.

Use the `-inputFile` flag to provide the input file.

```Powershell
.\geocode.ps1 -inputFile "locations.csv"
```
