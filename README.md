**THIS PROJECT IS LARGELY NOT RECIEVING UPDATES**

> check out [Husk](https://github.com/The-Duchess/husk), my new IRC bot project.

# **Bluckbot**

**Version 1.5.5**

- Bluckbot is a modular/plugable irc bot written with the Ruby programming language
- Bluckbot is written by Alice "Duchess" Archer
- Bluckbot is not designed to support windows because the config setup scripts and some plugins rely on linux core utils
- Bluckbot requires ruby 2.1 or higher
- Bluckbot comes with a gemfile which you can use bundler to auto install gems for the bot
- To use, clone this repository on your machine and then choose your method of setup
- To setup for use without manually configuring, run setup.rb
- To setup run setup.sh and it will create the necessary files/folders for basic operation and you can configure manually
- To run if configs are setup run ./run.sh
- To create Plugins follow the [Instructions](https://github.com/The-Duchess/bluckbot/blob/master/makingplugins.md)
- The screenshot below is the bot seen via PuTTY running in Windows 8.1

> Note: some modules may have their own files, and gem requirements, also vote.rb, cah.rb and cah_2.rb are not complete

**Libraries for Default Instance and All Existing Plugins**

>- 'cgi'
>- 'json'
>- 'open-uri'
>- 'net/http'
>- 'optparse'
>- 'date'
>- 'socket'
>- 'openssl'
>- 'google/api_client'
>- 'net/http'
>- 'multi_json'
>- 'marky_markov'

**Config Files (./res/)**

>- .config.sh contains the connection information for the bot
>- .admins contains the list of admin users as nicks
>- .chanlist contains a list of channels that can be joined with \`load chans
>- .modlist contains a list of modules as their file names that can be loaded with \`mass load
>- .nick_name contains the nick for the bot (default: bluckbot)

**Using:**

>- \`plsgo : tells the bot to quit
>- \`ignore $NICK : tells the bot to ignore a nick
>- \`unignore $NICK : tells the bot to remove a nick from the ignore list
>- \`lsign : gives a list of ignored nicks
>- \`save | \`load chans : saves and loads channels from currently active and previously saved
>- \`list channels : lists channels
>- \`msg $NICK message : sends a message to $NICK
>- \`act $CHANNEL action : sends an action to $CHANNEL
>- \`part : parts the bot from the channel this is sent from
>- \`join $#CHANNEL : joins a channel
>- \`k $NICK reason: only accessible to the owner and kicks a user from the channel
>- \`help : prints help
>- \`load $MODULE : loads a module
>- \`unload $MODULE : unloads a module
>- \`reload $MODULE : reloads a module
>- \`ls : lists modules
>- \`list : lists loaded modules
>- \`help $MODULE : gives help on a certain module
>- \`mass load : loads a preset set of modules in ./res/.modlist

**Screenshot**

![Alt text](https://github.com/The-Duchess/bluckbot/blob/master/demo.png)


**Warranty and License**

> This source code comes with no warranty, implied or otherwise, and is published under the GNU/GPL v3 license.
> you should have recieved a copy of the license with this software, if not you can find it at:
>>http://www.gnu.org/licenses/gpl-3.0.html

> for questions you can email me at my github email
