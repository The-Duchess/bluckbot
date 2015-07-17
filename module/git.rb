#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
# module as defined by .plugin.rb
#############################################################################################
# GLOBALS:
# - $logs are stored like [most recent - least recent], they are also unparsed
# - $admin_s is the list of admins
# - $plugins_s is the array of active plugins
#############################################################################################


$LOAD_PATH << './module'
require '.pluginf.rb'

class Git_pull < Pluginf
      #any functions you may need

      #your definition for script
      def script(message, nick, chan)

            if not $admin_s.include? nick
                  return "NOTICE: #{nick} :please do not disturb the irc bots"
            end

            `git pull`

            return "NOTICE #{nick} :git pull has been done"
      end
end

reg_p = /^`pull/ #regex to call the module
na = "git" #name for plugin #same as file name without .rb
de = "performs a git pull" #description

#plugin = Class_name.new(regex, name, help)
#pushed onto to the end of plugins array array
plugin = Git_pull.new(reg_p, na, de)
$plugins_s.push(plugin)
