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

    def send(text)
        @_socket.puts(text + "\r\n")
    end

    def say(chan, text)
        send("PRIVMSG #{chan} :#{text}")
    end

    def start

        send("NICK #{@_cfg[:nick]}")
        send("USER ruor #{@_cfg[:net]} * :tmewett/irc.rb")

        while true
            @_socket.gets("\r\n")
            puts $_

            part = $_.split(":", 3).map!(&:split)
            user = part[1][0].split("!")[0]

            if $_[0, 4] == "PING"
                send("PONG #{$_[6..-1]}")
            else
                case part[1][1]
                when "376" # End of MOTD
                    @_cfg[:chan].each { |c| send("JOIN #{c}") }

                when "353" # RPL_NAMES
                    @names[part[1][4]] = part[2][1..-1].map! { |u| u.gsub(/^[@\+]/, "") }

                when "PRIVMSG"
                    if part[2][0] == @_cfg[:nick]+"," or part[2][0] == @_cfg[:nick]+":"
                        @_cb[part[2][1]].call(part[1][2], user, part[2][2..-1])
                    else
                        @_cb[:privmsg].call(part[1][2], user, part[2])
                    end

                when "JOIN"
                    if user != @_cfg[:nick]
                        @names[part[1][2]] << user
                        @_cb[:join].call(part[1][2], user)
                    end

                end
            end
        end

    end

end