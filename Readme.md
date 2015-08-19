# Zbot
Cinch IRC bot written with plenty of help. I will not claim any of the plugins
And will try to get the correct credits in source

# Installation
Zeta requires ruby >= 2.0.0 and rubygems. Installation beyond that is simple

_Steps_
* git clone https://github.com/flagrun/Zeta.git
* bundle install
* move the example configs into the base directory
* ruby ./migrate.rb (just the first time
* ruby ./zeta.rb
* after bot is currently running send your bot a message ?master (masterpass)

_Plugins_
All plugins are automatically loaded that are in the plugins directory

# Upgrade
_Steps_
* git pull
* bundle
* update config files to new examples
* ruby ./migrate.rb
* ruby ./zeta.rb

## Commands
roles: owner,admin,operator,halfop,voice,nobody
prefix: ?

### Admin
_Channel_
** Role Required: admin/owner **
* ?join (\#channel) - admin
* ?part (\#channel) - admin
* ?quit (\#channel) - owner

_Plugins_
** Role Required: admin **
* ?plugin load   (plugin)
* ?plugin unload (plugin)
* ?plugin reload (plugin)
* ?plugin set    (plugin)

_Developer_
** Role Required: owner **
* ?die (msg) // Kills the bot
* ?e  code   // (alias: eval) Evaluate command
* ?em code   // (alias: eval) Evaluate command send in msg
* ?er code   // (alias: evalreply) Evaluate command and send to channel

_Ignore_
** Role Required: operator **
* ?ignore (user)
* ?unignore (user)

_Channel_
** Role Required: operator **
* ?disable (channel) // can omit channel to use current
* ?enable  (channel) // enalbed a channel that has been disabled

_Access_
** Role Required: voice **
* ?setaccess (user) (level) // Levels: nobody,voice,halfop,operator,admin,owner,founder
* ?access (user) // Show current access level

_Uptime_
** Role Required: admin **
* ?uptime    // Bot uptime
* ?sysuptime // grabs the uptime from current system
* ?users     // shows users currently logged into shell

### Macros
Macros are prefixed by a period and are loaded from locales/macros.yml
example. typing in ".dnf" in channel will cause the bot to respond with "Duke Nukem Forever came out. Your argument is invalid."

### FIFO
Zeta will open a named pipe under bot/zeta.io messages sent to this pipe will be directly sent to the irc server

### Plugins
_Utility_
* ?calc (query) - Returns a wolframalpha solution
* ?wiki (term) - Returns a wikipedia entry

_Code Runner_
* ?run (lang) (code)
* ?langs - lists all of the languages that are supported

_Seen_
* ?seen (user)

_Misc_
* ?attack (target)
* ?info (plugin)
* ?fnord
* ?xmas - days till christmas
* ?mayan - current day in the mayan calendar
* ?newyear - days until new years
* ?heavymetalise (message) - styles the vowles of the text
* ?rainbow (text) - colorizes your text
* ?eyerape (text) - even worse then rainbow
* ?rr (nick) - Play a game of Russian Rullete
* ?fml    - Returns a "F*ck My Life"

_GifMe_
* ?randomgif - grabs a random gif from gifme
* ?gif (term) - returns the best match from gifme

_Movie_
* ?movie (movie name) :year - the year is optional but must be prefixed with a colon

_Urban Dictionary_
* ?ud (definition) - returns a definition
* ?wotd - World of the day

_Weather_
* ?w (location)
* ?wx (location)
* ?setw (location) - Sets your current location so the bot will remember if you do ?w
* ?hurricane - gets current hurricane activity
* ?forecast (location)

_PDF Info_
This plugin grabs the metadata from a pdf that is linked in channel

_DBZ_
responds when you say certain keywords

### Network Specific Plugins
#### FlagRun Networks
_URL Grabber_
Grabs metadata from url in channel

#### DarkScience

_API_
* ?finger (nick) - pulls nickname information from the DarkScience API
* ?stats (nick) - pulls statistics information for a nick from the DarkScience API
* ?peek (channel) - pulls channel information from Darkscience API

_QDB_
* ?addquote (text) - submits quote to DarkScience API
* ?quote (id) - grabs the quote matching that ID for the specific channel
* ?quote - grabs random quote for channel

_LibSecure_
** only works in \#libsecure channel **
* ?latest - grabs the latest post from libsecure
