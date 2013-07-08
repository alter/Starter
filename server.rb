#!/usr/bin/ruby
# encoding: ASCII-8BIT

require 'socket'
require './lib/queue.rb'
require 'logger'
require 'open3'

host = '0.0.0.0'
port = 50000

obj = TQueue.new
server = TCPServer.new(host, port)

log = Logger.new('./server.log')
log.info ""
log.info "Logserver has been started"
log.info ""
$current_task = "";

PROGRAM_PATH = "/home/a1/GPT_launcher/launcher.py"
exit_status = nil
error = nil
Thread.start do
    loop do
        arg = obj.pull
        if arg != nil
            $current_task = arg
            cmd = "#{PROGRAM_PATH} #{arg}"
            log.info "Task with arguments: \"#{arg}\" has been started"
            Open3.popen3(cmd) { |i,o,e,t|
                pid = t.pid
                exit_status = t.value 
                error = e.read
            }
            log.info "Task with arguments: \"#{arg}\" has been finished with exit status #{exit_status}"
            $current_task = ""
            File.open('error', 'w') { |file| file.write(error)}
        else
            log.info "Queue is empty. Waiting 60 seconds"
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
                    arg.sub!(";","")
                    arg.sub!(",","")
                    arg.sub!(":","")
                    arg.sub!("`","")
                    arg.sub!("&","")
                    arg.sub!("\n","")
                    arg.sub!("|","")
                    arg.sub!("\\","")
                    arg.sub!("eval","")
                    log.info "Task with arguments: \"#{arg}\" has been added in queue"
                    obj.push("#{arg}\n")
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
                        cnt = %x[wc -l ./error|awk '{print $1}'].chomp
                        if $current_task != ""
                            socket.puts($current_task)
                            socket.puts("\xde")
                        elsif cnt.to_i == 0
                            socket.puts("There is no running tasks")
                            socket.puts("\xde")
                        else 
                            socket.puts("Error: #{exit_status}")
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
