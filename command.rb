#!/bin/env ruby

$plugins_s = Array.new

#allows some functions of loading or unloading modules or listing files to be restricted
def check_admin(nick)
    	if $admin_s.include? nick.to_s
    		return true
    	else
    		return false
    	end
end

def parse(nick, chan, message)

    message = message[0..-2].to_s
    #p message

    if message.match(/^`load /)
    	
	   if not check_admin(nick)
	     return "NOTICE #{nick} :please do not disturb the irc bots."
	   end
    	
        if message.match(/^`load /) and message.length > 5 then
    		$LOAD_PATH << './module'
    		ls = message.to_s[6..-1]
            if !ls.match(/.rb$/)
                ls = "#{ls}.rb"
            end
    		#checks if the module is already loaded
    		@ra = ""
    		$plugins_s.each { |a| @ra.concat("#{a.name.downcase}.rb ")}
    		@rb = @ra[0..-1].split(" ")
    		@rb.each do |a|
    			if a == ls
    				return "#{ls} is already loaded"
    			end
    		end
    		#checks if the module is is there
    		@ra = `ls ./module/`.split("\n").each { |a| a.to_s[0..-2]}
    		if not @ra.include? ls
    			return "#{ls} does not exist"
    		end
    		#load ls
    		load "#{ls}"
    		$LOAD_PATH << './'
    		return "#{ls} loaded"
    	end
    end

    if message.match(/^`ls$/)
    	
        if not check_admin(nick)
		  return "NOTICE #{nick} :you are not in the admin file\nplease contact the bot owner for questions"
	    end
    	
    	@r = "PRIVMSG #{nick} :"
    	@ra = `ls ./module/`.split("\n").each { |a| a.to_s[0..-1]}
    	@ra.each { |a| @r.concat("#{a} ")}
    	return @r[0..-1]
    end


    if message.match(/^`list$/)

    	@r = "NOTICE #{nick} :"

    	$plugins_s.each do |a|
    		#p a.class.to_s
    		#p a.regex.to_s
    		#p a.name.to_s
    		#p a.help.to_s
    		@r.concat("#{a.name} ")
    	end

    	return @r[0..-2]
    end

    if message.match(/^`help /)
        @ii = 0
        @r = ""
        $plugins_s.each do |a|
            #p message.to_s[6..-1]
            #p a.name.to_s
            if a.name.to_s.downcase == message.to_s.downcase[6..-1]
                @r = "NOTICE #{nick} :#{a.name} description: #{a.help}"
                return @r
            end

            next
        end

        return "no plugin: #{message[6..-1]} was found"
    end

    if message.match(/^`unload /)
    	
        if not check_admin(nick)
	       return "NOTICE #{nick} :please do not disturb the irc bots."
	    end
    	
    	@ii = 0
    	@r = ""
    	$plugins_s.each do |a|
    		#p message.to_s[8..-1]
    		#p a.name.to_s
    		if a.name.to_s.downcase == message.to_s.downcase[8..-1]
    			@r = "plugin #{a.name.to_s} removed"
                p "class"
                p a.class.to_s
                $plugins_s[@ii].cleanup
    			$plugins_s.delete_at(@ii)
    			return @r
    		else
    			@ii += 1
    		end

    		next
    	end

    	return "no plugin was unloaded"
    end

    if message.match(/^`mass load$/)
    	
    	if not check_admin(nick)
		  return "NOTICE #{nick} :please do not disturb the irc bots."
	   end
    	
    	temp_r = []
    	File.open("./res/.modlist", 'r') do |fr|
    		while line = fr.gets
    			line.chomp!
    			temp_r.push(line.to_s)
    		end
    	end
        temp_p = []
        $plugins_s.each { |a| temp_p.push("#{a.name.downcase}.rb")}
        temp_r.each do |a|
            if temp_p.include? a
                p "#{a} is already loaded"
                next
            end
            
            $LOAD_PATH << './module'
            begin
            	load "#{a}"
            rescue => e
            	p "failed to load #{a}"
            end
        
            $LOAD_PATH << './'
        end
    end

	if $plugins_s.length > 0 then
		$plugins_s.each { |a| if (message.match(a.regex)) and (a.chans.include? chan or a.chans.include? "any") then return a.script(message, nick, chan) end }
	end

	return ""

end
