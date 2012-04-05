#!/usr/bin/ruby
# encoding: UTF-8

require 'rubygems'
require 'sinatra'
require 'haml'
require 'socket'

set :haml, :format => :html5
@@result = []
@@queue  = []
socket = TCPSocket.new('localhost', 50000) 

get '/' do
    haml :index
end

post '/' do
    territory   = params[:territory]
    version     = params[:version]
    job         = params[:job]
    server      = params[:server]

    arg = "--job #{job} --config #{server} --territory #{territory} --version #{version}"
    socket.puts "\xdb#{arg}"

    socket.puts "\xdcstatus"
    while data = socket.gets()
        if data.chomp[-1].chr == "\xde"
           break 
        end
        @@result << data
    end

    socket.puts "\xdcqlist"
    while data = socket.gets()
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
   
    socket.puts "\xdcstatus"
    while data = socket.gets()
        if data.chomp[-1].chr == "\xde"
           break 
        end
        @@result << data
    end
    
    socket.puts "\xdcqlist" 
    while data = socket.gets()
        if data.chomp[-1].chr == "\xde"
           break 
        end
        @@queue << data
     end

 
    haml :success, :locals => {:result => @@result, :queue => @@queue }
end
