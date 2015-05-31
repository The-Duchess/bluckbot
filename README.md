**Bluckbot Version 1.1.7**

- Bluckbot is a modular/plugable irc bot written with the Ruby programming language
- Bluckbot requires ruby 2.1 or higher
- Bluckbot is written by Alice "Duchess" Archer
- To setup run setup.sh and it will create the necessary files/folders for basic operation

>note: some modules may have their own files

- To run, edit the ./res/.config.sh file and run ./run.sh

>\#!/bin/bash

>\#network name

>export NETWORK_N=

>\#Port Number

>export PORT_V=

>\#channel name without the #

>export CHANNEL_N=

>\#LOGGING TRUE | FALSE

>export LOGGING_YN=

>\#WHETHER TO USE PASS TRUE | FALSE

>export PASS_YN=

>\#Passphrase

>export PASSPHRASE=

- To create Plugins follow the template ./module/.template.rb

**Config Files (./res/)**

- .admins contains the list of admin users as nicks
- .chanlist contains a list of channels that can be joined with `load chans
- .modlist contains a list of modules as their file names that can be loaded with `mass load
- .nick_name contains the nick for the bot (default: bluckbot)

> This source code comes with no warranty, implied or otherwise, and is published under the GNU/GPL v3 license.
> you should have recieved a copy of the license with this software, if not you can find it at:
>>http://www.gnu.org/licenses/gpl-3.0.html

> for questions you can email me at my github email
