# Marvel Character of the Day
  [![Fetch Marvel Character Of The Day](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml/badge.svg)](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml)
<p align="center">
<img src="https://logos-world.net/wp-content/uploads/2020/12/Marvel-Entertainment-Logo.png" alt="Marvel Logo" width="350" height="auto">
</p>

## Leo (Thanos' Zodiac)
<p align="center">
<img src="https://comicvine.gamespot.com/a/uploads/scale_medium/0/77/2685236-leo__thanos__zodiac___earth_616__002.jpg" width="600" height="auto"/>
</p>

Leo is one of the members of the new Zodiac team, a group of ambitious people who wanted to conquer the World. Leo wears a special suit supplied by Thanos that enables him to assume the form of a humanoid lion and gives him super-powers. Thanos wanted the Zodiac team to steal different powerful items and take them out from Earth in order to bring balance to the planet and the cosmos. He was one of the Zodiac members who attacked the Helicarrier in order to retrieve an Ultimate Nullifier, while battling the Hulk, he suffered a heart attack and died, the energy of his suit passed through Iron Man's armor, which helped him to known where Zodiac had their powers from and shut them down.

**First Appearance:** Avengers Assemble #1 (5/1/2012)

[Character Details](https://comicvine.gamespot.com/leo-thanos-zodiac/4005-87622/)

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

