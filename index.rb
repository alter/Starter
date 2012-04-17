#!/usr/bin/ruby
# encoding: UTF-8

require 'rubygems'
require 'sinatra'
require 'haml'
require 'socket'

set :haml, :format => :html5
@@result = []
@@queue  = []

@@servers= { 
            "m100" => {"ip" => "192.168.198.66", "check" => 1}, 
            "Bart" => {"ip" => "195.211.130.227", "check" => 1},
            "Lisa" => {"ip" => "195.211.130.227", "check" => 0 }
           }

@@socket = "" # class variable for socket


def getStatus()
    @@socket.puts "\xdcstatus"
    while data = @@socket.gets()
        if data.chomp[-1].chr == "\xde"
           break
        end
        @@result << data.chomp()
    end
end

def getQueue()
    @@socket.puts "\xdcqlist"
    while data = @@socket.gets()
        if data.chomp[-1].chr == "\xde"
           break
        end
        @@queue << data
     end
end

get '/' do
    haml :index
end

post '/' do
    territory   = params[:territory]
    version     = params[:version]
    job         = params[:job]
    server      = params[:server]

    @@socket = TCPSocket.new(@@servers[server]["ip"], 50000)

    if ( version =~ /[0-9]\.[0-9]\.[0-9]{2}\.[0-9]{1,2}/ && territory =~ /[a-zA-Z_]{1,20}/ && job =~ /[a-zA-Z_]{1,20}/ && server =~ /[a-zA-Z0-9]{1,10}/ )
       arg = "--job #{job} --config #{server} --territory #{territory} --version #{version}"
       @@socket.puts "\xdb#{arg}"
    else
       arg = ""
    end

    redirect '/success', 307 
end

get '/success' do
    redirect '/results', 303
end

post '/success' do
    @@result = []
    @@queue  = []
   
    getStatus()
    getQueue()

    @@socket.close()

    haml :success, :locals => {:result => @@result, :queue => @@queue }
end

get '/results' do	
    @@result = []
    @@queue  = []

    @@servers.each do |server,value|
        if @@servers[server]["check"] == 1
		    @@socket = TCPSocket.new(@@servers[server]["ip"], 50000)
                @@result << "<h4>Server: #{@@servers[server]["ip"]} (#{server})</h4>"
                getStatus()
                @@queue  << "<h4>Server: #{@@servers[server]["ip"]} (#{server})</h4>"
                getQueue()
            @@socket.close()
        end
    end

    haml :results, :locals => {:result => @@result, :queue => @@queue }
end

