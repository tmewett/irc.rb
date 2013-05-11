require "socket"

class IRC
    # attr_writer :cfg

    def initialize(hash)
        @_socket = TCPSocket.new(hash[:net], hash[:port])

        @_cb = Hash.new(Proc.new {}) # Return empty Proc if the command doesn't exist
        @names = {}

        @_cfg = hash
        self.configure
    end

    def configure; end

    def on(event, &block) # Define event callbacks
        @_cb[event] = block
    end

    def trigger(event, *args)
        @_cb[event].call(*args)
    rescue => err
        puts err.message
    end

    def send(text)
        @_socket.puts(text + "\r\n")
    end

    def say(chan, text)
        send("PRIVMSG #{chan} :#{text}")
    end

    def start

        puts "Logging in..."
        send("NICK #{@_cfg[:nick]}")
        send("USER #{@_cfg[:nick]} #{@_cfg[:net]} * :tmewett/irc.rb")

        while true
            @_socket.gets("\r\n")
            # puts $_

            part = $_.split(":", 3).map!(&:split)
            user = part[1][0].split("!")[0]

            if $_[0, 4] == "PING"
                puts "Ping pong!"
                send("PONG #{$_[6..-1]}")
            else
                case part[1][1]
                when "376" # End of MOTD
                    puts "Joining channels..."
                    @_cfg[:chan].each { |c| send("JOIN #{c}") }

                when "353" # RPL_NAMES
                    puts "Processing names..."
                    @names[part[1][4]] = part[2][1..-1].map! { |u| u.gsub(/^[@\+]/, "") }

                when "PRIVMSG"
                    if part[2][0] == @_cfg[:nick]+"," or part[2][0] == @_cfg[:nick]+":"
                        trigger(part[2][1], part[1][2], user, part[2][2..-1])
                    else
                        trigger(:privmsg, part[1][2], user, part[2])
                    end

                when "JOIN"
                    if user != @_cfg[:nick]
                        @names[part[1][2]] << user
                        trigger(:join, part[1][2], user)
                    end

                when "PART"
                    if user != @_cfg[:nick]
                        @names[part[1][2]].delete(user)
                        trigger(:leave, part[1][2], user)
                    end
                
                when "QUIT"
                    @names.each_value { |v| v.delete(user) if v.include?(user) }
                    trigger(:leave, nil, user)

                end
            end
        end

    end

end