# Zbot
Cinch IRC bot written with plenty of help. I will not claim any of the plugins
And will try to get the correct credits in source

## Commands
roles: owner,admin,operator,halfop,voice,nobody
prefix: admin(\?), action(!), meme(.), remote(?)

### Admin
_Channel_

* \?join (\#channel) - admin
* \?part (\#channel) - admin
* \?quit (\#channel) - owner

_Plugins_
* \?plugin load   (plugin) - admin
* \?plugin unload (plugin) - admin
* \?plugin reload (plugin) - admin
* \?plugin set    (plugin) - admin

_Permissions_

* \?set admin  (user) - owner
* \?set op     (user) - admin
* \?set hop    (user) - op
* \?set voice  (user) - halfop
* \?set nobody (user) - halfop

_Developer_

* \?e code  - owner // (alias: eval) Evaluate command
* \?em code - owner // (alias: eval) Evaluate command send in msg
* \?er code - owner // (alias: evalreply) Evaluate command and send to channel


### Plugins
_Utility_

* !convert
* !math
* !wx
* !wiki

_Quotes_

* !quote

_Misc_

* !attack (target) - any
* !8ball (question) - any
* !roll (dice) - any
* !silly (dice) - any
* !urban (dice) - any
* !vote (dice) - any
* !info (dice) - any
* !rr (dice) - any