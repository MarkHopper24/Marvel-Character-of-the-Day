# Marvel Character of the Day
  [![Fetch Marvel Character Of The Day](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml/badge.svg)](https://github.com/MarkHopper24/Marvel-Character-of-the-Day/actions/workflows/MarvelCharacterOTDFetcher.yml)
<p align="center">
<img src="https://logos-world.net/wp-content/uploads/2020/12/Marvel-Entertainment-Logo.png" alt="Marvel Logo" width="350" height="auto">
</p>

## Strong Guy
<p align="center">
<img src="http://i.annihil.us/u/prod/marvel/i/mg/2/10/4c00322a3173c.jpg" width="600" height="auto"/>
</p>

According to his own admission, Guido was a nerdy-looking kid in his early life, bullied by other children, but after he discovered his mutant ability at a young age, when he was struck by a school bus, no one bullied him again.

**First Appearance:** X-Factor (1986) #71

[Comic Gallery](http://marvel.com/comics/characters/1011051/strong_guy?utm_campaign=apiRef&utm_source=422c32a7c4c3f9adfe3f4aef0db1a1e8)

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
