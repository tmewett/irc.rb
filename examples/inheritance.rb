require "irc"

class Bot < IRC
    def configure
        on(:join) do |chan, user|
            say chan, "Hello, #{user}!"
        end
    end
end

Bot.new(
    net: "irc.quakenet.org", port: 6667,
    nick: "greetbot",
    chan: ['#your', '#chans', '#here']
).start