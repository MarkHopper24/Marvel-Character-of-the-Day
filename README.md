# Marvel Character of the Day
  [![Fetch Marvel Character Of The Day](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml/badge.svg)](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml)
<p align="center">
<img src="https://logos-world.net/wp-content/uploads/2020/12/Marvel-Entertainment-Logo.png" alt="Marvel Logo" width="350" height="auto">
</p>

## Patsy Dragonsworth
<p align="center">
<img src="https://comicvine.gamespot.com/a/uploads/scale_medium/11125/111254576/4948767-patsy_dragonsworth_from_howard_the_duck_vol_1_6_0001.jpg" width="600" height="auto"/>
</p>

Patsy Dragonsworth was a young disturbed girl whom lived on her family estate with her insane mother. She was accused of whitchcraft by the townspeople that lived nearby and they undertook numerous attempts to either kill or 'eat' her. Patsty Dragonsworth was created by Steve Gerber and Gene Colan and first appeared in Howard the Duck Volume 1 issue 6 (1976). Patsy appeared in only two issues and her storyline came to an abrupt ending in which it was not made clear whether she survived or not. Whether creator Steve Gerber had plans to use her again in his series will most likely never be revealed.

**First Appearance:** Howard the Duck #6 (11/1/1976)

[Character Details](https://comicvine.gamespot.com/patsy-dragonsworth/4005-124791/)

<h2>What is this repository?</h2>
Marvel Character of the Day is a PowerShell-based application hosted in GitHub that provides information about a different Marvel character each day. The repository picks a random character daily @ 5am UTC.

<h3>Features</h3>

- <b>Daily Marvel Character Information:</b> Fetches and displays information about a random Marvel character every day from ComicVine's API.

- <b>Automated Scripts:</b> Uses PowerShell scripts and GitHub Workflow Actions to automate the process of retrieving and displaying character data.
  
- <b>Friendly JSON Endpoint:</b> Offers an easily retrievable endpoint containing a JSON file with the Daily Character information. You can find this here: https://raw.githubusercontent.com/MarkHopper24/Marvel-Character-of-the-Day/refs/heads/main/MarvelCharacterOfTheDay.json
  
- <b>TRMNL Integration:</b> Offers markdown templates for usage with [TRMNL](https://usetrmnl.com). To use this data for a plugin, you can either:
    1. Create a custom plugin with the polling strategy pointing to the JSON endpoint above. Copy the contents of the files in the .\templates folder to your plugin's markdown, and you're done.
    2. One-click install as a [Plugin recipe](https://help.usetrmnl.com/en/articles/10122094-plugin-recipes).
<p align="center">
<img src="https://raw.githubusercontent.com/MarkHopper24/Marvel-Character-of-the-Day/refs/heads/main/templates/trmnlPluginScreenshot.jpg" width="400" height="auto"/><br>
(Sample TRMNL screenshot)
</p>

<h3>Attribution</h3>
Data provided by Comic Vine https://comicvine.gamespot.com. © 2025 Marvel
This project and repository has no affilliation with Marvel.

