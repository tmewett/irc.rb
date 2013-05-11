require "irc"

# Makes random, related remarks when seeing trigger words.
# Users can add with the command syntax:
# on <word> say <string>
class Remark < IRC
    def configure
        @trigger = {}

        on("on") do |chan, u, args|
            if @trigger.include?(args[0].downcase!)
                @trigger[args[0]] << args[2..-1] * " "
            else
                @trigger[args[0]] = [args[2..-1] * " "] 
            end
            say chan, "Added remark."
        end

        on("forget") do |c, u, args|
            args.each { |r| @trigger.delete(r) }
        end

        on(:privmsg) do |chan, u, text|
            same = text & @trigger.keys
            say(chan, @trigger[same[0]].sample) if same != []
        end
    end
end