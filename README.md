**Bluckbot**

- Bluckbot is a modular/plugable irc bot written with the Ruby programming language
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
