# Marvel Character of the Day
  [![Fetch Marvel Character Of The Day](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml/badge.svg)](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml)
<p align="center">
<img src="https://logos-world.net/wp-content/uploads/2020/12/Marvel-Entertainment-Logo.png" alt="Marvel Logo" width="350" height="auto">
</p>

## Wolfsbane (Age of Apocalypse)
<p align="center">
<img src="http://i.annihil.us/u/prod/marvel/i/mg/3/20/528d3602d37e0.jpg" width="600" height="auto"/>
</p>

An only child, Rahne Sinclair's mutant powers emerged during the culling of Scotland by the Apocalypse's Horseman Mikhail when her parents attempted to hide her, but failed, and Rahne was discovered by Mikhail's hounds and brought before him alongside her parents whom Mikhail made Rahne beg for their lives, making her pledge allegiance to Apocalypse.

**First Appearance:** X-Man (1995) #12

[Comic Gallery](http://marvel.com/comics/characters/1010995/wolfsbane_age_of_apocalypse?utm_campaign=apiRef&utm_source=335f42edabc428513a94604c747fda4a)

<h2>What is this repository?</h2>
Marvel Character of the Day is a PowerShell-based application hosted in GitHub that provides information about a different Marvel character each day. The repository picks a random character daily @ 5am UTC.

<h3>Features</h3>
- <b>Daily Marvel Character Information:</b> Fetches and displays information about a random Marvel character every day from Marvel's official API.

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
Data provided by Marvel. © 2025 Marvel

This project and repository has no affilliation with Marvel.
