irc.rb
======

An IRC library that actually makes sense. Currently less than 100 lines!

## Example

```ruby
require "irc"

class Bot < IRC
    def configure
        on(:join) do |chan, user|
            say chan, "Hello, #{user}!"
        end
    end
end

bot = Bot.new({
    net: "irc.quakenet.org", port: 6667,
    nick: "greetbot",
    chan: ['#your', '#chans', '#here']
})
bot.start
```

## Usage

### `::new(hash)`
Pass a configuration hash when you initialize the IRC class.

### `#configure`
Run at the end of `#initialize`. Add handlers with `#on` in here. Saves the `def initialize(args); super args;` procedure.

### `#on(event, block)`
Adds/overwrites a listener to `event` and executes `block` when it happens. Use `:symbols` for IRC events and `"strings"` for user ones. Execute commands like:
```
<you> greetbot: slap another-user
* greetbot slaps another-user with a large fish
```
This will execute the `"slap"` callback, passing the channel it was in, the user who said it and all the words after (in this case, another-user) in an array as arguments.

_Please note that some IRC event callbacks are missing, but I am adding them._
 
### `#send(text)`
Sends the raw string `text` to the IRC socket and adds correct line endings.

### `#say(chan, text)`
Shortcut for `#send("PRIVMSG #{chan} :#{text}")`

### `#start`
Connects and starts the (blocking) mainloop for listening and calling.
