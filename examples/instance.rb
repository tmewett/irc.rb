require "irc"

bot = IRC.new(
    net: "irc.quakenet.org", port: 6667,
    nick: "greetbot",
    chan: ['#your', '#chans', '#here']
)
bot.on(:join) { |chan, user| say chan, "Hello, #{user}!" }
bot.start