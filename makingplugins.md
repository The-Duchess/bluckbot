# **Making Plugins**

Plugins use polymorphism to achieve a modular behavior by making plugins parent classes of a definition.

>This is Achieved by the base class stored in module/.pluginf.rb which stores default functionss for initalization, script, and cleanup as well as other functions you will not need to or should not touch (i.e regex).
- initialization can be edited to allow you to hold additional variables in the plugin class and load files. the current convention for files is that the initialize will create the neccessary resource and config files if they do not exist. no plugin will be added to the repo if it requires additional setup by the user.
- script is the function that is called by the bot core and is what should return your message line

>> NOTE: if you return a string not prefixed by a "command destination :" then the message will be set back to the previous channel in one message per line; delimited by '\n'. however if you prefix that with "command destination :" the bot core formats it into a number of messages based on '\n' as a delimiter and puts the "command destination :" at the beginning of all of them. not all commands are supported; as of now PRIVMSG, NOTICE, KICK, and MODE are supported. any information on this can be located in the IRC RFC.
>
- cleanup allows for modules to save files on close as this function is called when a plugin is unloaded and when the bot exits safely.

Plugins should be made using the template. There are things you will need to change in order you make your plugin behave as well as conventions you will need to follow. most, if not all, of this information is in module/.template.rb as well as this file will clarify what needs to be done to create your plugin.

>Things to change
>- any additional libraries you will need, as well as gems, must be loaded before the change in $LOAD_PATH.
>- Change the Class Name to something appropriate for your plugin, note: ruby requires class name to begin with a capital character. Also change the Template at the bottom where the new instance is allocated.
>- the prefix option allows for more complex regex to trigger the plugin. since the easiest way to determine what to do in IRC is regex pattern matching; plugins are called if the message someone says (the message variable) matches the pattern. so either use a simple regex or a union of a set. this variable is reg_p at the bottom.
>- you will need to set the name. the convention to allow for easy reloading without storing additional variables works by having the downcase of the name be the filename without the .rb. this also requires your filename to be lower case, so remember that when you save. the variable for name is na.
>- you may also want to provide a description or help for users for your plugin. this is variable de.

After that there are some globals that are more convenient to be stored globally as opposed to passed around. these are the backlog ($logs) which is irc messages stored most recent to least recent. they are the unparsed message lines read from the IRC socket. you also have a list of admins ($admin_s) by nick to filter users or abuse the bot if you feel like exploiting your own bot instance. and there is the plugin list ($plugins_s) but you shouldn't need to use this unless you want to make a plugin to remove the need of the bot core control.

You can add additional functions to the plugin inside the class, and multithread if you want, however remember that irc is driven from events of reads from the sock and triggers for plugins are synchronous with this. however all plugins that match a regex will be checked so you can use a regex // and manage threads on any message.

a last note. plugins default to ["any"] for channels that they can be called in. this can be edited if you want something to work only in any set of locations. a good example would be a multiplayer game.
