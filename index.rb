require 'rubygems'
require 'sinatra'
require 'haml'

set :haml, :format => :html5
@@result = "No running processes"

get '/' do
    haml :index
end

post '/' do
    territory   = params[:territory]
    version     = params[:version]
    job         = params[:job]
    server      = params[:server]
    Process.detach(fork{ %x[/usr/bin/python /home/a1/GPT_launcher/launcher.py --job #{job} --config #{server} --territory #{territory} --version #{version}] })
    sleep 2    
    @@result = %x[ps -ef|grep \[l\]auncher.py]
    if @@result == ""
        @@result = "No running processes"
    end
    redirect '/success' 
end

get '/success' do
    haml :success, :locals => {:result => @@result }
end
