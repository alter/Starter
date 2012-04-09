#!/usr/bin/ruby
# encoding: UTF-8

require 'rubygems'
require 'sinatra'
require 'haml'
require 'socket'

set :haml, :format => :html5
@@result = []
@@queue  = []
@@servers= { "m100" => "192.168.198.66", "Bart" => "195.211.130.227", "Lisa" => "195.211.130.227" }
@@socket = "" # global variable for socket

get '/' do
    haml :index
end

post '/' do
    territory   = params[:territory]
    version     = params[:version]
    job         = params[:job]
    server      = params[:server]

    @@socket = TCPSocket.new(@@servers[server],50000)

    if ( version =~ /[0-9]\.[0-9]\.[0-9]{2}\.[0-9]{1,2}/ && territory =~ /[a-zA-Z_]{1,20}/ && job =~ /[a-zA-Z_]{1,20}/ && server =~ /[a-zA-Z0-9]{1,10}/ )
       arg = "--job #{job} --config #{server} --territory #{territory} --version #{version}"
       @@socket.puts "\xdb#{arg}"
    else
       arg = ""
    end


    @@socket.puts "\xdcstatus"
    while data = @@socket.gets()
        if data.chomp[-1].chr == "\xde"
           break 
        end
        @@result << data
    end

    @@socket.puts "\xdcqlist"
    while data = @@socket.gets()
        if data.chomp[-1].chr == "\xde"
           break 
        end
        @@queue << data
     end
    
    redirect '/success' 
end

get '/success' do
    @@result = []
    @@queue  = []
   
    @@socket.puts "\xdcstatus"
    while data = @@socket.gets()
        if data.chomp[-1].chr == "\xde"
           break 
        end
        @@result << data
    end
    
    @@socket.puts "\xdcqlist" 
    while data = @@socket.gets()
        if data.chomp[-1].chr == "\xde"
           break 
        end
        @@queue << data
     end

 
    haml :success, :locals => {:result => @@result, :queue => @@queue }
end
