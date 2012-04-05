#!/usr/bin/ruby

require 'socket'

s = TCPSocket.new('localhost', 50000)
# Add tasks
#s.write "\xdb--job download_version --config m100 --territory USGala --version 3.0.00.66"
s.puts "\xdb--job download_version --config m100 --territory USGala --version 3.0.00.64"
s.puts "\xdb--job download_version --config m100 --territory USGala --version 3.0.00.65"
s.puts "\xdb--job download_version --config m100 --territory USGala --version 3.0.00.66"
s.puts "\xdb--job download_version --config m100 --territory USGala --version 3.0.00.67"
s.puts "\xdb--job download_version --config m100 --territory USGala --version 3.0.00.68"
s.puts "\xdb--job download_version --config m100 --territory USGala --version 3.0.00.69"

# Get status of running task
#s.puts "\xdcstatus"

# Remove task by id
#s.puts "\xdd1"
#puts s.gets

# Get queue of tasks 
s.puts "\xdcqlist"

#all_data = []
#while true
#    res = s.read(100)
#    if res.nil?
#        break
#    elsif res.length == 0
#        break
#    end

#    all_data << res
#end

while line = s.gets
    if line.chomp[-1].chr == "\xde"
        break
    end
    puts line
end

#s.close

#puts all_data.join()
