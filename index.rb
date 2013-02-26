#!/usr/bin/ruby
# encoding: ASCII-8BIT

require 'sinatra'
require 'haml'
require 'socket'
require 'thin'

class App < Sinatra::Base
	set :haml, :format => :html5
	$result = []
	$queue  = []

	$servers= { 
							"m100" => {"ip" => "192.168.198.66", "check" => 1}, 
							"Bart" => {"ip" => "195.211.130.227", "check" => 1},
							"Lisa" => {"ip" => "195.211.130.227", "check" => 0 }
						 }
	$socket = "" # class variable for socket


	def getStatus()
			$socket.puts "\xdcstatus"
			while data = $socket.gets()
					if data.chomp[-1].chr == "\xde"
						 break
					end
					$result << data.chomp()
			end
	end

	def getQueue()
			$socket.puts "\xdcqlist"
			while data = $socket.gets()
					if data.chomp[-1].chr == "\xde"
						 break
					end
					$queue << data
			 end
	end

	get '/' do
			haml :index
	end

	get '/css/bootstrap-responsive.css' do
		"Hello World"
	end


	post '/' do
			territory   = params[:territory]
			version     = params[:version]
			job         = params[:job]
			server      = params[:server]

			$socket = TCPSocket.new($servers[server]["ip"], 50000)
	#    $socket.set_encoding 'UTF-8' 

			if ( version =~ /[0-9]\.[0-9]\.[0-9]{2}\.[0-9]{1,2}(\.[0-9]{1,3})?/ && territory =~ /[a-zA-Z_]{1,20}/ && job =~ /[a-zA-Z_]{1,20}/ && server =~ /[a-zA-Z0-9]{1,10}/ )
				 arg = "--job #{job} --config #{server} --territory #{territory} --version #{version}"
				 $socket.puts "\xdb#{arg}"
			else
				 arg = ""
			end

			redirect '/success', 307 
	end

	get '/success' do
			redirect '/results', 303
	end

	post '/success' do
			$result = []
			$queue  = []
		 
			getStatus()
			getQueue()

			$socket.close()

			haml :success, :locals => {:result => $result, :queue => $queue }
	end

	get '/results' do	
			$result = []
			$queue  = []
			$servers.each do |server,value|
					if $servers[server]["check"] == 1
					$socket = TCPSocket.new($servers[server]["ip"], 50000)
									$result << "<h4>Server: #{$servers[server]["ip"]} (#{server})</h4>"
									getStatus()
									$queue  << "<h4>Server: #{$servers[server]["ip"]} (#{server})</h4>"
									getQueue()
							$socket.close()
					end
			end

			haml :results, :locals => {:result => $result, :queue => $queue }
	end

	time_ccu_hash = Hash.new()
	result_arr = []

	get '/ccugrep' do
			result_arr = []
			haml :ccugrep, :locals => {:result => result_arr, :request => request.request_method}
	end

	post '/ccugrep' do
			text   = params[:text]
			time_ccu_hash.clear
			result_arr.clear
			regex = Regexp.new(/([0-9]{13}),\ ([0-9]{1,4})/)
			text.scan(regex){|key, value| time_ccu_hash[Time.at(key.to_i/1000).utc] = value}
			time_ccu_hash.sort.each{|key,value| result_arr << "#{key}: #{value}"}

			haml :ccugrep, :locals => {:result => result_arr, :request => request.request_method}
	end
end


App.run!({:port => 4567})
