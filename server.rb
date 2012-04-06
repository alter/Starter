#!/usr/bin/ruby

require 'socket'
require 'lib/queue.rb'
require 'logger'

host = '0.0.0.0'
port = 50000

obj = TQueue.new
server = TCPServer.new(host, port)

log = Logger.new('server.log')
log.info ""
log.info "Logserver has been started"
log.info ""
$current_task = "";

Thread.start do
    loop do
        arg = obj.pull
        if arg != nil
            $current_task = arg
            log.info "Task with arguments: \"#{arg}\" has been started"
            %x[/usr/bin/python /home/a1/GPT_launcher/launcher.py #{arg}]
            log.info "Task with arguments: \"#{arg}\" has been finished"
            $current_task = ""
        else
            log.info "Queue is empty"
            log.info "Waiting 60 seconds"
            sleep 60
        end
    end
end

loop do
    socket = server.accept
    Thread.start do
        port = socket.peeraddr[1]
        name = socket.peeraddr[2]

        log.info "Recieving from #{name}:#{port}"
        begin
            while arg = socket.gets
                if arg[0].chr == "\xdb"
                    arg.sub!("\xdb","")
                    log.info "Task with arguments: \"#{arg}\" has been added in queue"
                    obj.push(arg)
                elsif arg[0].chr == "\xdc"
                    arg.sub!("\xdc","")
                    if arg.chomp == "qlist"
                        if obj.list.size > 0
                            socket.puts(obj.list)
                            socket.puts("\xde")
                        else
                            socket.puts("Queue is empty")
                            socket.puts("\xde")
                        end
                    elsif arg.chomp == "status"
                        if $current_task != ""
                            socket.puts($current_task)
                            socket.puts("\xde")
                        else
                            socket.puts("There is no running tasks")
                            socket.puts("\xde")
                        end
                    end
                elsif arg[0].chr == "\xdd"
                    arg.sub!("\xdd","")
                    socket.puts(obj.remove(arg))
                    log.info("Task №#{arg} has been removed")
                    socket.puts("Task №#{arg} has been removed")
                    socket.puts("\xde")
                else
                    socket.puts("It's a spam message")
                    socket.puts("\xde")
                end
            end
            rescue ClientQuitError
                log.error "*** #{name}:#{port} disconnected"
            ensure 
                socket.close()
        end
    end
end
